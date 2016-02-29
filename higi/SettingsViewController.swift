//
//  SettingsViewController.swift
//  higi
//
//  Created by Remy Panicker on 9/24/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    /*! @internal This is a left over property from the refactor */
    var pictureChanged = false;
    
    var settingsTableViewController: SettingsTableViewController!;
    
    // MARK: IB Outlets
    
    @IBOutlet weak var backgroundImageView: UIImageView! {
        didSet {
            backgroundImageView.image = SessionData.Instance.user.blurredImage;
        }
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("SETTINGS_VIEW_TITLE", comment: "Title for Settings view.")
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedSettingsTableViewControllerSegue" {
            settingsTableViewController = segue.destinationViewController as! SettingsTableViewController;
        }
    }
}
