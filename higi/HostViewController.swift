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

    lazy var splashViewController = UIStoryboard(name: "Splash", bundle: nil).instantiateInitialViewController() as! SplashViewController
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate else { return }
        appDelegate.window?.rootViewController = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
     
        self.presentViewController(splashViewController, animated: true, completion: nil)
    }
}
