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
    var pictureChanged = false
    
    private(set) var settingsTableViewController: SettingsTableViewController!
    
    // MARK: IB Outlets
    
    @IBOutlet private var backgroundImageView: UIImageView!
    
    private(set) var userController: UserController!
    
    deinit {
        print("deinit settings vc")
    }
    
    func configure(userController: UserController) {
        self.userController = userController
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("SETTINGS_VIEW_TITLE", comment: "Title for Settings view.")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        if let photo = userController.user.photo {
            backgroundImageView.setImageWithURL(photo.URI)
        } else {
            backgroundImageView.image = nil
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedSettingsTableViewControllerSegue" {
            settingsTableViewController = segue.destinationViewController as! SettingsTableViewController
            settingsTableViewController.userController = userController
        }
    }
    
    @IBAction func didTapDoneButton(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
