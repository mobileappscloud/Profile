import Foundation

class LocationDelegate: NSObject, CLLocationManagerDelegate {
    
    private final var MAX_DISTANCE: Double = 200;
    
    private var lastKiosk: KioskInfo?;
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            if (SessionController.Instance.kioskList == nil) {
                if (!SessionData.Instance.kioskListString.isEmpty) {
                    SessionController.Instance.kioskList = ApiUtility.deserializeKiosks(SessionData.Instance.kioskListString);
                    self.findClosestLocation(newLocation);
                }
            } else {
                self.findClosestLocation(newLocation);
            }
        });
    }
    
    func findClosestLocation(location: CLLocation!) {
        if (location != nil) {
            if (lastKiosk != nil) {
                if (location.distanceFromLocation((lastKiosk?.location!)!) < MAX_DISTANCE) {
                    // Still near previously displayed kiosk so do nothing
                    return;
                } else {
                    lastKiosk = nil;
                    clearNotification();
                }
            }
            for kiosk in SessionController.Instance.kioskList {
                if (kiosk.isMapVisible && kiosk.status == "Deployed" && location.distanceFromLocation(kiosk.location!) < MAX_DISTANCE) {
                    if (lastKiosk == nil || lastKiosk != kiosk) {
                        lastKiosk = kiosk;
                        showLocalNotification(kiosk);
                    }
                    return;
                }
            }
            lastKiosk = nil;
            clearNotification();
        }
    }
    
    func showLocalNotification(kiosk: KioskInfo) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var showStationNotification: Bool = userDefaults.boolForKey("StationNearbyNotificationSettingKey");
        if !showStationNotification {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            let notification = UILocalNotification();
            notification.fireDate = NSDate();
            notification.alertBody = "You are near the higi Station at \(kiosk.organizations[0]) \(kiosk.streetAddress)!";
            notification.applicationIconBadgeNumber = -1;
            UIApplication.sharedApplication().scheduleLocalNotification(notification);
        });
    }
    
    func clearNotification() {
        dispatch_async(dispatch_get_main_queue(), {
            UIApplication.sharedApplication().cancelAllLocalNotifications();
        });
    }
    
}