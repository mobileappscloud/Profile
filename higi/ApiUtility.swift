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
                ApiUtility.retrieveDevices(success);
                ApiUtility.grabNextPulseArticles(success);
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
                if (SessionData.Instance.kioskList != nil) {
                    ApiUtility.retrieveKioskList(nil);
                    success?();
                } else {
                    ApiUtility.retrieveKioskList(success);
                }
                
            },
            failure: { operation, error in
                SessionController.Instance.checkins = [];
                if (SessionData.Instance.kioskList != nil) {
                    ApiUtility.retrieveKioskList(nil);
                    success?();
                } else {
                    ApiUtility.retrieveKioskList(success);
                }
            });
    }
    
    class func retrieveActivities(success: (() -> Void)?) {
        ApiUtility.checkForNewActivities({
            SessionController.Instance.earnditError = false;
            let userId = !HigiApi.EARNDIT_DEV ? SessionData.Instance.user.userId : "rQIpgKhmd0qObDSr5SkHbw";
            var startDateFormatter = NSDateFormatter();
            startDateFormatter.dateFormat = "yyyy-MM-01";
            var endDateFormatter = NSDateFormatter();
            endDateFormatter.dateFormat = "yyyy-MM-dd";
            var endDate = NSDate();
            var dateComponents = NSDateComponents();
            dateComponents.month = -6;
            var startDate = NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: endDate, options: NSCalendarOptions.allZeros)!;
            
            HigiApi().sendGet("\(HigiApi.earnditApiUrl)/user/\(userId)/activities?limit=0&startDate=\(startDateFormatter.stringFromDate(startDate))&endDate=\(endDateFormatter.stringFromDate(endDate))", success: {operation, responseObject in
                var activities: [HigiActivity] = [];
                var serverActivities = ((responseObject as NSDictionary)["response"] as NSDictionary)["data"] as NSArray;
                for activity: AnyObject in serverActivities {
                    activities.append(HigiActivity(dictionary: activity as NSDictionary));
                }
                SessionController.Instance.activities = activities;
                success?();
                }, failure: { operation, error in
                    SessionController.Instance.earnditError = true;
                    SessionController.Instance.activities = [];
                    success?();
            });
        });
        
    }
    
    class func checkForNewActivities(success: (() -> Void)?) {
        let userId = !HigiApi.EARNDIT_DEV ? SessionData.Instance.user.userId : "rQIpgKhmd0qObDSr5SkHbw";
        HigiApi().sendPost("\(HigiApi.earnditApiUrl)/user/\(userId)/lookForNewActivities", parameters: nil, success: {operation, responseObject in
            var i=0;    // Still won't allow optional method be the only thing in the body
            success?();
            }, failure: { operation, error in
                var i=0;
                success?();
        });
    }
    
    class func retrieveChallenges(success: (() -> Void)?) {
        SessionController.Instance.earnditError = false;
        let userId = !HigiApi.EARNDIT_DEV ? SessionData.Instance.user.userId : "rQIpgKhmd0qObDSr5SkHbw";
        HigiApi().sendGet("\(HigiApi.earnditApiUrl)/user/\(userId)/challenges?&include[gravityboard]=3&include[participants]=50" +
            "&include[comments]=50&include[teams.comments]=50", success: {operation, responseObject in
            var challenges: [HigiChallenge] = [];
            let serverChallenges = ((responseObject as NSDictionary)["response"] as NSDictionary)["data"] as NSArray;
            for challenge: AnyObject in serverChallenges {
                let serverParticipant = ((challenge as NSDictionary)["userRelation"] as NSDictionary)["participant"] as? NSDictionary;
                var participant: ChallengeParticipant!;
                if (serverParticipant != nil) {
                    participant = ChallengeParticipant(dictionary: serverParticipant!);
                }
                let serverGravityBoard = ((challenge as NSDictionary)["userRelation"] as NSDictionary)["gravityboard"] as? NSArray;
                var gravityBoard: [GravityParticipant] = [];
                if (serverGravityBoard != nil) {
                    for boardParticipant: AnyObject in serverGravityBoard! {
                        gravityBoard.append(GravityParticipant(place: (boardParticipant as NSDictionary)["position"] as? NSString, participant: ChallengeParticipant(dictionary: (boardParticipant as NSDictionary)["participant"] as NSDictionary)));
                    }
                }
                let serverParticipants = ((challenge as NSDictionary)["participants"] as NSDictionary)["data"] as? NSArray;
                var participants:[ChallengeParticipant] = [];
                if (serverParticipants != nil) {
                    for singleParticipant: AnyObject in serverParticipants! {
                        participants.append(ChallengeParticipant(dictionary: singleParticipant as NSDictionary));
                    }
                }
                let serverPagingData = (((challenge as NSDictionary)["participants"] as NSDictionary)["paging"] as NSDictionary)["nextUrl"] as? NSString;
                var pagingData = PagingData(nextUrl: serverPagingData);
                
                let serverComments = ((challenge as NSDictionary)["comments"] as NSDictionary)["data"] as? NSArray;
                var chatter:Chatter;
                var comments:[Comments] = [];
                var commentPagingData = PagingData(nextUrl: "");
                if (serverComments != nil) {
                    commentPagingData = PagingData(nextUrl: (((challenge as NSDictionary)["comments"] as NSDictionary)["paging"] as NSDictionary)["nextUrl"] as? NSString);
                    for challengeComment in serverComments! {
                        let comment = (challengeComment as NSDictionary)["comment"] as NSString;
                        let timeSinceLastPost = (challengeComment as NSDictionary)["timeSincePosted"] as NSString;
                        let commentParticipant = ChallengeParticipant(dictionary: (challengeComment as NSDictionary)["participant"] as NSDictionary);
                        let commentTeam = commentParticipant.team?;
                        comments.append(Comments(comment: comment, timeSincePosted: timeSinceLastPost, participant: commentParticipant, team: commentTeam))
                    }
                }
                chatter = Chatter(comments: comments, paging: commentPagingData);
                challenges.append(HigiChallenge(dictionary: challenge as NSDictionary, userStatus: ((challenge as NSDictionary)["userRelation"] as NSDictionary)["status"] as NSString, participant: participant, gravityBoard: gravityBoard, participants: participants, pagingData: pagingData, chatter: chatter));
            }
            
            SessionController.Instance.challenges = challenges;
            success?();
            }, failure: { operation, error in
                SessionController.Instance.earnditError = true;
                if (SessionController.Instance.challenges == nil) {
                    SessionController.Instance.challenges = [];
                }
                success?();
        });
        
    }
    
    class func retrieveDevices(success: (() -> Void)?) {
        let userId = !HigiApi.EARNDIT_DEV ? SessionData.Instance.user.userId : "rQIpgKhmd0qObDSr5SkHbw";
        SessionController.Instance.earnditError = false;
        HigiApi().sendGet("\(HigiApi.earnditApiUrl)/user/\(userId)/devices", success: {operation, responseObject in
            var devices: [String:ActivityDevice] = [:];
            var serverDevices = (responseObject as NSDictionary)["response"] as NSArray;
            for device: AnyObject in serverDevices {
                var thisDevice = ActivityDevice(dictionary: device as NSDictionary);
                devices[thisDevice.name] = thisDevice;
            }
            
            SessionController.Instance.devices = devices;
            success?();
            }, failure: { operation, error in
                SessionController.Instance.devices = [:];
                SessionController.Instance.earnditError = true;
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
                SessionData.Instance.kioskList = [];
                if (success != nil) {
                    success!();
                }

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
                
                var i = 0; //TODO remove this if possible. Causes to not build because contents are only an optional call.
                callback?();
                
        });
    }
}
