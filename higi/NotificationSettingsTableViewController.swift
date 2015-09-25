//
//  NotificationSettingsTableViewController.swift
//  higi
//
//  Created by Remy Panicker on 9/23/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import UIKit

class NotificationSettingsTableViewController: UITableViewController {

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        configureBackButton();
        configureNavigationTitle();
        
        self.tableView.tableFooterView = UIView();
    }
    
    // MARK: Configuration
    
    func configureNavigationTitle() {
        self.title = "Notifications";
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
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
