//
//  ApiUtility.swift
//  higi
//
//  Created by Dan Harms on 6/18/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation
import HealthKit

class ApiUtility {
    
    class func checkTermsAndPrivacy(viewController: UIViewController, success: (() -> Void)?, failure: (() -> Void)?) {
        HigiApi().sendGet("\(HigiApi.webUrl)/termsinfo", success: {operation, responseObject in
            var user = SessionData.Instance.user;
            var termsInfo = responseObject as NSDictionary;
            var termsFile = termsInfo["termsFilename"] as NSString;
            var privacyFile = termsInfo["privacyFilename"] as NSString;
            var newTerms = termsFile != user.termsFile;
            var newPrivacy = privacyFile != user.privacyFile;
            if (newTerms || newPrivacy) {
                var termsController = TermsViewController(nibName: "TermsView", bundle: nil);
                termsController.newTerms = newTerms;
                termsController.newPrivacy = newPrivacy;
                termsController.termsFile = termsFile;
                termsController.privacyFile = privacyFile;
                viewController.presentViewController(termsController, animated: true, completion: nil);
            } else {
                ApiUtility.retrieveCheckins(success);
                ApiUtility.retrieveActivities(success);
                ApiUtility.retrieveChallenges(success);
            }
            
            }, failure: {operation, error in
                var i = 0;
                failure?();
        });
    }
    
    class func retrieveCheckins(success: (() -> Void)?) {
        grabNextPulseArticles(nil);
        HigiApi().sendGet( "\(HigiApi.higiApiUrl)/data/user/\(SessionData.Instance.user.userId)/checkIn", success:
            { operation, responseObject in
                
                var serverCheckins = responseObject as NSArray;
                var checkins: [HigiCheckin] = [];
                var lastBpCheckin, lastBmiCheckin: HigiCheckin?;
                for checkin: AnyObject in serverCheckins {
                    if let checkinData = checkin as? NSDictionary {
                        var checkin = HigiCheckin(dictionary: checkinData);
                        checkin.prevBpCheckin = lastBpCheckin;
                        checkin.prevBmiCheckin = lastBmiCheckin;
                        if (checkin.systolic != nil) {
                            lastBpCheckin = checkin;
                        }
                        if (checkin.bmi != nil) {
                            lastBmiCheckin = checkin;
                        }
                        checkins.append(checkin);
                    }
                }
                SessionController.Instance.checkins = checkins;
                if (SessionData.Instance.kioskList.count > 0) {
                    ApiUtility.retrieveKioskList(nil);
                    success?();
                } else {
                    ApiUtility.retrieveKioskList(success);
                }
                
            },
            failure: { operation, error in
                SessionController.Instance.checkins = [];
                if (SessionData.Instance.kioskList.count > 0) {
                    ApiUtility.retrieveKioskList(nil);
                    success?();
                } else {
                    ApiUtility.retrieveKioskList(success);
                }
            });
    }
    
