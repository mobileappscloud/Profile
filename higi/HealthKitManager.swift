//
//  HealthKitManager.swift
//  higi
//
//  Created by Remy Panicker on 11/9/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import HealthKit

/// Class which manages interactions with HealthKit and health data.
internal class HealthKitManager {
    
    /// The minimum amount of time (seconds) to wait before syncing data with the API.
    private static let syncInterval: NSTimeInterval = {
        let syncHours = 2.0
        let minutesPerHour = 60.0
        let secondsPerMinute = 60.0
        let syncInterval: NSTimeInterval = syncHours * minutesPerHour * secondsPerMinute
        return syncInterval
    }()
    
    /// Thread-safe singleton for storage of relevant properties.
    private static let sharedInstance: HealthKitManager = {
       let manager = HealthKitManager()
        manager.currentSource({ (source) in
            manager.deviceSource = source
        })
        return manager
    }()
    
    /// Represents data sourced from the current device.
    private var deviceSource: HKSource? = nil
    
    /// Observer query which handles background delivery of step data.
    private var stepObserverQuery: HKObserverQuery = {
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!
        let observerQuery = HKObserverQuery(sampleType: sampleType, predicate: nil, updateHandler: { (observerQuery, completionHandler, error) in
            
            if (error != nil) {
                completionHandler()
                return
            }
            
            // TODO: IF UNAUTHORIZED, stop observer query and disable background updates
            
            HealthKitManager.syncStepData({ (success, error) in
                completionHandler()
            })
        })
        return observerQuery
    }()
    
    /// The store serves as a link to all data within HealthKit.
    private lazy var healthStore: HKHealthStore! = {
        return HKHealthStore()
    }()
    
    /// Types of health data to read.
    private let healthKitReadTypes = Set<HKQuantityType>(arrayLiteral:
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!
    )
    
    /**
     Identifies the device as a source for HealthKit data.
     
     - parameter completion: Block to execute upon completion. The block will be passed the following parameters:
     - parameter source:     HealthKit source for the current device.
     */
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
                    break;                    
                }
            }
            completion(source: healthKitSource)
        })
        self.healthStore.executeQuery(query)
    }
    
    /**
     Check if health data is available.
     
     - returns: `true` if the device has a HealthKit data store and data is available for the current app to read, otherwise `false`.
     */
    internal class func isHealthDataAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    /**
     Check if the prompt to connect the branded activity tracker has been displayed.
     
     - returns: 'true' if the prompt to connect the branded activity tracker has been displayed, otherwise `false`.
     */
    internal class func didAskToConnectActivityTracker() -> Bool {
        return PersistentSettingsController.boolForKey(.DidAskToConnectActivityTracker)
    }
    
    /**
     Update value which determines if the prompt to connect the branded activity tracker has been displayed.
     
     - parameter didAsk: Boolean indicating if the user has been asked to connect an activity tracker.
     */
    internal class func didAskToConnectActivityTracker(didAsk: Bool) {
        PersistentSettingsController.setBool(didAsk, key: .DidAskToConnectActivityTracker)
    }
    
    /**
     Whether or not the app should show the system-provided HealthKit authorization modal.
     
     - returns: `true` if the app has not displayed the authorization modal yet, otherwise `false`.
     */
    internal class func didShowAuthorizationModal() -> Bool {
        return PersistentSettingsController.boolForKey(.DidShowActivityTrackerAuthorizationRequest)
    }
}

internal extension HealthKitManager {
    
    /**
     Request read access to step data within the device's health store. 
     
     __Note:__ The system-provided authorization modal can only be shown to the user once. Thus, the modal is only displayed the first time authorization is requested.
     
     - parameter completion: Block to execute upon completion. The block will be passed the following parameters:
     - parameter didRespond: Returns `true` if the user responded to the authorization modal, otherwise `false`.
     - parameter error:      Object representing an error encountered during execution.
     */
    internal class func requestReadAccessToStepData(completion: ((didRespond: Bool, error: NSError?) -> Void)!) {
        if !HealthKitManager.isHealthDataAvailable() {
            return
        }
        
        let manager = HealthKitManager.sharedInstance
        manager.healthStore.requestAuthorizationToShareTypes(nil, readTypes: manager.healthKitReadTypes) { (success, error) -> Void in
            
            PersistentSettingsController.setBool(true, key: .DidShowActivityTrackerAuthorizationRequest)
            
            completion?(didRespond: success, error: error);
        }
    }
    
    /**
     Checks if the app currently has read-access to step data within the health store.
     
     - parameter completion: Block to execute upon completion. The block will be passed the following parameters:
     - parameter isAuthorized: Returns `true` if the app currently has read-access to step data within the health store, otherwise `false`.
     */
    internal class func checkReadAuthorizationForStepData(completion: ((isAuthorized: Bool) -> Void)!) {
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
    
    /**
     Sync step data from the device's health store with the API.
     
     - parameter syncCompletionHandler: Block to execute upon completion. The block will be passed the following parameters:
     - parameter success:               Returns `true` if the function completed without issue, otherwise `false`.
                                        __Note:__ Success does not necessarily mean data was sent to the server. For example, if the sync interval has not been reached, this function will return `true` because the function completed without issue.
     - parameter error:                 Object representing an error encountered during execution.
     */
    internal class func syncStepData(syncCompletionHandler: ((success: Bool, error: NSError?) -> Void)?) {
        if SessionData.Instance.user == nil {
            SessionData.Instance.restore()
            
            if SessionData.Instance.user == nil {
                HealthKitManager.disableBackgroundUpdates()
                syncCompletionHandler?(success: false, error: nil)
                return
            }
        }
        
