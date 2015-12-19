import Foundation
import HealthKit

class ApiUtility {
    
    // Notificiation names
    
    class var QR_CHECKIN: String {
        return "qrCheckin";
    }
    
    class var ACTIVITIES: String {
        return "activitiesLoaded";
    }
    
    class var CHALLENGES: String {
        return "challengesLoaded";
    }
    
    class var CHECKINS: String {
        return "checkinsLoaded";
    }
    
    class var DEVICES: String {
        return "devicesLoaded";
    }
    
    class var PULSE: String {
        return "pulseArticlesLoaded";
    }
    
    class var KIOSKS: String {
        return "kiosksLoaded";
    }
    
    class var PROFILE_PICTURES: String {
        return "profilePicturesLoaded";
    }
    
    
    
    class func checkTermsAndPrivacy(viewController: UIViewController, success: ((terms: NSString, privacy: NSString) -> Void)?, failure: (() -> Void)?) {
        HigiApi().sendGet("\(HigiApi.webUrl)/termsinfo",
            success: {operation, responseObject in
                let termsInfo = responseObject as! NSDictionary;
                let termsFile = termsInfo["termsFilename"] as! NSString;
                let privacyFile = termsInfo["privacyFilename"] as! NSString;
                success?(terms: termsFile, privacy: privacyFile)
                
            }, failure: {operation, error in
                failure?();
        });
    }
    
    class func initializeApiData() {
        SessionController.Instance.earnditError = false;
        ApiUtility.retrieveCheckins(nil);
        ApiUtility.retrieveActivities(nil);
        ApiUtility.retrieveChallenges(nil);
        ApiUtility.retrieveDevices(nil);
        ApiUtility.grabNextPulseArticles(nil);
    }
    
    class func retrieveCheckins(success: (() -> Void)?) {
        grabNextPulseArticles(nil);
        HigiApi().sendGet( "\(HigiApi.higiApiUrl)/data/user/\(SessionData.Instance.user.userId)/checkIn", success:
            { operation, responseObject in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    let serverCheckins = responseObject as! NSArray;
                    var checkins: [HigiCheckin] = [];
                    var lastBpCheckin, lastBmiCheckin: HigiCheckin?;
                    for checkin: AnyObject in serverCheckins {
                        if let checkinData = checkin as? NSDictionary {
                            let checkin = HigiCheckin(dictionary: checkinData);
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
                    dispatch_async(dispatch_get_main_queue(), {
                        NSNotificationCenter.defaultCenter().postNotificationName(ApiUtility.CHECKINS, object: nil, userInfo: ["success": true]);
                    });
                    ApiUtility.retrieveKioskList(success);
                    
                });
                
            },
            failure: { operation, error in
                NSNotificationCenter.defaultCenter().postNotificationName(ApiUtility.CHECKINS, object: nil, userInfo: ["success": false]);
                if (SessionController.Instance.checkins == nil) {
                    SessionController.Instance.checkins = [];
                }
                if (SessionController.Instance.kioskList != nil) {
                    ApiUtility.retrieveKioskList(nil);
                    success?();
                } else {
                    ApiUtility.retrieveKioskList(success);
                }
        });
    }
    
    class func requestLastStepActivitySyncDate(completion: (success: Bool, syncDate: NSDate?) -> Void) {

        let userId = SessionData.Instance.user.userId;
        let URLString = "\(HigiApi.earnditApiUrl)/user/\(userId)/activities?device=higi&type=step&limit=1"
        
        HigiApi().sendGet(URLString, success: {operation, responseObject in
            
            let serverActivities = ((responseObject as! NSDictionary)["response"] as! NSDictionary)["data"] as! NSArray;
            var activity: HigiActivity? = nil
            for serverActivity: AnyObject in serverActivities {
                activity = HigiActivity(dictionary: serverActivity as! NSDictionary);
                break;
            }
            
            var syncDate: NSDate? = nil
            if let UTCDate = activity?.updateDate {
                let offset: NSTimeInterval = Double(NSTimeZone.localTimeZone().secondsFromGMTForDate(UTCDate))
                syncDate = UTCDate.dateByAddingTimeInterval(offset)
            }
            
            completion(success: true, syncDate: syncDate)
            
            }, failure: { operation, error in
                completion(success: false, syncDate: nil)
        })
    }
    
