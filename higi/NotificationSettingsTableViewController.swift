//
//  NotificationSettingsTableViewController.swift
//  higi
//
//  Created by Remy Panicker on 9/23/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import UIKit

class NotificationSettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var pushNotificationCell: UITableViewCell! {
        didSet {
            pushNotificationCell.textLabel?.text = NSLocalizedString("NOTIFICATION_SETTINGS_DEVICE_VIEW_TITLE", comment: "Title for device-specific notification settings view.")
        }
    }

    @IBOutlet weak var emailCell: UITableViewCell! {
        didSet {
            emailCell.textLabel?.text = NSLocalizedString("NOTIFICATION_SETTINGS_EMAIL_VIEW_TITLE", comment: "Title for email notification settings view.")
        }
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        configureBackButton();
        configureNavigationTitle();
        
        self.tableView.tableFooterView = UIView();
    }
    
    // MARK: Configuration
    
    func configureNavigationTitle() {
        self.title = NSLocalizedString("NOTIFICATION_SETTINGS_VIEW_TITLE", comment: "Title for notification settings view.");
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
        self.navigationController!.navigationBar.barStyle = .Default;
        self.navigationController?.navigationBar.translucent = false;
    }
    
    func configureBackButton() {
        (self.navigationController as! MainNavigationController).revealController.panGestureRecognizer().enabled = false;
        let backButton = UIButton(type: UIButtonType.Custom);
        backButton.setBackgroundImage(UIImage(named: "btn_back_black.png"), forState: UIControlState.Normal);
        backButton.addTarget(self, action: "didTapBackButton:", forControlEvents: UIControlEvents.TouchUpInside);
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        let backBarItem = UIBarButtonItem(customView: backButton);
        self.navigationItem.leftBarButtonItem = backBarItem;
        self.navigationItem.hidesBackButton = true;
    }
    
    // MARK: - Navigation
    
    func didTapBackButton(sender: AnyObject!) {
        self.navigationController!.popViewControllerAnimated(true);
    }
}
