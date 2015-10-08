//
//  SettingsViewController.swift
//  higi
//
//  Created by Remy Panicker on 9/24/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import UIKit

class SettingsViewController: BaseViewController {
    
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        configureNavigationTitle();
    }
    
    // MARK: Configuration
    
    func configureNavigationTitle() {
        self.title = NSLocalizedString("SETTINGS_VIEW_TITLE", comment: "Title for Settings view.");
        self.navigationController!.navigationBar.barStyle = .Black;
        self.navigationController?.navigationBar.translucent = true;
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedSettingsTableViewControllerSegue" {
            settingsTableViewController = segue.destinationViewController as! SettingsTableViewController;
        }
    }
    
    // MARK: - Scroll View
    
    func updateNavBar() {
        let scrollY = settingsTableViewController.tableView.contentOffset.y;
        let alpha = min(scrollY / 100, 1);
        self.fakeNavBar.alpha = alpha;

        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 1.0 - alpha, alpha: 1.0)];
        if (alpha < 0.5) {
            toggleButton!.setBackgroundImage(UIImage(named: "nav_ocmicon"), forState: UIControlState.Normal);
            toggleButton!.alpha = 1 - alpha;
            pointsMeter.setLightText();
            self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        } else {
            toggleButton!.setBackgroundImage(UIImage(named: "nav_ocmicon_inverted"), forState: UIControlState.Normal);
            toggleButton!.alpha = alpha;
            pointsMeter.setDarkText();
            self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
        }
    }
}
