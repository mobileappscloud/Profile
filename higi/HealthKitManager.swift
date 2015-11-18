//
//  HealthKitManager.swift
//  higi
//
//  Created by Remy Panicker on 11/9/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import HealthKit

public class HealthKitManager {
    
    private static let sharedInstance: HealthKitManager = {
       let manager = HealthKitManager()
        manager.currentSource({ (source) in
            manager.deviceSource = source
        })
        manager.healthStore.executeQuery(manager.stepObserverQuery)
        return manager
    }()
    
    private var deviceSource: HKSource? = nil
    
    private lazy var stepObserverQuery: HKObserverQuery = {
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!
        let observerQuery = HKObserverQuery(sampleType: sampleType, predicate: nil, updateHandler: { (observerQuery, completionHandler, error) in
            print("OBSERVE THIS SHIT")
        })
        return observerQuery
    }()
    
    private lazy var healthStore: HKHealthStore! = {
        return HKHealthStore()
    }()
    
    private let healthKitReadTypes = Set<HKQuantityType>(arrayLiteral:
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!
    )
    
    public class func isHealthDataAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    /**
     
    */
    public class func shouldShowAuthorizationModal() -> Bool {
        return !PersistentSettingsController.boolForKey(.DidShowActivityTrackerAuthorizationRequest)
    }
    
    private func currentSource(completion: (source: HKSource?) -> Void) {
        let sampleType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!
        let query = HKSourceQuery(sampleType: sampleType, samplePredicate: nil, completionHandler: { (query, sources, error) in
            if sources == nil {
                completion(source: nil)
                return
            }
            
            var healthKitSource: HKSource? = nil
            for source in sources! {
                if source.bundleIdentifier.hasPrefix("com.apple.health") {
                    healthKitSource = source
                }
                break;
            }
            completion(source: healthKitSource)
        })
        self.healthStore.executeQuery(query)
    }
    
    public class func requestReadAccessToStepData(completion: ((didRespond: Bool, error: NSError?) -> Void)!) {
        if !HealthKitManager.isHealthDataAvailable() {
            return
        }
        
        let manager = HealthKitManager.sharedInstance
        manager.healthStore.requestAuthorizationToShareTypes(nil, readTypes: manager.healthKitReadTypes) { (success, error) -> Void in
            
            PersistentSettingsController.setBool(true, key: .DidShowActivityTrackerAuthorizationRequest)
            
            for sampleType in manager.healthKitReadTypes {
                HKHealthStore().enableBackgroundDeliveryForType(sampleType, frequency: .Hourly, withCompletion: { (success, error) in
                    print(error)
                })
            }
            
            completion?(didRespond: success, error: error);
        }
    }
    
