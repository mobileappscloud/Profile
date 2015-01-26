//
//  SplashViewController.swift
//  higi
//
//  Created by Dan Harms on 6/13/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class SplashViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        moveToNextScreen();
    }
    
    func moveToNextScreen() {
        if (SessionData.Instance.token == "") {
            var navigationController = MainNavigationController(rootViewController: WelcomeViewController(nibName: "Welcome", bundle: nil));
            self.presentViewController(navigationController, animated: false, completion: nil);
        } else {
            HigiApi().sendGet("\(HigiApi.higiApiUrl)/data/qdata/\(SessionData.Instance.user.userId)?newSession=true", success: { operation, responseObject in
                
                var login = HigiLogin(dictionary: responseObject as NSDictionary);
                SessionData.Instance.user = login.user;
                ApiUtility.checkTermsAndPrivacy(self, success: self.gotoDashboard, failure: self.errorToWelcome);
                
                }, failure: {operation, error in
                    
                    self.errorToWelcome();
            });
        }
    }
    
    func gotoDashboard() {
        if (SessionController.Instance.checkins != nil && SessionController.Instance.activities != nil && SessionController.Instance.challenges != nil && SessionData.Instance.kioskList != nil && SessionController.Instance.pulseArticles.count > 0) {
            Utility.gotoDashboard(self);
        }
    }
    
    func errorToWelcome() {
        SessionData.Instance.reset();
        SessionData.Instance.save();
        var navigationController = MainNavigationController(rootViewController: WelcomeViewController(nibName: "Welcome", bundle: nil));
        self.presentViewController(navigationController, animated: false, completion: nil);
    }
    
    override func shouldAutorotate() -> Bool {
        return false;
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait;
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue;
    }

}
