//
//  NotificationSettingsTableViewController.swift
//  higi
//
//  Created by Remy Panicker on 9/15/15.
//  Copyright (c) 2015 higi, LLC. All rights reserved.
//

import UIKit

enum TableSection: Int {
    case GlobalSetting
    case UniqueSetting
    case Count
}

enum SectionGlobalSettingRow: Int {
    case AllowNotifications
    case Count
}

enum SectionUniqueSettingRow: Int {
    case KioskNearby
    case ScannedCheckInUploadStatus
    case Count
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
        var backButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton;
        backButton.setBackgroundImage(UIImage(named: "btn_back_black.png"), forState: UIControlState.Normal);
        backButton.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside);
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        var backBarItem = UIBarButtonItem(customView: backButton);
        self.navigationItem.leftBarButtonItem = backBarItem;
        self.navigationItem.hidesBackButton = true;
    }
    
    func configureTableView() {
        let switchCellNib = UINib(nibName: "SwitchTableViewCell", bundle: nil);
        tableView.registerNib(switchCellNib, forCellReuseIdentifier: switchCellReuseIdentifier);
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
    
    func switchValueForIndexPath(indexPath: NSIndexPath) -> Bool {
        var value = false;
        
        if let section = TableSection(rawValue: indexPath.section) {
            switch section {
            case .GlobalSetting:
                if let row = SectionGlobalSettingRow(rawValue: indexPath.row) {
                    switch row {
                    case .AllowNotifications:
                        value = shouldSendNotifications();
                    default:
                        break;
                    }
                }
                
            case .UniqueSetting:
                if let row = SectionUniqueSettingRow(rawValue: indexPath.row) {
                    switch row {
                    case .KioskNearby:
                        value = shouldSendKioskNotifications();
                    case .ScannedCheckInUploadStatus:
                        value = shouldSendScannedCheckInNotifications();
                    default:
                        break;
                    }
                }
                
            default:
                break;
            }
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
            case .GlobalSetting:
                rowCount = SectionGlobalSettingRow.Count.rawValue;
            case .UniqueSetting:
                rowCount = SectionUniqueSettingRow.Count.rawValue;
            default:
                break;
            }
        }
        return rowCount;
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var rowHeight = UITableViewAutomaticDimension;
        if let tableSection = TableSection(rawValue: indexPath.section) {
            switch tableSection {
            case .UniqueSetting:
                rowHeight = shouldSendNotifications() ? UITableViewAutomaticDimension : 0.0;
                // MARK:!!! Remove debug printing
                print("\nrow = \(indexPath.row) , height = \(rowHeight)");
            default:
                break;
            }
        }
        return rowHeight;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell();

        if let tableSection = TableSection(rawValue: indexPath.section) {
            let switchCell = tableView.dequeueReusableCellWithIdentifier(switchCellReuseIdentifier, forIndexPath: indexPath) as! SwitchTableViewCell;
            
            switchCell.delegate = self;
            switchCell.switchControl.on = switchValueForIndexPath(indexPath);
            
            switch tableSection {
            case .GlobalSetting:
                if let row = SectionGlobalSettingRow(rawValue: indexPath.row) {
                    switch row {
                    case .AllowNotifications:
                        switchCell.titleLabel.text = "Allow Notifications";
                    default:
                        break;
                    }
                }
                
            case .UniqueSetting:
                if let row = SectionUniqueSettingRow(rawValue: indexPath.row) {
                    if row == .KioskNearby || row == .ScannedCheckInUploadStatus {
                        switchCell.switchControl.enabled = shouldSendNotifications();
                    }
                    
                    switch row {
                    case .KioskNearby:
                        switchCell.titleLabel.text = "Kiosk Nearby"
                    case .ScannedCheckInUploadStatus:
                        switchCell.titleLabel.text = "Scanned Check-in Status"
                    default:
                        break;
                    }
                }
                
            default:
                break;
            }

            cell = switchCell;
        }
        
        return cell;
    }
    
    // MARK: - Switch Cell Delegate
    
    func valueDidChangeForSwitchCell(cell: SwitchTableViewCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            self.tableView.beginUpdates();
            updateValueForNotificationSettingAtIndexPath(indexPath, value: cell.switchControl.on);
            self.tableView.endUpdates();
        };
    }
    
    func updateValueForNotificationSettingAtIndexPath(indexPath: NSIndexPath, value: Bool) {
        var key: String = "";
        
        if let tableSection = TableSection(rawValue: indexPath.section) {
            switch tableSection {
            case .GlobalSetting:
                if let row = SectionGlobalSettingRow(rawValue: indexPath.row) {
                    switch row {
                    case .AllowNotifications:
                        key = allLocalNotificationSettingKey;
                    default:
                        break;
                    }
                }
            case .UniqueSetting:
                if let row = SectionUniqueSettingRow(rawValue: indexPath.row) {
                    switch row {
                    case .KioskNearby:
                        key = kioskNotificationSettingKey;
                    case .ScannedCheckInUploadStatus:
                        key = scannedCheckInNotificationSettingKey;
                    default:
                        break;
                    }
                }
            default:
                break
            }
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
