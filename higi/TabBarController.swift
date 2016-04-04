//
//  TabBarController.swift
//  higi
//
//  Created by Remy Panicker on 2/23/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class TabBarController: UITabBarController {
    
    enum ViewControllerIndex: Int {
        case Home
        case Challenges
        case Metrics
        case FindStation
        
        private static let allValues = [Home, Challenges, Metrics, FindStation]
    }

    lazy private(set) var homeNavController: UINavigationController = {
        let nav = UINavigationController(rootViewController: self.homeViewController)
        let title = NSLocalizedString("MAIN_TAB_BAR_ITEM_TITLE_HOME", comment: "Title for Home tab bar item.")
        self.configureTab(nav, title: title, itemImageNamePrefix: "home", enabled: true)
        return nav
    }()
    lazy private(set) var homeViewController: DashboardViewController = {
        let homeViewController = DashboardViewController(nibName: "DashboardView", bundle: nil)
        homeViewController.navigationItem.rightBarButtonItems = [self.navigationOverflowBarButtonItem(), self.profileBarButtonItem()]
        return homeViewController
    }()
    
    lazy private(set) var challengesNavController: UINavigationController = {
        let nav = UINavigationController(rootViewController: self.challengesViewController)
        let title = NSLocalizedString("MAIN_TAB_BAR_ITEM_TITLE_CHALLENGES", comment: "Title for Challenges tab bar item.")
        self.configureTab(nav, title: title, itemImageNamePrefix: "challenges")
        return nav
    }()
    lazy private(set) var challengesViewController: ChallengesViewController = {
        let challengesViewController = ChallengesViewController(nibName: "ChallengesView", bundle: nil)
        challengesViewController.navigationItem.rightBarButtonItems = [self.navigationOverflowBarButtonItem(), self.profileBarButtonItem()]
        return challengesViewController
    }()
    
    lazy private(set) var metricsNavController: UINavigationController = {
        let nav = UINavigationController(rootViewController: self.metricsViewController)
        let title = NSLocalizedString("MAIN_TAB_BAR_ITEM_TITLE_METRICS", comment: "Title for Metrics tab bar item.")
        self.configureTab(nav, title: title, itemImageNamePrefix: "metrics")
        return nav
    }()
    lazy private(set) var metricsViewController: NewMetricsViewController = {
        let metricsViewController = UIStoryboard(name: "Metrics", bundle: nil).instantiateInitialViewController() as! NewMetricsViewController
        metricsViewController.navigationItem.rightBarButtonItems = [self.navigationOverflowBarButtonItem(), self.profileBarButtonItem()]
        return metricsViewController
    }()
    
    lazy private(set) var findStationNavController: UINavigationController = {
        let nav = UINavigationController(rootViewController: self.findStationViewController)
        let title = NSLocalizedString("MAIN_TAB_BAR_ITEM_TITLE_FIND_STATION", comment: "Title for Find Station tab bar item.")
        self.configureTab(nav, title: title, itemImageNamePrefix: "station", enabled: true)
        return nav
    }()
    lazy private(set) var findStationViewController: FindStationViewController = {
       let findStationViewController = FindStationViewController(nibName: "FindStationView", bundle: nil)
        findStationViewController.navigationItem.rightBarButtonItems = [self.navigationOverflowBarButtonItem(), self.profileBarButtonItem()]
        return findStationViewController
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var controllers: [UIViewController] = []
        for index in ViewControllerIndex.allValues {
            controllers.append(navController(viewControllerIndex: index))
        }
        self.viewControllers = controllers
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        hideTabBar(forSize: self.view.frame.size)
    }
}

// MARK: - Configuration

extension TabBarController {
    
    private func navController(viewControllerIndex index: ViewControllerIndex) -> UINavigationController {
        switch index {
        case .Home:
            return homeNavController
        case .Challenges:
            return challengesNavController
        case .Metrics:
            return metricsNavController
        case .FindStation:
            return findStationNavController
        }
    }
    
    private func configureTab(navigationController: UINavigationController, title: String, itemImageNamePrefix imageNamePrefix: String, enabled: Bool = false) {
        let image = UIImage(named: "\(imageNamePrefix)-tab-bar-icon")
        let selectedImage = UIImage(named: "\(imageNamePrefix)-selected-tab-bar-icon")
        navigationController.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: selectedImage)
        navigationController.tabBarItem.enabled = enabled
    }
}

// MARK: - Navigation

extension TabBarController {
    
    // MARK: Bar Button Items
    
    private func navigationOverflowBarButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(named: "ellipses-nav-bar-icon"), style: .Plain, target: self, action: #selector(TabBarController.didTapOverflowButton(_:)))
    }
    
    private func profileBarButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(named: "profile-nav-bar-icon"), style: .Plain, target: self, action: #selector(TabBarController.didTapProfileButton(_:)))
    }
    
    private func modalDismissBarButtonItem(systemItem: UIBarButtonSystemItem) -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: systemItem, target: self, action: #selector(TabBarController.modalDoneButtonTapped(_:)))
    }
    
    // MARK: Modal View Controllers
    
    func dailySummaryModalViewController() -> UIViewController {
        let dailySummaryViewController = DailySummaryViewController(nibName: "DailySummaryView", bundle: nil)
        dailySummaryViewController.navigationItem.rightBarButtonItem = modalDismissBarButtonItem(.Done)
        let dailySummaryNav = UINavigationController(rootViewController: dailySummaryViewController)
        return dailySummaryNav
    }
    
    func pulseModalViewController() -> UIViewController {
        let pulseViewController = PulseHomeViewController(nibName: "PulseHomeView", bundle: nil)
        pulseViewController.navigationItem.rightBarButtonItem = modalDismissBarButtonItem(.Done)
        let pulseNav = UINavigationController(rootViewController: pulseViewController)
        return pulseNav
    }
    
    func settingsModalViewController() -> UIViewController {
        let settingsStoryboard = UIStoryboard(name: "Settings", bundle: nil)
        let settingsNavController = settingsStoryboard.instantiateInitialViewController() as! UINavigationController
        return settingsNavController
    }
    
    private func captureModalViewController() -> UIViewController {
        let captureViewController = QrScannerViewController(nibName: "QrScannerView", bundle: nil)
        captureViewController.navigationItem.rightBarButtonItem = modalDismissBarButtonItem(.Cancel)
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
        
        let dailySummaryMenuTitle = NSLocalizedString("MAIN_NAVIGATION_BAR_BUTTON_ITEM_OVERFLOW_POPOVER_ACTION_TITLE_DAILY_SUMMARY", comment: "Title for overflow menu action item which modally presents Daily Summary.")
        let dailySummary = popoverAction(dailySummaryMenuTitle, viewController: dailySummaryModalViewController())
        dailySummary.enabled = homeViewController.metricsLoaded && homeViewController.activitiesLoaded
        popoverAlert.addAction(dailySummary)
        
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
    
    dynamic func didTapProfileButton(sender: UIBarButtonItem) {
        
    }
    
    func modalDoneButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
