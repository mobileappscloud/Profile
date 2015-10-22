//
//  SplashViewController.swift
//  higi
//
//  Created by Dan Harms on 6/13/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class SplashViewController: UIViewController, UIAlertViewDelegate {
    
    private var spinner: CustomLoadingSpinner!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        checkVersion();
        self.spinner = CustomLoadingSpinner(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width / 2 - 16, UIScreen.mainScreen().bounds.size.height / 2 + 32, 32, 32));
        Utility.delay(3) {
            self.view.addSubview(self.spinner)
            self.spinner.startAnimating();
        };
    }

    func moveToNextScreen() {
        if (SessionData.Instance.token == "") {
            let navigationController = MainNavigationController(rootViewController: WelcomeViewController(nibName: "Welcome", bundle: nil));
            self.presentViewController(navigationController, animated: false, completion: nil);
        } else {
            HigiApi().sendGet("\(HigiApi.higiApiUrl)/data/qdata/\(SessionData.Instance.user.userId)?newSession=true", success: { operation, responseObject in
                
                let login = HigiLogin(dictionary: responseObject as! NSDictionary);
                SessionData.Instance.user = login.user;
                ApiUtility.checkTermsAndPrivacy(self, success: nil, failure: self.errorToWelcome);
                
                }, failure: {operation, error in
                    self.errorToWelcome();
            });
        }
    }
    
    func errorToWelcome() {
        spinner.stopAnimating();
        spinner.hidden = true;
        SessionData.Instance.reset();
        SessionData.Instance.save();
        let navigationController = MainNavigationController(rootViewController: WelcomeViewController(nibName: "Welcome", bundle: nil));
        self.presentViewController(navigationController, animated: false, completion: nil);
    }
    
    override func shouldAutorotate() -> Bool {
        return false;
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait;
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait;
    }
    
    func checkVersion() {
        HigiApi().sendGet("\(HigiApi.higiApiUrl)/app/mobile/minVersion?p=ios", success: { operation, responseObject in
            
            var minVersionParts = (responseObject as! NSString).componentsSeparatedByString(".") ;
            for i in minVersionParts.count...3 {
                minVersionParts.append("0");
            }
            var myVersionParts = Utility.appVersion().componentsSeparatedByString(".") as [String];
            
            var isUpToDate = true;
            
            for i in 0..<3 {
                let myPart = Int(myVersionParts[i])!;
                let minPart = Int(minVersionParts[i])!;
                if (myPart > minPart) {
                    break;
                } else if (myPart < minPart) {
                    isUpToDate = false;
                    break;
                }
            }
            
            if (isUpToDate) {
                self.moveToNextScreen();
            } else {
                let title = NSLocalizedString("APP_UPDATE_ALERT_TITLE", comment: "Title for alert displayed when app requires an update.")
                let message = NSLocalizedString("APP_UPDATE_ALERT_MESSAGE", comment: "Message for alert displayed when app requires an update.")
                let dismissTitle = NSLocalizedString("APP_UPDATE_ALERT_ACTION_TITLE_DISMISS", comment: "Title for dismiss action on alert displayed when app requires an update.")
                UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: dismissTitle).show();
            }
            
            }, failure: {operation, error in
                self.moveToNextScreen();
        });
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        UIApplication.sharedApplication().openURL(NSURL(string: "itms://itunes.apple.com/us/app/higi/id599485135?mt=8")!);
    }
    
}