    class func uploadStepActivities(activities: NSDictionary, success: (() -> Void)?, failure: ((error: NSError?) -> Void)?) {
        let URLString = "\(HigiApi.earnditApiUrl)/higiStep"
        HigiApi().sendPost(URLString, parameters: activities, success: { (operation, responseObject) in
            
//            NSNotificationCenter.defaultCenter().postNotificationName(ApiUtility.ACTIVITIES, object: nil, userInfo: ["success": false]);
            self.retrieveActivities(success)
//            success?()
            
            }, failure: { (operation, error) in
                failure?(error: error)
        })
    }
    
    class func retrieveActivities(success: (() -> Void)?) {
        if SessionData.Instance.user == nil {
            success?();
        }
        
        SessionData.Instance.lastUpdate = NSDate();
        let userId = SessionData.Instance.user.userId;
        ApiUtility.checkForNewActivities({
            let startDateFormatter = NSDateFormatter();
            startDateFormatter.dateFormat = "yyyy-MM-01";
            let endDateFormatter = NSDateFormatter();
            endDateFormatter.dateFormat = "yyyy-MM-dd";
            let endDate = NSDate();
            let dateComponents = NSDateComponents();
            dateComponents.month = -6;
            let startDate = NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: endDate, options: NSCalendarOptions())!;
            
            HigiApi().sendGet("\(HigiApi.earnditApiUrl)/user/\(userId)/activities?limit=0&startDate=\(startDateFormatter.stringFromDate(startDate))&endDate=\(endDateFormatter.stringFromDate(endDate))", success: {operation, responseObject in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var activities: [String: (Int, [HigiActivity])] = [:];
                    let serverActivities = ((responseObject as! NSDictionary)["response"] as! NSDictionary)["data"] as! NSArray;
                    for serverActivity: AnyObject in serverActivities {
                        let activity = HigiActivity(dictionary: serverActivity as! NSDictionary);
                        let dateString = Constants.dateFormatter.stringFromDate(activity.startTime);
                        if var (total, processedActivities) = activities[dateString] {
                            let points = activity.errorDescription == nil ? activity.points + total : total;
                            processedActivities.append(activity);
                            activities[dateString] = (points, processedActivities);
                        } else {
                            let points = activity.errorDescription == nil ? activity.points : 0;
                            let processedActivities = [activity];
                            activities[dateString] = (points, processedActivities);
                        }
                    }
                    
                    SessionController.Instance.activities = activities;
                    dispatch_async(dispatch_get_main_queue(), {
                        NSNotificationCenter.defaultCenter().postNotificationName(ApiUtility.ACTIVITIES, object: nil, userInfo: ["success": true]);
                        success?();
                    });
                    SessionController.Instance.loadedActivities = true;
                });
                }, failure: { operation, error in
                    SessionController.Instance.earnditError = true;
                    NSNotificationCenter.defaultCenter().postNotificationName(ApiUtility.ACTIVITIES, object: nil, userInfo: ["success": false]);
                    SessionController.Instance.activities = [:];
                    SessionController.Instance.loadedActivities = true;
                    success?();
            });
        });
        
    }
    
    class func checkForNewActivities(success: (() -> Void)?) {
        let userId = SessionData.Instance.user.userId;
        HigiApi().sendPost("\(HigiApi.earnditApiUrl)/user/\(userId)/lookForNewActivities", parameters: nil, success: {operation, responseObject in
            success?();
            }, failure: { operation, error in
                success?();
        });
    }
    
    class func retrieveChallenges(success: (() -> Void)?) {
        let userId = SessionData.Instance.user.userId;
        HigiApi().sendGet("\(HigiApi.earnditApiUrl)/user/\(userId)/challenges?&include[gravityboard]=3&include[participants]=50&include[comments]=50&include[teams.comments]=50", success: {operation, responseObject in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var challenges: [HigiChallenge] = [];
                    let serverChallenges = ((responseObject as! NSDictionary)["response"] as! NSDictionary)["data"] as! NSArray;
                    for challenge: AnyObject in serverChallenges {
                        let serverParticipant = ((challenge as! NSDictionary)["userRelation"] as! NSDictionary)["participant"] as? NSDictionary;
                        var participant: ChallengeParticipant!;
                        if (serverParticipant != nil) {
                            participant = ChallengeParticipant(dictionary: serverParticipant!);
                        }
                        let serverGravityBoard = ((challenge as! NSDictionary)["userRelation"] as! NSDictionary)["gravityboard"] as? NSArray;
                        var gravityBoard: [GravityParticipant] = [];
                        if (serverGravityBoard != nil) {
                            for boardParticipant: AnyObject in serverGravityBoard! {
                                gravityBoard.append(GravityParticipant(place: (boardParticipant as! NSDictionary)["position"] as? NSString, participant: ChallengeParticipant(dictionary: (boardParticipant as! NSDictionary)["participant"] as! NSDictionary)));
                            }
                        }
                        let serverParticipants = ((challenge as! NSDictionary)["participants"] as! NSDictionary)["data"] as? NSArray;
                        var participants:[ChallengeParticipant] = [];
                        if (serverParticipants != nil) {
                            for singleParticipant: AnyObject in serverParticipants! {
                                participants.append(ChallengeParticipant(dictionary: singleParticipant as! NSDictionary));
                            }
                        }
                        let serverPagingData = (((challenge as! NSDictionary)["participants"] as! NSDictionary)["paging"] as! NSDictionary)["nextUrl"] as? NSString;
                        let pagingData = PagingData(nextUrl: serverPagingData);
                        
                        let serverComments = ((challenge as! NSDictionary)["comments"] as! NSDictionary)["data"] as? NSArray;
                        var chatter:Chatter;
                        var comments:[Comments] = [];
                        var commentPagingData = PagingData(nextUrl: "");
                        if (serverComments != nil) {
                            commentPagingData = PagingData(nextUrl: (((challenge as! NSDictionary)["comments"] as! NSDictionary)["paging"] as! NSDictionary)["nextUrl"] as? NSString);
                            for challengeComment in serverComments! {
                                let comment = (challengeComment as! NSDictionary)["comment"] as! NSString;
                                let timeSinceLastPost = (challengeComment as! NSDictionary)["timeSincePosted"] as! NSString;
                                let commentParticipant = ChallengeParticipant(dictionary: (challengeComment as! NSDictionary)["participant"] as! NSDictionary);
                                let commentTeam = commentParticipant.team;
                                comments.append(Comments(comment: comment, timeSincePosted: timeSinceLastPost, participant: commentParticipant, team: commentTeam))
                            }
                        }
                        chatter = Chatter(comments: comments, paging: commentPagingData);
                        challenges.append(HigiChallenge(dictionary: challenge as! NSDictionary, userStatus: ((challenge as! NSDictionary)["userRelation"] as! NSDictionary)["status"] as! NSString, participant: participant, gravityBoard: gravityBoard, participants: participants, pagingData: pagingData, chatter: chatter));
                    }
                    
                    SessionController.Instance.challenges = challenges;
                    dispatch_async(dispatch_get_main_queue(), {
                        NSNotificationCenter.defaultCenter().postNotificationName(ApiUtility.CHALLENGES, object: nil, userInfo: ["success": true]);
                        success?();
                    });
                });
            }, failure: { operation, error in
                SessionController.Instance.earnditError = true;
                if (SessionController.Instance.challenges == nil) {
                    SessionController.Instance.challenges = [];
                }
                NSNotificationCenter.defaultCenter().postNotificationName(ApiUtility.CHALLENGES, object: nil, userInfo: ["success": false]);
                success?();
        });
        
    }
    
    class func retrieveDevices(success: (() -> Void)?) {
        let userId = SessionData.Instance.user.userId;
        HigiApi().sendGet("\(HigiApi.earnditApiUrl)/user/\(userId)/devices", success: {operation, responseObject in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var devices: [String:ActivityDevice] = [:];
                let serverDevices = (responseObject as! NSDictionary)["response"] as! NSArray;
                for device: AnyObject in serverDevices {
                    let thisDevice = ActivityDevice(dictionary: device as! NSDictionary);
                    devices[thisDevice.name as String] = thisDevice;
                }
                
                SessionController.Instance.devices = devices;
                dispatch_async(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotificationName(ApiUtility.DEVICES, object: nil, userInfo: ["success": true]);
                    success?();
                });
            });
            }, failure: { operation, error in
                SessionController.Instance.earnditError = true;
                NSNotificationCenter.defaultCenter().postNotificationName(ApiUtility.DEVICES, object: nil, userInfo: ["success": false]);
                success?();
        });
        
    }
    
    class func retrieveKioskList(success: (() -> Void)?) {
        if (SessionData.Instance.kioskListString != "") {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                SessionController.Instance.kioskList = ApiUtility.deserializeKiosks(SessionData.Instance.kioskListString);
                
                HigiApi().sendGet("\(HigiApi.higiApiUrl)/data/KioskList", success:
                    { operation, responseObject in
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                            
                            let responseString = ApiUtility.jsonStringify(responseObject);
                            SessionData.Instance.kioskListString = responseString;
                            SessionData.Instance.save();
                            SessionController.Instance.kioskList = ApiUtility.deserializeKiosks(responseString);
                        });
                        
                    }, failure: nil);
                dispatch_async(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotificationName(ApiUtility.KIOSKS, object: nil, userInfo: ["success": true]);
                    success?();
                });
            });
        } else {
            HigiApi().sendGet("\(HigiApi.higiApiUrl)/data/KioskList", success:
                { operation, responseObject in
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        
                        SessionData.Instance.kioskListString = ApiUtility.jsonStringify(responseObject);
                        SessionData.Instance.save();
                        SessionController.Instance.kioskList = ApiUtility.deserializeKiosks(SessionData.Instance.kioskListString);
                        dispatch_async(dispatch_get_main_queue(), {
                            NSNotificationCenter.defaultCenter().postNotificationName(ApiUtility.KIOSKS, object: nil, userInfo: ["success": true]);
                            success?();
                        });
                    });
                    
                },
                failure: { operation, error in
                    if (SessionController.Instance.kioskList == nil) {
                            SessionController.Instance.kioskList = [];
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName(ApiUtility.KIOSKS, object: nil, userInfo: ["success": false]);
                    success?();
                    
            });
        }
    }
    
    class func jsonStringify(value: AnyObject) -> String {
        if NSJSONSerialization.isValidJSONObject(value) {
            if let data = try? NSJSONSerialization.dataWithJSONObject(value, options: []) {
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    return string as String;
                }
            }
        }
        return "";
    }
    
    class func deserializeKiosks(response: String) -> [KioskInfo] {
        let jsonData = response.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false);
        let serverKiosks = (try! NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers)) as! NSArray;
        var kiosks: [KioskInfo] = [];
        for kiosk: AnyObject in serverKiosks {
            if let kioskData = kiosk as? NSDictionary {
                let newKiosk = KioskInfo(dictionary: kioskData);
                if (newKiosk.position != nil) {
                    if (newKiosk.isMapVisible) {
                        kiosks.append(newKiosk);
                    } else {
                        if let checkins = SessionController.Instance.checkins {
                            for checkin in checkins {
                                if (checkin.kioskInfo != nil && newKiosk.kioskId == checkin.kioskInfo!.kioskId) {
                                    kiosks.append(newKiosk);
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
        return kiosks;
    }

    /*
    class func updateHealthKit() {
        if (UIDevice.currentDevice().systemVersion >= "8.0" && HKHealthStore.isHealthDataAvailable()) {
            if (SessionController.Instance.healthStore == nil) {
                SessionController.Instance.healthStore = HKHealthStore();
            }
            var healthStore = SessionController.Instance.healthStore;
            healthStore.requestAuthorizationToShareTypes((ApiUtility.dataTypesToWrite() as! Set<HKSampleType>), readTypes: (ApiUtility.dataTypesToRead() as! Set<HKObjectType>), completion: { success, error in
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        var startDate = NSDate.distantPast();
                        
                        healthStore.executeQuery(HKSampleQuery(sampleType: HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!, predicate: HKQuery.predicateForObjectsFromSource(HKSource.defaultSource()), limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil, resultsHandler: {query, results, error in
                            
                            if (results != nil && (results as! [HKSample]).count > 0) {
                                var dataResults: [HKSample] = results as! [HKSample];
                                startDate = dataResults.last!.startDate;
                            }
                            
                            healthStore.executeQuery(HKSampleQuery(sampleType: HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!, predicate: HKQuery.predicateForObjectsFromSource(HKSource.defaultSource()), limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil, resultsHandler: {query, results, error in
                                
                                if (results != nil && (results as! [HKSample]).count > 0) {
                                    var dataResults: [HKSample] = results as! [HKSample];
                                    if (startDate.compare(dataResults.last!.startDate) == .OrderedAscending) {
                                        startDate = dataResults.last!.startDate;
                                    }
                                }
                                
                                healthStore.executeQuery(HKSampleQuery(sampleType: HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex), predicate: HKQuery.predicateForObjectsFromSource(HKSource.defaultSource()), limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil, resultsHandler: {query, results, error in
                                    
                                    if (results != nil && (results as! [HKSample]).count > 0) {
                                        var dataResults: [HKSample] = results as! [HKSample];
                                        if (startDate.compare(dataResults.last!.startDate) == .OrderedAscending) {
                                            startDate = dataResults.last!.startDate;
                                        }
                                    }
                                    
                                    healthStore.executeQuery(HKSampleQuery(sampleType: HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureSystolic), predicate: HKQuery.predicateForObjectsFromSource(HKSource.defaultSource()), limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil, resultsHandler: {query, results, error in
                                        
                                        if (results != nil && (results as! [HKSample]).count > 0) {
                                            var dataResults: [HKSample] = results as! [HKSample];
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
    */
    
//    class func saveData(startDate: NSDate) {
//        
//        var bpSamples: [HKSample] = [];
//        var pulseSamples: [HKSample] = [];
//        var bmiSamples: [HKSample] = [];
//        var weightSamples: [HKSample] = [];
//        
//        for checkin: HigiCheckin in SessionController.Instance.checkins {
//            if (checkin.dateTime.compare(startDate) != .OrderedDescending) {
//                continue;
//            }
//            if (checkin.systolic != nil) {
//                let systolic = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureSystolic)!, quantity: HKQuantity(unit: HKUnit.millimeterOfMercuryUnit(), doubleValue: Double(checkin.systolic!)), startDate: checkin.dateTime, endDate: checkin.dateTime);
//                let diastolic = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureDiastolic)!, quantity: HKQuantity(unit: HKUnit.millimeterOfMercuryUnit(), doubleValue: Double(checkin.diastolic!)), startDate: checkin.dateTime, endDate: checkin.dateTime);
//                let bpSet = NSSet(objects: systolic, diastolic);
//                bpSamples.append(HKCorrelation(type: HKObjectType.correlationTypeForIdentifier(HKCorrelationTypeIdentifierBloodPressure)!,
//                    startDate: checkin.dateTime, endDate: checkin.dateTime, objects: bpSet as! Set<HKSample>));
//                pulseSamples.append(HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!, quantity: HKQuantity(unit: HKUnit.countUnit().unitDividedByUnit(HKUnit.minuteUnit()), doubleValue: Double(checkin.pulseBpm!)), startDate: checkin.dateTime, endDate: checkin.dateTime));
//            }
//            
//            if (checkin.bmi != nil) {
//                weightSamples.append(HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!, quantity: HKQuantity(unit: HKUnit.poundUnit(), doubleValue: checkin.weightLbs!), startDate: checkin.dateTime, endDate: checkin.dateTime));
//                bmiSamples.append(HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)!, quantity: HKQuantity(unit: HKUnit(fromString: ""), doubleValue: checkin.bmi!), startDate: checkin.dateTime, endDate: checkin.dateTime));
//            }
//        }
//        
//        let healthStore = SessionController.Instance.healthStore;
//        healthStore.saveObjects(bpSamples, withCompletion: {(completed, error) in });
//        healthStore.saveObjects(pulseSamples, withCompletion: {(completed, error) in });
//        healthStore.saveObjects(weightSamples, withCompletion: {(completed, error) in });
//        healthStore.saveObjects(bmiSamples, withCompletion: {(completed, error) in });
//    }
    
//    class func dataTypesToWrite() -> NSSet {
//        return NSSet(array: [
//            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureSystolic),
//            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureDiastolic),
//            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate),
//            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex),
//            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)]);
//    }
    
    class func dataTypesToRead() -> NSSet {
        return NSSet(array: []);
    }
    
    class func grabNextPulseArticles(callback: (() -> Void)?) {
        let paged = Int(SessionController.Instance.pulseArticles.count / 15) + 1;
        let url = "\(HigiApi.webUrl)/pulse/?feed=json&posts_per_rss=15&paged=\(paged)";
        HigiApi().sendGet(url, success: { operation, responseObject in
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let serverArticles = (responseObject as! NSDictionary)["posts"] as! NSArray;
                var articles: [PulseArticle] = [];
                for articleData: AnyObject in serverArticles {
                    articles.append(PulseArticle(dictionary: articleData as! NSDictionary));
                }
                
                SessionController.Instance.pulseArticles += articles;
                dispatch_async(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotificationName(ApiUtility.PULSE, object: nil, userInfo: ["success": true]);
                    callback?();
                });
            });
            
            }, failure: {operation, error in
                NSNotificationCenter.defaultCenter().postNotificationName(ApiUtility.PULSE, object: nil, userInfo: ["success": false]);
                callback?();
                
        });
    }
}
