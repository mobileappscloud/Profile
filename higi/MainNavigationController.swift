//
//  MainNavigationController.swift
//  higi
//
//  Created by Dan Harms on 7/22/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class MainNavigationController: UINavigationController {
    
    var revealController: RevealViewController!;
    
    var drawerController: DrawerViewController!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default);
        navigationBar.shadowImage = UIImage();
        navigationBar.translucent = true;
    }
    
    override func shouldAutorotate() -> Bool {
        return false;
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue);
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait;
    }

}