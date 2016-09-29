import Foundation
import HealthKit

final class ApiUtility {
    
    // Notificiation names
    
    class var QR_CHECKIN: String {
        return "qrCheckin";
    }
    
    class var DEVICES: String {
        return "devicesLoaded";
    }
    
    class func initializeApiData() {
        SessionController.Instance.earnditError = false;
        ApiUtility.retrieveDevices(nil);
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
            success?()
            
            }, failure: { (operation, error) in
                failure?(error: error)
        })
    }
    
    class func retrieveDevices(success: (() -> Void)?) {
        let userId = SessionData.Instance.user.userId;
        HigiApi().sendGet("\(HigiApi.earnditApiUrl)/user/\(userId)/devices", success: {operation, responseObject in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var devices: [String:ActivityDevice] = [:];
                let serverDevices = (responseObject as! NSDictionary)["response"] as! NSArray;
                for device: AnyObject in serverDevices {
                    let thisDevice = ActivityDevice(dictionary: device as! NSDictionary);
                    devices[thisDevice!.name as String] = thisDevice;
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
