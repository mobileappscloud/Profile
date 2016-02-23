//
//  HostViewController.swift
//  higi
//
//  Created by Remy Panicker on 2/23/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

private struct Storyboard {
    private struct Segue {
        static let splashIdentifier = "SplashViewControllerStoryboardSegueIdentifier"
    }
}

/// Host viewcontroller which serves as a router for the base UI flows. This class should be set as the app delegate's root viewcontroller.
final class HostViewController: UIViewController {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate else { return }
        appDelegate.window?.rootViewController = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
     
        self.performSegueWithIdentifier(Storyboard.Segue.splashIdentifier, sender: self)
    }
}
