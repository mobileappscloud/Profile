//
//  TabBarController.swift
//  higi
//
//  Created by Remy Panicker on 2/23/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class TabBarController: UITabBarController {
    
    private(set) var userController: UserController!
    
    enum ViewControllerIndex: Int {
        case Home
        case Communities
        case Challenges
        case Rewards
        case Metrics
        
        private static let allValues = [Home, Communities, Challenges, Rewards, Metrics]
    }

    lazy private(set) var homeNavController: UINavigationController = {
        let nav = UINavigationController(rootViewController: self.homeViewController)
        let title = NSLocalizedString("MAIN_TAB_BAR_ITEM_TITLE_HOME", comment: "Title for Home tab bar item.")
        self.configureTab(nav, title: title, itemImageNamePrefix: "home")
        return nav
    }()
    lazy private(set) var homeViewController: HomeViewController = {
        let homeViewController = UIStoryboard(name: "Home", bundle: nil).instantiateInitialViewController() as! HomeViewController
        homeViewController.navigationItem.rightBarButtonItems = [self.navigationOverflowBarButtonItem(), self.profileBarButtonItem()]
        homeViewController.configure(self.userController)
        return homeViewController
    }()
    
    lazy private(set) var communitiesNavController: UINavigationController = {
        let nav = UINavigationController(rootViewController: self.communitiesViewController)
        let title = NSLocalizedString("MAIN_TAB_BAR_ITEM_TITLE_COMMUNITIES", comment: "Title for Communities tab bar item.")
        self.configureTab(nav, title: title, itemImageNamePrefix: "communities")
        return nav
    }()
    lazy private(set) var communitiesViewController: CommunitiesViewController = {
        let communitiesViewController = UIStoryboard(name: "Communities", bundle: nil).instantiateInitialViewController() as! CommunitiesViewController
        communitiesViewController.navigationItem.rightBarButtonItems = [self.navigationOverflowBarButtonItem(), self.profileBarButtonItem()]
        communitiesViewController.configure(self.userController)
        return communitiesViewController
    }()
    
    lazy private(set) var challengesNavController: UINavigationController = {
        let nav = UINavigationController(rootViewController: self.challengesViewController)
        let title = NSLocalizedString("MAIN_TAB_BAR_ITEM_TITLE_CHALLENGES", comment: "Title for Challenges tab bar item.")
        self.configureTab(nav, title: title, itemImageNamePrefix: "challenges")
        return nav
    }()
    lazy private(set) var challengesViewController: ChallengesViewController = {
        let challengesViewController = UIStoryboard(name: "Challenges", bundle: nil).instantiateInitialViewController() as! ChallengesViewController
        challengesViewController.navigationItem.rightBarButtonItems = [self.navigationOverflowBarButtonItem(), self.profileBarButtonItem()]
        challengesViewController.configureWith(userController: self.userController)
        return challengesViewController
    }()
    
    lazy private(set) var rewardsNavController: UINavigationController = {
        let nav = UINavigationController(rootViewController: self.rewardsViewController)
        let title = NSLocalizedString("MAIN_TAB_BAR_ITEM_TITLE_REWARDS", comment: "Title for Rewards tab bar item.")
        self.configureTab(nav, title: title, itemImageNamePrefix: "rewards")
        return nav
    }()
    lazy private(set) var rewardsViewController: UIViewController = {
        let rewardsViewController = UIViewController()
        rewardsViewController.view.backgroundColor = Theme.Color.Primary.whiteGray
        rewardsViewController.title = "Rewards"
        rewardsViewController.navigationItem.rightBarButtonItems = [self.navigationOverflowBarButtonItem(), self.profileBarButtonItem()]
        return rewardsViewController
    }()
    
    lazy private(set) var metricsOverviewNavController: UINavigationController = {
        let nav = UINavigationController(rootViewController: self.metricsOverviewViewController)
        let title = NSLocalizedString("MAIN_TAB_BAR_ITEM_TITLE_METRICS", comment: "Title for Metrics tab bar item.")
        self.configureTab(nav, title: title, itemImageNamePrefix: "metrics")
        return nav
    }()
    lazy private(set) var metricsOverviewViewController: MetricsOverviewViewController = {
        let metricsOverviewViewController = UIStoryboard(name: "MetricsOverview", bundle: nil).instantiateInitialViewController() as! MetricsOverviewViewController
        metricsOverviewViewController.configure(withUserController: self.userController)
        metricsOverviewViewController.navigationItem.rightBarButtonItems = [self.navigationOverflowBarButtonItem(), self.profileBarButtonItem()]
        return metricsOverviewViewController
    }()
    
    private var previousViewControllerOnSelectedTab: UIViewController? = nil
    
    // MARK: -
    
    func configure(userController: UserController) {
        self.userController = userController
    }
}

