//
//  NotificationSettingsTableViewController.swift
//  higi
//
//  Created by Remy Panicker on 9/15/15.
//  Copyright (c) 2015 higi, LLC. All rights reserved.
//

import UIKit

enum TableSection: Int {
    case LocalNotification
    case Count
}

enum SectionLocalNotificationRow: Int {
    case AllNotifications
    case KioskNearby
    case ScannedCheckInUploadStatus
    case Count
    
    static let titleText = [AllNotifications : "Notifications", KioskNearby : "Nearby Kiosk Notifications", ScannedCheckInUploadStatus : "Scanned Check-in Upload Notifications"];
}

class NotificationSettingsTableViewController: UITableViewController, SwitchTableViewCellDelegate {

    let switchCellReuseIdentifier = "SwitchCellReuseIdentifier";
    
    // TODO: Currently assuming these settings should be device specific. Need to investigate various
    //       types of settings and create a settings-specific controller.
    let allLocalNotificationSettingKey = "AllLocalNotificationSettingKey";
    let kioskNotificationSettingKey = "KioskNotificationSettingKey";
    let scannedCheckInNotificationSettingKey = "ScannedCheckInNotificationSettingKey";
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationTitle();
        configureBackButton();
        
        configureTableView();
    }
    
    // MARK: Configuration
    
    func configureNavigationTitle() {
        self.title = "Notification Settings";
        self.navigationController!.navigationBar.barStyle = .Default;
        let navTitleLabel = UILabel();
        navTitleLabel.textColor = UIColor.blackColor();
        navTitleLabel.font = UIFont.boldSystemFontOfSize(17.0);
        navTitleLabel.text = self.title;
        navTitleLabel.sizeToFit();
        self.navigationItem.titleView = navTitleLabel;
    }
    
    func configureBackButton() {
        (self.navigationController as! MainNavigationController).revealController.panGestureRecognizer().enabled = false;
        let backButton = UIButton(type: UIButtonType.Custom);
        backButton.setBackgroundImage(UIImage(named: "btn_back_black.png"), forState: UIControlState.Normal);
        backButton.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside);
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        let backBarItem = UIBarButtonItem(customView: backButton);
        self.navigationItem.leftBarButtonItem = backBarItem;
        self.navigationItem.hidesBackButton = true;
    }
    
    func configureTableView() {
        let switchCellNib = UINib(nibName: "SwitchTableViewCell", bundle: nil);
        tableView.registerNib(switchCellNib, forCellReuseIdentifier: switchCellReuseIdentifier);
        tableView.estimatedRowHeight = 47.0;
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.tableFooterView = UIView();
    }

    // MARK: - Settings
    
    func shouldSendNotifications() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(allLocalNotificationSettingKey);
    }
    
    func shouldSendKioskNotifications() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(kioskNotificationSettingKey);
    }
    
    func shouldSendScannedCheckInNotifications() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(scannedCheckInNotificationSettingKey);
    }
    
    func switchValueForRow(row: SectionLocalNotificationRow) -> Bool {
        var value = false;
        switch row {
        case .AllNotifications:
            value = shouldSendNotifications();
        case .KioskNearby:
            value = shouldSendKioskNotifications();
        case .ScannedCheckInUploadStatus:
            value = shouldSendScannedCheckInNotifications();
        default:
            break;
        }
        return value;
    }
    
    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TableSection.Count.rawValue;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount: Int! = 0;
        if let tableSection = TableSection(rawValue: section) {
            switch tableSection {
            case .LocalNotification:
                rowCount = SectionLocalNotificationRow.Count.rawValue;
            default:
                break;
            }
        }
        return rowCount;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if let tableSection = TableSection(rawValue: indexPath.section) {
            switch tableSection {
            case .LocalNotification:
                let switchCell = tableView.dequeueReusableCellWithIdentifier(switchCellReuseIdentifier, forIndexPath: indexPath) as! SwitchTableViewCell;
                
                switchCell.delegate = self;
                if let row = SectionLocalNotificationRow(rawValue: indexPath.row) {
                    switchCell.titleLabel.text = SectionLocalNotificationRow.titleText[row];
                    
                    switchCell.switchControl.on = switchValueForRow(row);
                    
                    if row == .KioskNearby || row == .ScannedCheckInUploadStatus {
                        switchCell.switchControl.enabled = shouldSendNotifications();
                    }
                }
                
                return switchCell;
                
            default:
                break;
            }
        }
        
        assert(false, "Method must produce a cell.");
        return UITableViewCell();
    }
    
    // MARK: - Switch Cell Delegate
    
    func valueDidChangeForSwitchCell(cell: SwitchTableViewCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            if indexPath.section == TableSection.LocalNotification.rawValue {
                let row = SectionLocalNotificationRow(rawValue: indexPath.row)!
                updateValueForLocalNotificationSettingRow(row, value: cell.switchControl.on);
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)));
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.tableView.reloadData();
                };
            }
        }
    }
    
    func updateValueForLocalNotificationSettingRow(row: SectionLocalNotificationRow, value: Bool) {
        var key: String = "";
        
        switch row {
        case .AllNotifications:
            key = allLocalNotificationSettingKey;
        case .KioskNearby:
            key = kioskNotificationSettingKey;
        case .ScannedCheckInUploadStatus:
            key = scannedCheckInNotificationSettingKey;
        default:
            break;
        }

        if key != "" {
            NSUserDefaults.standardUserDefaults().setBool(value, forKey: key);
            NSUserDefaults.standardUserDefaults().synchronize();
        }
    }
    
    // MARK: - Navigation
    
    func goBack(sender: AnyObject!) {
        self.navigationController!.popViewControllerAnimated(true);
    }
}
