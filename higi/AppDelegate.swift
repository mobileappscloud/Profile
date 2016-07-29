//
//  AppDelegate.swift
//  higi
//
//  Created by Dan Harms on 6/9/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    
    var locationManager: CLLocationManager!;
    
    var locationDelegate: LocationDelegate!;
    
    // MARK: - Application Lifecycle

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        CrashAnalyticsManager.setupVendors()

        GMSServices.provideAPIKey("AIzaSyB1iNeT8pxcPd4rcwQ-Titp2hA5bLHh3-k");
        
        Flurry.startSession("2GSDDCY6499XJ8B5GTYZ");
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        SessionData.Instance.restore();
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Sound, UIUserNotificationType.Alert, UIUserNotificationType.Badge], categories: nil));
        
        if HealthKitManager.deviceHasMotionProcessor() &&
            HealthKitManager.isHealthDataAvailable() &&
            HealthKitManager.didShowAuthorizationModal() {
            HealthKitManager.checkReadAuthorizationForStepData({ (isAuthorized) in
                if isAuthorized {
                    HealthKitManager.enableBackgroundUpdates()
                } else {
                    HealthKitManager.disableBackgroundUpdates()
                }
            })
        }
        
        Theme.Appearance.applyGlobalStylings()
                
        var canHandleResource = true
        if let launchOptions = launchOptions,
            let userActivityDictionary = launchOptions[UIApplicationLaunchOptionsUserActivityDictionaryKey] {
            let userActivity = userActivityDictionary["UIApplicationLaunchOptionsUserActivityKey"] as! NSUserActivity
            
            if let webpageURL = userActivity.webpageURL {
                canHandleResource = UniversalLink.canHandleURL(webpageURL)
            }
        }
        return canHandleResource
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        checkPin();
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    // MARK: - Helper --> Should be refactored out of this class
    
    func checkPin() {
        if (SessionData.Instance.pin != "") {
            SessionController.Instance.askTouchId = false;
            let viewController: UIViewController? = Utility.mainTabBarController()?.presentedViewController ?? Utility.mainTabBarController()
            viewController?.presentViewController(PinCodeViewController(nibName: "PinCodeView", bundle: nil), animated: false, completion: nil);
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 0.2)); // Run for a bit to make sure lock screen shows up
        }
    }
    
    func startLocationManager() {
        if (locationManager == nil && UIApplication.sharedApplication().backgroundRefreshStatus == UIBackgroundRefreshStatus.Available) {
            locationManager = CLLocationManager();
            locationManager.requestAlwaysAuthorization();
            locationDelegate = LocationDelegate();
            locationManager.delegate = locationDelegate;
            locationManager.pausesLocationUpdatesAutomatically = true;
            locationManager.startMonitoringSignificantLocationChanges();
        }
    }
    
    func stopLocationManager() {
        if locationManager != nil {
            locationManager.stopMonitoringSignificantLocationChanges();
            locationManager = nil;
        }
    }
}

extension AppDelegate {
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        if application.applicationState == UIApplicationState.Active {
            if let info = notification.userInfo as? Dictionary<String, Int> {
                //99 is id of QR scanner notifications
                if info["ID"] == 99 {
                    let title = notification.alertTitle
                    let message = notification.alertBody
                    let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                    let acknowledgeActionTitle = NSLocalizedString("LOCAL_NOTIFICATION_SCANNED_CHECK_IN_ALERT_ACTION_TITLE_ACKNOWLEDGE", comment: "Title for action which dismisses alert displayed for a scanned station check-in upload.")
                    let acknowledgeAction = UIAlertAction(title: acknowledgeActionTitle, style: .Default, handler: nil)
                        alertController.addAction(acknowledgeAction)
    
                    self.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}

extension AppDelegate {
        
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        
        var didContinueUserActivity = false
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let webpageURL = userActivity.webpageURL {
                if UniversalLink.canHandleURL(webpageURL) {
                    continueHandling(userActivityWithUniversalLink: userActivity)
                    didContinueUserActivity = true
                } else {
                    application.openURL(webpageURL)
                }
            }
        }
        
        return didContinueUserActivity
    }
    
    private func continueHandling(userActivityWithUniversalLink userActivity: NSUserActivity) {
        guard let hostViewController = window?.rootViewController as? HostViewController else { return }
        
        hostViewController.userActivity = userActivity
    }
}

extension AppDelegate {
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
}

extension AppDelegate {
    
    class func instance() -> AppDelegate {
        return UIApplication.sharedApplication().delegate! as! AppDelegate
    }
}