// MARK: - View Lifecycle

extension TabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
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
        case .Communities:
            return communitiesNavController
        case .Challenges:
            return challengesNavController
        case .Rewards:
            return rewardsNavController
        case .Metrics:
            return metricsOverviewNavController
        }
    }
    
    private func configureTab(navigationController: UINavigationController, title: String, itemImageNamePrefix imageNamePrefix: String) {
        let image = UIImage(named: "\(imageNamePrefix)-tab-bar-icon")
        let selectedImage = UIImage(named: "\(imageNamePrefix)-selected-tab-bar-icon")
        navigationController.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: selectedImage)
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
    
    func findStationModalViewController() -> UIViewController {
        let findStationViewController = FindStationViewController(nibName: "FindStationView", bundle: nil)
        let findStationNav = UINavigationController(rootViewController: findStationViewController)
        return findStationNav
    }
    
    func settingsModalViewController() -> UIViewController {
        let settingsStoryboard = UIStoryboard(name: "Settings", bundle: nil)
        let settingsNavController = settingsStoryboard.instantiateInitialViewController() as! UINavigationController
        let settings = settingsNavController.topViewController as! SettingsViewController
        settings.configure(userController)
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
        popoverAlert.modalPresentationStyle = .Popover
        popoverAlert.popoverPresentationController?.permittedArrowDirections = .Any
        popoverAlert.popoverPresentationController?.barButtonItem = barButtonItem
        
        let dailySummaryMenuTitle = NSLocalizedString("MAIN_NAVIGATION_BAR_BUTTON_ITEM_OVERFLOW_POPOVER_ACTION_TITLE_DAILY_SUMMARY", comment: "Title for overflow menu action item which modally presents Daily Summary.")
        let dailySummary = popoverAction(dailySummaryMenuTitle, viewController: dailySummaryModalViewController(), analyticsEvent: "DailySummary_Pressed")
        dailySummary.enabled = false
        popoverAlert.addAction(dailySummary)
        
        let findStationMenuTitle = NSLocalizedString("MAIN_NAVIGATION_BAR_BUTTON_ITEM_OVERFLOW_POPOVER_ACTION_TITLE_FIND_STATION", comment: "Title for overflow menu action item which modally presents Find Station.")
        let findStation = popoverAction(findStationMenuTitle, viewController: findStationModalViewController(), analyticsEvent: "FindStation_Pressed")
        popoverAlert.addAction(findStation)
        
        let captureMenuTitle = NSLocalizedString("MAIN_NAVIGATION_BAR_BUTTON_ITEM_OVERFLOW_POPOVER_ACTION_TITLE_CAPTURE", comment: "Title for overflow menu action item which modally presents Capture.")
        let capture = popoverAction(captureMenuTitle, viewController: captureModalViewController(), analyticsEvent: "Capture_Pressed")
        popoverAlert.addAction(capture)
        
        let settingsMenuTitle = NSLocalizedString("MAIN_NAVIGATION_BAR_BUTTON_ITEM_OVERFLOW_POPOVER_ACTION_TITLE_SETTINGS", comment: "Title for overflow menu action item which modally presents Settings.")
        let settings = popoverAction(settingsMenuTitle, viewController: settingsModalViewController(), analyticsEvent: "Settings_Pressed")
        popoverAlert.addAction(settings)
        
        let cancelMenuTitle = NSLocalizedString("MAIN_NAVIGATION_BAR_BUTTON_ITEM_OVERFLOW_POPOVER_ACTION_TITLE_CANCEL", comment: "Title for overflow menu action item which dismisses the popover.")
        let cancel = UIAlertAction(title: cancelMenuTitle, style: .Cancel, handler: { (action) in
            Flurry.logEvent("Cancel_Pressed")
        })
        popoverAlert.addAction(cancel)
        
        return popoverAlert
    }
    
    private func popoverAction(title: String, viewController: UIViewController, analyticsEvent: String?) -> UIAlertAction {
        let action = UIAlertAction(title: title, style: .Default, handler: { [weak self] (action) in
            if let analyticsEvent = analyticsEvent {
                Flurry.logEvent(analyticsEvent)
            }
            dispatch_async(dispatch_get_main_queue(), {
                self?.presentViewController(viewController, animated: true, completion: nil)
            })
        })
        return action
    }
    
    // MARK: UI Action
    
    dynamic func didTapOverflowButton(sender: UIBarButtonItem) {
        let popoverAlert = self.popoverAlert(sender)
        self.presentViewController(popoverAlert, animated: true, completion: nil)
    }
    
    dynamic func didTapProfileButton(sender: UIBarButtonItem) {
        Flurry.logEvent("ProfileButton_Pressed")
        
        let viewController:UIViewController = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewControllerWithIdentifier("userProfileID") as! UserProfileViewController
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    func modalDoneButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - Tab Bar Delegate

extension TabBarController: UITabBarControllerDelegate {
    
    /**
        The tab bar delegate will attempt to trigger the scroll to top feature if we are viewing a tab's root view controller. Each tab bar item's root view controller is contained within a navigation controller. Thus the selected view controller will always be an instance of `UINavigationController`. We will need to access the navigation controller's `topViewController` property to determine which view is currently displayed.
 
        By default, iOS implements behavior where tapping on a tab bar which is already active will pop the navigation stack to the root view controller. In `(tabBarController:, shouldSelectViewController:)` the navigation controller's top view controller contains the child view controller which was pushed onto the stack. However, in `(tabBarController:, didSelectViewController:)` the navigation controller will already be popped to the root view controller. We will need to use both these methods to keep track of when a tab AND it's navigation stack have remained unchanged for successive taps on the tab bar item before we can scroll the root view's content view to the top.
     */
 
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        
        let trackPreviousViewControllerForSuccessiveTaps = (viewController == selectedViewController)
        if trackPreviousViewControllerForSuccessiveTaps {
            if let navigationController = viewController as? UINavigationController,
                let topViewController = navigationController.topViewController {
                previousViewControllerOnSelectedTab = topViewController
            }
        } else {
            previousViewControllerOnSelectedTab = nil
        }
        
        return true
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        
        logAnalyticEventForButtonPress(viewController)
        
        guard let previousViewController = previousViewControllerOnSelectedTab else { return }
        
        if let navigationController = viewController as? UINavigationController,
            let topViewController = navigationController.topViewController {
            
            if previousViewController == topViewController,
                let topScrollableView = topViewController as? TabBarTopScrollDelegate {
                topScrollableView.scrollToTop()
            }
        }
    }
    
    private func logAnalyticEventForButtonPress(selectedViewController: UIViewController) {
    
        guard let nav = (selectedViewController as? UINavigationController) else { return }
        
        guard let index = self.viewControllers?.indexOf(nav),
            let viewControllerIndex = ViewControllerIndex(rawValue: index) else { return }
        
        var event: String?
        switch viewControllerIndex {
        case .Home:
            event = "HomeButton_Pressed"
        case .Communities:
            event = "CommunityButton_Pressed"
        case .Challenges:
            event = "ChallengeButton_Pressed"
        case .Rewards:
            event = "RewardsButton_Pressed"
        case .Metrics: 
            event = "MetricsButton_Pressed"
        }
        if let event = event {
            Flurry.logEvent(event)
        }
    }
}


// MARK: - Protocols

/// Protocol which enables a tab bar item's root view controller to scroll to the top of the scroll view.
protocol TabBarTopScrollDelegate: class {
    
    /**
     Scrolls the content view to the top.
     */
    func scrollToTop()
}
