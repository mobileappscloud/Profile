//
//  RequiredAppUpdateViewController.swift
//  higi
//
//  Created by Remy Panicker on 10/22/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import UIKit

class RequiredAppUpdateViewController: UIViewController {
    
    private func appStoreURL() -> NSURL {
        let URLString = NSBundle.mainBundle().objectForInfoDictionaryKey("AppUpdateURL") as! String;
        return NSURL(string: URLString)!;
    }
    
    private func openAppStore() {
        UIApplication.sharedApplication().openURL(self.appStoreURL());
    }
}
