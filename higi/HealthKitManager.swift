//
//  HealthKitManager.swift
//  higi
//
//  Created by Remy Panicker on 11/9/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import HealthKit

public class HealthKitManager {
    
    private static let sharedInstance = HealthKitManager()
    
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
    public class func shouldRequestAuthorization() -> Bool {
        return !PersistentSettingsController.boolForKey(.DidShowActivityTrackerAuthorizationRequest)
    }
    
    public class func requestReadAccessToStepData(completion: ((didRespond: Bool, error: NSError?) -> Void)!) {
        if !HealthKitManager.isHealthDataAvailable() {
            return
        }
        
        let manager = HealthKitManager.sharedInstance
        manager.healthStore.requestAuthorizationToShareTypes(nil, readTypes: manager.healthKitReadTypes) { (success, error) -> Void in
            
            PersistentSettingsController.setBool(true, key: .DidShowActivityTrackerAuthorizationRequest)
            
            completion?(didRespond: success, error: error);
        }
    }
    
    private func currentSource(completion: (source: HKSource?) -> Void) {
        let sampleType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!
        let query = HKSourceQuery(sampleType: sampleType, samplePredicate: nil, completionHandler: { (query, sources, error) in
            var healthKitSource: HKSource? = nil
            for source in sources! {
                if source.bundleIdentifier.hasPrefix("com.apple.health") {
                    healthKitSource = source
                }
                break;
            }
            completion(source: healthKitSource)
        })
        HealthKitManager.sharedInstance.healthStore.executeQuery(query)
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
    
    public class func readStepData(startDate: NSDate, var endDate: NSDate?, limit: Int?, completion: (samples: [HKSample]?, error: NSError?) -> Void) {
        if endDate == nil {
            endDate = NSDate()
        }
        
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!
        
        let calendar = NSCalendar.currentCalendar()
        let modifiedStartDate = calendar.startOfDayForDate(startDate)
        let modifiedEndDate = calendar.dateBySettingHour(23, minute: 59, second: 59, ofDate: endDate!, options: NSCalendarOptions())
        
        let interval = NSDateComponents()
        interval.day = 1
        
        let statCollectionQuery = HKStatisticsCollectionQuery(quantityType: sampleType, quantitySamplePredicate: nil, options: [.SeparateBySource, .CumulativeSum], anchorDate: modifiedStartDate, intervalComponents: interval)
        statCollectionQuery.initialResultsHandler = {
            query, results, error in
            
            results!.enumerateStatisticsFromDate(modifiedStartDate, toDate: modifiedEndDate!) {
                statistics, stop in
                
                for source in statistics.sources! {
                    if source.bundleIdentifier.hasPrefix("com.apple.health") {
                        print(statistics.startDate)
                        print(statistics.sumQuantityForSource(source))
                        print(statistics.endDate)
                    }
                }
            }
    
        }
        HealthKitManager.sharedInstance.healthStore.executeQuery(statCollectionQuery)
    }
    
    
}