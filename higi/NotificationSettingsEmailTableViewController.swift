//
//  NotificationSettingsEmailTableViewController.swift
//  higi
//
//  Created by Remy Panicker on 9/23/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import UIKit

private enum TableSection: Int {
    case Main
    case Count
}

private enum MainSectionRow: Int {
    case CheckInResults
    case HigiNews
    case Count
        
    static let notification = [CheckInResults : EmailNotification.CheckInResult, HigiNews : EmailNotification.HigiNews];
}

class NotificationSettingsEmailTableViewController: UITableViewController, SwitchTableViewCellDelegate {

    let switchCellReuseIdentifier = "SwitchCellReuseIdentifier";

    let dataController = NotificationSettingsEmailController();
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        configureBackButton();
        configureNavigationTitle();
        
        configureTableView();
    }
    
    // MARK: Configuration
    
    func configureNavigationTitle() {
        self.title = NSLocalizedString("NOTIFICATION_SETTINGS_EMAIL_VIEW_TITLE", comment: "Title for email notification settings view.");
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
    
    func configureTableView() {
        tableView.registerClass(SwitchTableViewCell.self, forCellReuseIdentifier: switchCellReuseIdentifier);
        
        tableView.tableFooterView = UIView();
    }
    
    // MARK: - Navigation
    
    func didTapBackButton(sender: AnyObject!) {
        self.navigationController!.popViewControllerAnimated(true);
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TableSection.Count.rawValue;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0;
        if let tableSection = TableSection(rawValue: section) {
            switch tableSection {
            case .Main:
                rowCount = MainSectionRow.Count.rawValue;
            default:
                break;
            }
        }
        return rowCount;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell();
        if let section = TableSection(rawValue: indexPath.section) {
            switch section {
            case .Main:
                if  let row = MainSectionRow(rawValue: indexPath.row) {
                    let switchCell = tableView.dequeueReusableCellWithIdentifier(switchCellReuseIdentifier, forIndexPath: indexPath) as! SwitchTableViewCell;
                    
                    switchCell.delegate = self;
                    
                    switch row {
                    case .CheckInResults:
                        switchCell.textLabel!.text = NSLocalizedString("NOTIFICATION_SETTINGS_EMAIL_VIEW_CHECK_IN_RESULTS_CELL_TITLE", comment: "Title for check-in result email notification.");
                        switchCell.switchControl.on = EmailNotification.CheckInResult.isEnabled()
                    case .HigiNews:
                        switchCell.textLabel!.text = NSLocalizedString("NOTIFICATION_SETTINGS_EMAIL_VIEW_NEWS_CELL_TITLE", comment: "Title for news email notification.");
                        switchCell.switchControl.on = EmailNotification.HigiNews.isEnabled()
                    default:
                        break;
                    }
                    
                    cell = switchCell;
                }
            default:
                break;
            }
        }
        return cell;
    }
    
    // MARK: - Switch Cell
    
    func valueDidChangeForSwitchCell(cell: SwitchTableViewCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            if let section = TableSection(rawValue: indexPath.section) {
                if section == .Main {
                    if let row = MainSectionRow(rawValue: indexPath.row) {
                        
                        let notification = MainSectionRow.notification[row]
                        dataController.updateNotification(notification!, value: cell.switchControl.on,
                            completion: { [weak self] success in
                                if !success {
                                    dispatch_async(dispatch_get_main_queue(), {
                                        self?.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic);
                                    });
                                }
                            });
                    }
                }
            }
        }
    }
}
