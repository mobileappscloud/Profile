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
    
    class var CHECKINS: String {
        return "checkinsLoaded";
    }
    
    class var DEVICES: String {
        return "devicesLoaded";
    }
    
    class func initializeApiData() {
        SessionController.Instance.earnditError = false;
        ApiUtility.retrieveCheckins(nil);
        ApiUtility.retrieveActivities(nil);
        ApiUtility.retrieveDevices(nil);
    }
    
    class func retrieveCheckins(success: (() -> Void)?) {
        guard let user = SessionData.Instance.user, let userId = user.userId else {
            success?()
            return
        }
        
        HigiApi().sendGet( "\(HigiApi.higiApiUrl)/data/user/\(userId)/checkIn", success:
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
                });
                
            },
            failure: { operation, error in
                NSNotificationCenter.defaultCenter().postNotificationName(ApiUtility.CHECKINS, object: nil, userInfo: ["success": false]);
                if (SessionController.Instance.checkins == nil) {
                    SessionController.Instance.checkins = [];
                }
        });
    }
    
    class func requestLastStepActivitySyncDate(completion: (success: Bool, syncDate: NSDate?) -> Void) {

        guard let user = SessionData.Instance.user, let userId = user.userId else {
            completion(success: false, syncDate: nil)
            return
        }
        
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
        guard let user = SessionData.Instance.user, let userId = user.userId else {
            success?()
            return
        }
        
        SessionData.Instance.lastUpdate = NSDate();

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
                    var activities: [String: HigiActivitySummary] = [:];
                    let serverActivities = ((responseObject as! NSDictionary)["response"] as! NSDictionary)["data"] as! NSArray;
                    for serverActivity: AnyObject in serverActivities {
                        let activity = HigiActivity(dictionary: serverActivity as! NSDictionary);
                        let dateString = NSDateFormatter.activityDateFormatter.stringFromDate(activity.startTime);
                        if var activitySummary = activities[dateString] {
                            let points = activity.errorDescription == nil ? activity.points + activitySummary.totalPoints : activitySummary.totalPoints;
                            activitySummary.activities.append(activity);
                            activities[dateString] = (points, activitySummary.activities);
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
}

extension ApiUtility {
    
    class func fetchTemporarySessionToken(userId: String, completion: (token: String?, error: NSError?) -> Void) {
        let URLString = "\(HigiApi.higiApiUrl)/login/token?higiId=\(userId)"
        HigiApi().sendGet(URLString, success: { (operation, responseObject) in
            guard let responseDict = responseObject as? NSDictionary else {
                let parseError = NSError(domain: NSStringFromClass(self), code: 99999, userInfo: [NSLocalizedDescriptionKey : "Error parsing response object."])
                completion(token: nil, error: parseError)
                return
            }
            
            if let token = responseDict["Token"] as? String {
                completion(token: token, error: nil)
            } else {
                let missingToken = NSError(domain: NSStringFromClass(self), code: 99998, userInfo: [NSLocalizedDescriptionKey : "Token missing from response object."])
                completion(token: nil, error: missingToken)
            }
            }, failure: { operation, error in
                completion(token: nil, error: error)
        })
    }
}