    /**

    */
    public class func hasReadAccessToStepData(completion: ((isAuthorized: Bool) -> Void)!) {
        if !HealthKitManager.isHealthDataAvailable() {
            completion(isAuthorized: false)
            return
        }
        
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: nil, limit: 1, sortDescriptors: nil, resultsHandler: { (query, samples, error) in
            let isAuthorized: Bool = samples?.count > 0
            completion(isAuthorized: isAuthorized)
        })
        HealthKitManager.sharedInstance.healthStore.executeQuery(query)
    }
    
    public class func readStepData(startDate: NSDate, var endDate: NSDate?, limit: Int?, completion: (statistics: [HKStatistics]?, error: NSError?) -> Void) {
        if endDate == nil {
            endDate = NSDate()
        }
        
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!
        
        let calendar = NSCalendar.currentCalendar()
        let modifiedStartDate = calendar.startOfDayForDate(startDate)
        let modifiedEndDate = calendar.dateBySettingHour(23, minute: 59, second: 59, ofDate: endDate!, options: NSCalendarOptions())!
        
        let interval = NSDateComponents()
        interval.day = 1
        
        let statCollectionQuery = HKStatisticsCollectionQuery(quantityType: sampleType, quantitySamplePredicate: nil, options: [.SeparateBySource, .CumulativeSum], anchorDate: modifiedStartDate, intervalComponents: interval)
        statCollectionQuery.initialResultsHandler = {
            query, results, error in
            
            var statistics: [HKStatistics] = []
            results?.enumerateStatisticsFromDate(modifiedStartDate, toDate: modifiedEndDate, withBlock:  { (statistic, stop) in
                statistics.append(statistic)
            })
            completion(statistics: statistics, error: error)
        }
        HealthKitManager.sharedInstance.healthStore.executeQuery(statCollectionQuery)
    }
    
    public class func syncStepData() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            ApiUtility.requestLastStepActivitySyncDate({ (syncDate) in
                
                let sampleStartDate = HealthKitManager.sampleStartDate(basedOnLastSyncDate: syncDate)
                if sampleStartDate == nil {
                    return;
                }
                
                HealthKitManager.readStepData(sampleStartDate!, endDate: nil, limit: nil, completion: { (statistics, error) in
                    if statistics != nil {
                        let collection = HealthKitManager.stepActivityCollection(fromHealthKitStatistics: statistics!)
                        if let parameters = collection?.dictionary() {
                            ApiUtility.uploadStepActivities(parameters, success: {

                            })
                        }
                    }
                })
                
            })
        })
    }
    
    private class func sampleStartDate(basedOnLastSyncDate syncDate: NSDate?) -> NSDate? {
        var sampleStartDate: NSDate? = nil
        
        if syncDate == nil {
            sampleStartDate = NSDate()
        } else {
            let syncMinutes = 60.0
            let syncInterval: NSTimeInterval = 60.0 * syncMinutes
            if NSDate().timeIntervalSinceDate(syncDate!) > syncInterval {
                sampleStartDate = syncDate!
            }
        }
        
        return sampleStartDate
    }
    
    public class func disableBackgroundUpdates() {
        HealthKitManager.sharedInstance.healthStore.disableAllBackgroundDeliveryWithCompletion({ (success, error) in
            if !success {
                HealthKitManager.disableBackgroundUpdates()
            }
        })
    }
}

extension HealthKitManager {
    
    static let activityDateFormatter: NSDateFormatter = {
       let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    struct StepActivityCollection {
        let higiId: String!
        let deviceId: String!
        var dates: [StepActivity] = []
        
        init(higiId: String, deviceId: String) {
            self.higiId = higiId
            self.deviceId = deviceId
        }
        
        func dictionary() -> NSDictionary {
            var dateDictionaries: [NSDictionary] = []
            for date in dates {
                dateDictionaries.append(date.dictionary())
            }
            let dictionary: NSDictionary = ["higiId" : higiId, "deviceId" : deviceId, "dates" : dateDictionaries]
            return dictionary
        }
    }
    
    struct StepActivity {
        let date: NSDate!
        let steps: Double!
        
        init(date: NSDate, steps: Double) {
            self.date = date
            self.steps = steps
        }
        
        func dictionary() -> NSDictionary {
            let formattedDateString = HealthKitManager.activityDateFormatter.stringFromDate(date)
            let stepsObjectValue = NSNumber(double: steps)
            let dictionary: NSDictionary = ["date" : formattedDateString, "steps" : stepsObjectValue]
            return dictionary
        }
    }
    
    class func stepActivity(fromHealthKitStatistic statistic: HKStatistics) -> StepActivity? {
        if statistic.quantityType != HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)! {
            return nil;
        }
        
        let date = statistic.startDate
        if HealthKitManager.sharedInstance.deviceSource != nil {
            let quantity = statistic.sumQuantityForSource(HealthKitManager.sharedInstance.deviceSource!)
            let steps = quantity?.doubleValueForUnit(HKUnit.countUnit())
            let activity = StepActivity(date: date, steps: steps!)
            return activity
        } else {
            return nil
        }
    }
    
    class func stepActivityCollection(fromHealthKitStatistics statistics: [HKStatistics]) -> StepActivityCollection? {
        if let userId = SessionData.Instance.user.userId, deviceId = HealthKitManager.sharedInstance.deviceSource?.bundleIdentifier {

            var activityCollection = StepActivityCollection(higiId: userId as String, deviceId: deviceId)
            for statistic in statistics {
                if let activity = HealthKitManager.stepActivity(fromHealthKitStatistic: statistic) {
                    activityCollection.dates.append(activity)
                }
            }
            return activityCollection
        } else {
            return nil
        }
    }
}