        ApiUtility.requestLastStepActivitySyncDate({ (success, syncDate) in
            
            let sampleStartDate = HealthKitManager.sampleStartDate(basedOnLastSyncDate: syncDate)
            if sampleStartDate == nil {
                syncCompletionHandler?(success: true, error: nil)
                return
            }
            
            HealthKitManager.readStepData(sampleStartDate!, endDate: nil, completion: { (statistics, error) in
                
                if statistics == nil || error != nil {
                    syncCompletionHandler?(success: false, error: error)
                    return
                }
                
                let collection = HealthKitManager.stepActivityCollection(fromHealthKitStatistics: statistics!)
                if let parameters = collection?.dictionary() {
                    
                    ApiUtility.uploadStepActivities(parameters,
                        success: {
                            syncCompletionHandler?(success: true, error: nil)
                        }, failure: { (error) in
                            syncCompletionHandler?(success: false, error: error)
                    })
                    
                } else {
                    syncCompletionHandler?(success: false, error: nil)
                }
            })
        })
    }
    
    /**
     Evaluate the last sync date and determine when to start sampling data from the health store.
     
     - parameter syncDate: Date the app last synced step data with the server.
     
     - returns: Date to begin sampling data from the health store. If data should not be sampled, this value is `nil`.
     */
    private class func sampleStartDate(basedOnLastSyncDate syncDate: NSDate?) -> NSDate? {
        var sampleStartDate: NSDate? = nil
        
        if syncDate == nil {
            sampleStartDate = NSDate()
        } else {
            if NSDate().timeIntervalSinceDate(syncDate!) > self.syncInterval {
                sampleStartDate = syncDate!
            }
        }
        
        return sampleStartDate
    }
    
    /**
     Read step data from the device's health store.
     
     - parameter startDate:  Date to start sampling step data.
     - parameter endDate:    Date to end sampling step data.
     - parameter completion: Block to execute upon completion. The block will be passed the following parameters:
     - parameter statistics: Array of HKStatistics matching the input parameters.
     - parameter error:      Object representing an error encountered during execution.
     */
    private class func readStepData(startDate: NSDate, var endDate: NSDate?, completion: (statistics: [HKStatistics]?, error: NSError?) -> Void) {
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
}

internal extension HealthKitManager {
    
    /**
     Enable background delivery of HealthKit data.
     */
    internal class func enableBackgroundUpdates() {
        let manager = HealthKitManager.sharedInstance
        for sampleType in HealthKitManager.sharedInstance.healthKitReadTypes {
            HealthKitManager.sharedInstance.healthStore.enableBackgroundDeliveryForType(sampleType, frequency: .Hourly,
                withCompletion: { (success, error) in
                    
                    if success {
                        manager.healthStore.executeQuery(manager.stepObserverQuery)
                    }
            })
        }
    }
    
    /**
     Disable background delivery of HealthKit data.
     */
    internal class func disableBackgroundUpdates() {
        let manager = HealthKitManager.sharedInstance
        manager.healthStore.disableAllBackgroundDeliveryWithCompletion({ (success, error) in
            if success {
                manager.healthStore.stopQuery(manager.stepObserverQuery)
            } else {
                HealthKitManager.disableBackgroundUpdates()
            }
        })
    }
}

private extension HealthKitManager {
    
    /// Date formatter capable of outputting a date string compatible with the API.
    static let activityDateFormatter: NSDateFormatter = {
       let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    /**
     *  Internal struct to represent a step activity collection which is compatible with the API.
     */
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
    
    /**
     *  Internal struct to represent a step activity which is compatible with the API.
     */
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
    
    /**
     Constructor for a step activity object.
     
     - parameter statistic: HealthKit statistic for a step sample.
     
     - returns: Step activity if applicable, otherwise `nil`.
     */
    class func stepActivity(fromHealthKitStatistic statistic: HKStatistics) -> StepActivity? {
        if statistic.quantityType != HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)! {
            return nil;
        }
        
        let date = statistic.startDate
        var stepActivity: StepActivity? = nil
        if HealthKitManager.sharedInstance.deviceSource != nil {
            let quantity = statistic.sumQuantityForSource(HealthKitManager.sharedInstance.deviceSource!)
            if let steps = quantity?.doubleValueForUnit(HKUnit.countUnit()) {
                stepActivity = StepActivity(date: date, steps: steps)
            }
        }
        return stepActivity
    }
    
    /**
     Constructor for a step activity collection.
     
     - parameter statistics: Array of HealthKit statistics.
     
     - returns: Step activity collection if applicable, otherwise `nil`.
     */
    class func stepActivityCollection(fromHealthKitStatistics statistics: [HKStatistics]) -> StepActivityCollection? {
        if let user = SessionData.Instance.user, userId = user.userId, deviceId = HealthKitManager.sharedInstance.deviceSource?.bundleIdentifier {
            
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