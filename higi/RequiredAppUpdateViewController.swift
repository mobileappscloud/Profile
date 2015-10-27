//
//  RequiredAppUpdateViewController.swift
//  higi
//
//  Created by Remy Panicker on 10/22/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import UIKit

class RequiredAppUpdateViewController: UIViewController {
    
    private let displayName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleDisplayName") as! NSString
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            let format = NSLocalizedString("REQUIRED_APP_UPDATE_VIEW_TITLE_FORMAT", comment: "Format of title text for required app update view.");
            titleLabel.text = NSString.localizedStringWithFormat(format, self.displayName) as String;
        }
    }
    @IBOutlet weak var messageLabel: UILabel! {
        didSet {
            let format = NSLocalizedString("REQUIRED_APP_UPDATE_VIEW_MESSAGE_FORMAT", comment: "Format of essage text for required app update view.");
            messageLabel.text = NSString.localizedStringWithFormat(format, self.displayName, self.displayName) as String;
        }
    }
    @IBOutlet weak var actionButton: UIButton! {
        didSet {
            let color = Utility.colorFromHexString(Constants.higiGreen);
            actionButton.setTitleColor(color, forState: .Normal);
            let title = NSLocalizedString("REQUIRED_APP_UPDATE_VIEW_UPDATE_ACTION_BUTTON_TITLE", comment: "Title for update-action button on required app update view.");
            actionButton.setTitle(title, forState: .Normal);
        }
    }
    
    // MARK: UI Action

    @IBAction func didTapActionButton(sender: AnyObject) {
        self.openAppStore()
    }
    
    // MARK: Helper
    
    private func appStoreURL() -> NSURL {
        let URLString = NSBundle.mainBundle().objectForInfoDictionaryKey("AppUpdateURL") as! String;
        return NSURL(string: URLString)!;
    }
    
    private func openAppStore() {
        UIApplication.sharedApplication().openURL(self.appStoreURL());
    }
}