    class func retrieveActivities(success: (() -> Void)?) {
        var startDateFormatter = NSDateFormatter();
        startDateFormatter.dateFormat = "yyyy-MM-01";
        var endDateFormatter = NSDateFormatter();
        endDateFormatter.dateFormat = "yyyy-MM-dd";
        var endDate = NSDate();
        var dateComponents = NSDateComponents();
        dateComponents.month = -6;
        var startDate = NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: endDate, options: NSCalendarOptions.allZeros)!;
        HigiApi().sendGet("\(HigiApi.earnditApiUrl)/user/XibU2q0gN0eB5NxdflUQ0w/activities?startDate=\(startDateFormatter.stringFromDate(startDate))&endDate=\(endDateFormatter.stringFromDate(endDate))", success: {operation, responseObject in
            var activities: [HigiActivity] = [];
            var serverActivities = ((responseObject as NSDictionary)["response"] as NSDictionary)["data"] as NSArray;
            for activity: AnyObject in serverActivities {
                activities.append(HigiActivity(dictionary: activity as NSDictionary));
            }
            SessionController.Instance.activities = activities;
            success?();
            }, failure: { operation, error in
                SessionController.Instance.activities = [];
                success?();
        });    }
    
    class func retrieveChallenges(success: (() -> Void)?) {
        HigiApi().sendGet("\(HigiApi.earnditApiUrl)/user/XibU2q0gN0eB5NxdflUQ0w/challenges", success: {operation, responseObject in
            var challenges: [HigiChallenge] = [];
            var serverChallenges = ((responseObject as NSDictionary)["response"] as NSDictionary)["data"] as NSArray;
            for challenge: AnyObject in serverChallenges {
                var serverParticipant = (challenge as NSDictionary)["participant"] as? NSDictionary;
                var participant: ChallengeParticipant!;
                if (serverParticipant != nil) {
                    participant = ChallengeParticipant(dictionary: serverParticipant!);
                }
                challenges.append(HigiChallenge(dictionary: (challenge as NSDictionary)["challenge"] as NSDictionary, userStatus: (challenge as NSDictionary)["status"] as NSString, participant: participant));
            }
            
            SessionController.Instance.challenges = challenges;
            success?();
            }, failure: { operation, error in
                SessionController.Instance.challenges = [];
                success?();
        });
        
    }
    
    class func retrieveKioskList(success: (() -> Void)?) {
        
        HigiApi().sendGet("\(HigiApi.higiApiUrl)/data/KioskList", success:
            { operation, responseObject in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    
                    
                    var serverKiosks = responseObject as NSArray;
                    var kiosks: [KioskInfo] = [];
                    for kiosk: AnyObject in serverKiosks {
                        if let kioskData = kiosk as? NSDictionary {
                            var newKiosk = KioskInfo(dictionary: kioskData);
                            if (newKiosk.position != nil) {
                                if (newKiosk.isMapVisible) {
                                    kiosks.append(newKiosk);
                                } else {
                                    for checkin in SessionController.Instance.checkins {
                                        if (checkin.kioskInfo != nil && newKiosk.kioskId == checkin.kioskInfo!.kioskId) {
                                            kiosks.append(newKiosk);
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    SessionData.Instance.kioskList = kiosks;
                    dispatch_async(dispatch_get_main_queue(), {
                        if (success != nil) {
                            success!();
                        }
                    });
                });
                
            },
            failure: { operation, error in
                
        });
    }
    
    class func updateHealthKit() {
        if (UIDevice.currentDevice().systemVersion >= "8.0" && HKHealthStore.isHealthDataAvailable()) {
            if (SessionController.Instance.healthStore == nil) {
                SessionController.Instance.healthStore = HKHealthStore();
            }
            var healthStore = SessionController.Instance.healthStore;
            healthStore.requestAuthorizationToShareTypes(ApiUtility.dataTypesToWrite(), readTypes: ApiUtility.dataTypesToRead(), completion: { success, error in
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        var startDate = NSDate.distantPast() as NSDate;
                        
                        healthStore.executeQuery(HKSampleQuery(sampleType: HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass), predicate: HKQuery.predicateForObjectsFromSource(HKSource.defaultSource()), limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil, resultsHandler: {query, results, error in
                            
                            if (results != nil && (results as [HKSample]).count > 0) {
                                var dataResults: [HKSample] = results as [HKSample];
                                startDate = dataResults.last!.startDate;
                            }
                            
                            healthStore.executeQuery(HKSampleQuery(sampleType: HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate), predicate: HKQuery.predicateForObjectsFromSource(HKSource.defaultSource()), limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil, resultsHandler: {query, results, error in
                                
                                if (results != nil && (results as [HKSample]).count > 0) {
                                    var dataResults: [HKSample] = results as [HKSample];
                                    if (startDate.compare(dataResults.last!.startDate) == .OrderedAscending) {
                                        startDate = dataResults.last!.startDate;
                                    }
                                }
                                
                                healthStore.executeQuery(HKSampleQuery(sampleType: HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex), predicate: HKQuery.predicateForObjectsFromSource(HKSource.defaultSource()), limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil, resultsHandler: {query, results, error in
                                    
                                    if (results != nil && (results as [HKSample]).count > 0) {
                                        var dataResults: [HKSample] = results as [HKSample];
                                        if (startDate.compare(dataResults.last!.startDate) == .OrderedAscending) {
                                            startDate = dataResults.last!.startDate;
                                        }
                                    }
                                    
                                    healthStore.executeQuery(HKSampleQuery(sampleType: HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureSystolic), predicate: HKQuery.predicateForObjectsFromSource(HKSource.defaultSource()), limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil, resultsHandler: {query, results, error in
                                        
                                        if (results != nil && (results as [HKSample]).count > 0) {
                                            var dataResults: [HKSample] = results as [HKSample];
                                            if (startDate.compare(dataResults.last!.startDate) == .OrderedAscending) {
                                                startDate = dataResults.last!.startDate;
                                            }
                                        }
                                        
                                        ApiUtility.saveData(startDate);
                                        
                                    }));
                                    
                                    
                                }));
                                
                                
                            }));
                            
                        }));
                        
                        
                    });
                }
            });
        }
    }
    
    class func saveData(startDate: NSDate) {
        
        var bpSamples: [HKSample] = [];
        var pulseSamples: [HKSample] = [];
        var bmiSamples: [HKSample] = [];
        var weightSamples: [HKSample] = [];
        
        for checkin: HigiCheckin in SessionController.Instance.checkins {
            if (checkin.dateTime.compare(startDate) != .OrderedDescending) {
                continue;
            }
            if (checkin.systolic != nil) {
                var systolic = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureSystolic), quantity: HKQuantity(unit: HKUnit.millimeterOfMercuryUnit(), doubleValue: Double(checkin.systolic!)), startDate: checkin.dateTime, endDate: checkin.dateTime);
                var diastolic = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureDiastolic), quantity: HKQuantity(unit: HKUnit.millimeterOfMercuryUnit(), doubleValue: Double(checkin.diastolic!)), startDate: checkin.dateTime, endDate: checkin.dateTime);
                var bpSet = NSSet(objects: systolic, diastolic);
                bpSamples.append(HKCorrelation(type: HKObjectType.correlationTypeForIdentifier(HKCorrelationTypeIdentifierBloodPressure), startDate: checkin.dateTime, endDate: checkin.dateTime, objects: bpSet));
                pulseSamples.append(HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate), quantity: HKQuantity(unit: HKUnit.countUnit().unitDividedByUnit(HKUnit.minuteUnit()), doubleValue: Double(checkin.pulseBpm!)), startDate: checkin.dateTime, endDate: checkin.dateTime));
            }
            
            if (checkin.bmi != nil) {
                weightSamples.append(HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass), quantity: HKQuantity(unit: HKUnit.poundUnit(), doubleValue: checkin.weightLbs!), startDate: checkin.dateTime, endDate: checkin.dateTime));
                bmiSamples.append(HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex), quantity: HKQuantity(unit: HKUnit(fromString: ""), doubleValue: checkin.bmi!), startDate: checkin.dateTime, endDate: checkin.dateTime));
            }
        }
        
        var healthStore = SessionController.Instance.healthStore;
        healthStore.saveObjects(bpSamples, withCompletion: nil);
        healthStore.saveObjects(pulseSamples, withCompletion: nil);
        healthStore.saveObjects(weightSamples, withCompletion: nil);
        healthStore.saveObjects(bmiSamples, withCompletion: nil);
    }
    
    class func dataTypesToWrite() -> NSSet {
        return NSSet(array: [
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureSystolic),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureDiastolic),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)]);
    }
    
    class func dataTypesToRead() -> NSSet {
        return NSSet(array: []);
    }
    
    class func grabNextPulseArticles(callback: (() -> Void)?) {
        var paged = Int(SessionController.Instance.pulseArticles.count / 15) + 1;
        var url = "\(HigiApi.webUrl)/pulse/?feed=json&posts_per_rss=15&paged=\(paged)";
        HigiApi().sendGet(url, success: { operation, responseObject in
            
            var serverArticles = (responseObject as NSDictionary)["posts"] as NSArray;
            var articles: [PulseArticle] = [];
            for articleData: AnyObject in serverArticles {
                articles.append(PulseArticle(dictionary: articleData as NSDictionary));
            }
            
            SessionController.Instance.pulseArticles += articles;
            
            callback?();
            
            }, failure: {operation, error in
                
                var i = 0; //TODO remove this if possible
                callback?();
                
        });
    }
}
