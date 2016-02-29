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

// MARK: - Navigation

extension TabBarController {
    
    // MARK: Bar Button Items
    
    private func navigationOverflowBarButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(named: "ellipses-nav-bar-icon"), style: .Plain, target: self, action: #selector(didTapOverflowButton))
    }
    
    private func modalDoneBarButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(modalDoneButtonTapped))
    }
    
    // MARK: Modal View Controllers
    
    private func pulseModalViewController() -> UIViewController {
        let pulseViewController = PulseHomeViewController(nibName: "PulseHomeView", bundle: nil)
        pulseViewController.navigationItem.rightBarButtonItem = modalDoneBarButtonItem()
        let pulseNav = UINavigationController(rootViewController: pulseViewController)
        return pulseNav
    }
    
    private func settingsModalViewController() -> UIViewController {
        let settingsStoryboard = UIStoryboard(name: "Settings", bundle: nil)
        let settingsNavController = settingsStoryboard.instantiateInitialViewController() as! UINavigationController
        settingsNavController.viewControllers.first?.navigationItem.rightBarButtonItem = modalDoneBarButtonItem()
        return settingsNavController
    }
    
    private func captureModalViewController() -> UIViewController {
        let captureViewController = QrScannerViewController(nibName: "QrScannerView", bundle: nil)
        captureViewController.navigationItem.rightBarButtonItem = modalDoneBarButtonItem()
        let captureNav = UINavigationController(rootViewController: captureViewController)
        return captureNav
    }
    
    // MARK: Popover Alert
    
    private func popoverAlert(barButtonItem: UIBarButtonItem?) -> UIAlertController {
        let popoverAlert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        popoverAlert.view.tintColor = Theme.Color.Primary.charcoal
        popoverAlert.modalPresentationStyle = .Popover
        popoverAlert.popoverPresentationController?.permittedArrowDirections = .Any
        popoverAlert.popoverPresentationController?.barButtonItem = barButtonItem
        
        let pulseMenuTitle = NSLocalizedString("MAIN_NAVIGATION_BAR_BUTTON_ITEM_OVERFLOW_POPOVER_ACTION_TITLE_HIGI_PULSE", comment: "Title for overflow menu action item which modally presents higi Pulse.")
        let pulse = popoverAction(pulseMenuTitle, viewController: pulseModalViewController())
        popoverAlert.addAction(pulse)
        
        let settingsMenuTitle = NSLocalizedString("MAIN_NAVIGATION_BAR_BUTTON_ITEM_OVERFLOW_POPOVER_ACTION_TITLE_SETTINGS", comment: "Title for overflow menu action item which modally presents Settings.")
        let settings = popoverAction(settingsMenuTitle, viewController: settingsModalViewController())
        popoverAlert.addAction(settings)
        
        let captureMenuTitle = NSLocalizedString("MAIN_NAVIGATION_BAR_BUTTON_ITEM_OVERFLOW_POPOVER_ACTION_TITLE_CAPTURE", comment: "Title for overflow menu action item which modally presents Capture.")
        let capture = popoverAction(captureMenuTitle, viewController: captureModalViewController())
        popoverAlert.addAction(capture)
        
        let cancelMenuTitle = NSLocalizedString("MAIN_NAVIGATION_BAR_BUTTON_ITEM_OVERFLOW_POPOVER_ACTION_TITLE_CANCEL", comment: "Title for overflow menu action item which dismisses the popover.")
        let cancel = UIAlertAction(title: cancelMenuTitle, style: .Cancel, handler: nil)
        popoverAlert.addAction(cancel)
        
        return popoverAlert
    }
    
    private func popoverAction(title: String, viewController: UIViewController) -> UIAlertAction {
        let action = UIAlertAction(title: title, style: .Default, handler: { [weak self] (action) in
            dispatch_async(dispatch_get_main_queue(), {
                self?.presentViewController(viewController, animated: true, completion: nil)
            })
        })
        return action
    }
    
    // MARK: UI Action
    
    dynamic func didTapOverflowButton(sender: UIBarButtonItem) {
        let popoverAlert = self.popoverAlert(sender)
        self.presentViewController(popoverAlert, animated: true, completion: {
            // Workaround to Apple bug where tintColor is overridden - http://stackoverflow.com/a/32695820/5897233
            popoverAlert.view.tintColor = Theme.Color.Primary.charcoal
        })
    }
    
    func modalDoneButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
