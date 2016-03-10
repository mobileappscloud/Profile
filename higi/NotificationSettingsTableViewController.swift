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
        
        self.title = NSLocalizedString("NOTIFICATION_SETTINGS_VIEW_TITLE", comment: "Title for notification settings view.")
        
        self.tableView.tableFooterView = UIView();
    }
}
