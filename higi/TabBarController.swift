//
//  TabBarController.swift
//  higi
//
//  Created by Remy Panicker on 2/23/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class TabBarController: UITabBarController {

    private(set) lazy var homeViewController: DashboardViewController = {
        return DashboardViewController(nibName: "DashboardView", bundle: nil)
    }()
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeNav = UINavigationController(rootViewController: homeViewController)
        homeNav.tabBarItem = UITabBarItem(title: "Dashboard", image: UIImage(named: "home-tab-bar-icon"), selectedImage: UIImage(named: "home-tab-bar-highlight-icon"))
        self.viewControllers = [homeNav]
        
        self.tabBar.tintColor = Theme.Color.primary
    }
}

// MARK: - Interface Orientation

extension TabBarController {
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return .Portrait
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
}
