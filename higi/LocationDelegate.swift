import Foundation

final class LocationDelegate: NSObject, CLLocationManagerDelegate {
    
    private final var MAX_DISTANCE: Double = 200;
    
    private var lastKiosk: KioskInfo?;
    
    lazy private var stationController: StationController = {
        return StationController()
    }()
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { [weak self] in
            
            guard let strongSelf = self else { return }
            
            if strongSelf.stationController.stations.count == 0 {
                strongSelf.stationController.fetch({
                        strongSelf.findClosestLocation(newLocation)
                    }, failure: {
                        
                })
            } else {
                self?.findClosestLocation(newLocation)
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
            for kiosk in stationController.stations {
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
        let showStationNotification: Bool = PersistentSettingsController.boolForKey(.EnableNotifications) && PersistentSettingsController.boolForKey(.StationNearbyNotification);
        if !showStationNotification {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            let notification = UILocalNotification();
            notification.fireDate = NSDate();
            let notificationFormat = NSLocalizedString("LOCATION_DELEGATE_LOCAL_NOTIFICATION_FORMAT", comment: "Format of local notification which is displayed when a user is near a higi station.");
            notification.alertBody = String(format: notificationFormat, arguments: [kiosk.organizations[0], kiosk.streetAddress]);
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