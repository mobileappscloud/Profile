//
//  TabBarController.swift
//  higi
//
//  Created by Remy Panicker on 2/23/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class TabBarController: UITabBarController {

    lazy private(set) var homeViewController: DashboardViewController = {
        let homeViewController = DashboardViewController(nibName: "DashboardView", bundle: nil)
        return homeViewController
    }()
    
    lazy private(set) var challengesViewController: ChallengesViewController = {
        return ChallengesViewController(nibName: "ChallengesView", bundle: nil)
    }()
    
    lazy private(set) var metricsViewController: NewMetricsViewController = {
        let navController = UIStoryboard(name: "Metrics", bundle: nil).instantiateInitialViewController() as! UINavigationController
        return navController.topViewController as! NewMetricsViewController
    }()
    
    lazy private(set) var findStationViewController: FindStationViewController = {
       return FindStationViewController(nibName: "FindStationView", bundle: nil)
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addViewControllers()
        self.tabBar.tintColor = Theme.Color.primary
    }
}

// MARK: - Configuration

extension TabBarController {
    
    private func addViewControllers() {
        
        let dashboardTitle = NSLocalizedString("MAIN_TAB_BAR_ITEM_TITLE_HOME", comment: "Title for Home tab bar item.")
        let challengesTitle = NSLocalizedString("MAIN_TAB_BAR_ITEM_TITLE_CHALLENGES", comment: "Title for Challenges tab bar item.")
        let metricsTitle = NSLocalizedString("MAIN_TAB_BAR_ITEM_TITLE_METRICS", comment: "Title for Metrics tab bar item.")
        let findStationsTitle = NSLocalizedString("MAIN_TAB_BAR_ITEM_TITLE_FIND_STATION", comment: "Title for Find Station tab bar item.")
        
        typealias tabConfigItem = (viewController: UIViewController, navController: UINavigationController?, imageNamePrefix: String, title: String)
        let items: [tabConfigItem] = [(homeViewController, nil, "home", dashboardTitle),
                                      (challengesViewController, nil, "challenges", challengesTitle),
                                      (metricsViewController, metricsViewController.navigationController, "metrics", metricsTitle),
                                      (findStationViewController, nil, "station", findStationsTitle)
        ]
        
        var configuredControllers: [UIViewController] = []
        for var item in items {
            item.viewController.navigationItem.rightBarButtonItem = navigationOverflowBarButtonItem()
            if item.navController == nil {
                item.navController = UINavigationController(rootViewController: item.viewController)
            }
            guard let navController = item.navController else { continue }
            
            let image = UIImage(named: "\(item.imageNamePrefix)-tab-bar-icon")
            let highlightImage = UIImage(named: "\(item.imageNamePrefix)-tab-bar-highlight-icon")
            navController.tabBarItem = UITabBarItem(title: item.title, image: image, selectedImage: highlightImage)
            configuredControllers.append(navController)
        }
        
        self.viewControllers = configuredControllers
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
