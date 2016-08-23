//
//  HostViewController.swift
//  higi
//
//  Created by Remy Panicker on 2/23/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

/// Host viewcontroller which serves as a router for the base UI flows. This class should be set as the app delegate's root viewcontroller.
final class HostViewController: UIViewController {
    
    private enum RouteHandling {
        case Uninitialized
        case Processing
        case AppUpdate
        case Unauthenticated
        case Authenticated
    }
    
    private let hostController = HostController()
    
    private var userValidationCoordinator: UserValidationCoordinator?
    
    lazy private var routeHandling: RouteHandling = {
        return RouteHandling.Uninitialized
    }()
    
    override var userActivity: NSUserActivity? {
        get {
            return super.userActivity
        }
        set {
            if let newValue = newValue {
                switch self.routeHandling {
                case .Uninitialized:
                    fallthrough
                case .Processing:
                    super.userActivity = newValue
                case .Authenticated:
                    super.userActivity = newValue
                    self.handleUserActivity()
                    
                case .AppUpdate:
                    fallthrough
                case .Unauthenticated:
                    break
                }
            } else {
                super.userActivity = newValue
            }
        }
    }
    
    deinit {
        unregisterForNotifications()
    }
}

// MARK: - View Lifecycle

extension HostViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        registerForNotifications()
        routeUserFlow()
    }
}

// MARK: - Notifications

extension HostViewController {
    
    private func registerForNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didRecieveAuthenticatedSessionTerminationNotification), name: APIClientTerminateAuthenticatedSessionNotification, object: nil)
    }
    
    private func unregisterForNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: APIClientTerminateAuthenticatedSessionNotification, object: nil)
    }
    
    @objc private func didRecieveAuthenticatedSessionTerminationNotification(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), {
            self.dismissViewControllerAnimated(false, completion: nil)
        })
        
        hostController.revokeRefreshToken({ [weak self] in
            self?.spawnNewHost()
        })
        APIClient.removeCachedAuthorization()
    }
    
    private func spawnNewHost() {
        let storyboard = UIStoryboard(name: "Host", bundle: nil)
        let host = storyboard.instantiateInitialViewController() as! HostViewController
        dispatch_async(dispatch_get_main_queue(), {
            AppDelegate.instance().window?.rootViewController = host        
        })
    }
}

// MARK: - Routing

extension HostViewController {
    
    private func routeUserFlow() {
        routeHandling = .Processing
        
        hostController.appMeetsMinimumVersion({ [weak self] in
            self?.checkCachedToken()
            }, failure: { [weak self] in
                self?.navigateToAppUpdateView()
        })
    }
    
    private func checkCachedToken() {
        guard hostController.authorizationTokenIsCached() else {
            return navigateToWelcomeView()
        }
        if hostController.authorizationTokenIsLegacyToken() {
            hostController.migrateLegacyToken({ [weak self] in
                self?.initAuthenticatedUserFlow()
            }, failure: { [weak self] in
                self?.navigateToWelcomeView()
            })
            return
        }
        // We can skip validation of OAuth2 access token because the networking layer automatically wraps authenticated requests with logic to refresh invalid tokens and log out if a refreshed access token can not be obtained.
        initAuthenticatedUserFlow()
    }
}

// MARK: Authenticated Route

extension HostViewController {
    
    private func initAuthenticatedUserFlow() {
        hostController.fetchUser({ [weak self] in
            self?.validateUser()
        }, failure: { [weak self] in
            self?.navigateToWelcomeView()
        })
    }
    
    private func validateUser() {
        guard let userController = hostController.userController else {
            navigateToWelcomeView()
            return
        }
        
        userValidationCoordinator = UserValidationCoordinator(userController: userController, presentingViewController: self, delegate: self)
        userValidationCoordinator!.beginValidation()
    }
}

extension HostViewController {
    
    private func handleUserActivity() {
        guard let userActivity = userActivity,
            let webpageURL = userActivity.webpageURL else { return }
        
        UniversalLink.handleURL(webpageURL)
        self.userActivity = nil
    }
}

// MARK: - Navigation

extension HostViewController {
    
    private func navigateToMainTabBar(withUserController userController: UserController, completion: (() -> Void)?) {
        let tabBar = UIStoryboard(name: "TabBar", bundle: nil).instantiateInitialViewController() as! TabBarController
        tabBar.configure(userController)
        present(tabBar, completion: completion)
        routeHandling = .Authenticated
    }
    
    private func navigateToWelcomeView() {
        let welcomeViewController = WelcomeViewController(nibName: "Welcome", bundle: nil)
        welcomeViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: welcomeViewController)
        present(navigationController)
        routeHandling = .Unauthenticated
    }
    
    private func navigateToAppUpdateView() {
        let appUpdateViewController = UIStoryboard(name: "RequiredAppUpdate", bundle: nil).instantiateInitialViewController() as! RequiredAppUpdateViewController
        present(appUpdateViewController)
        routeHandling = .AppUpdate
    }
    
    private func present(viewController: UIViewController, completion: (() -> Void)? = nil) {
        dispatch_async(dispatch_get_main_queue(), {
            self.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
            self.presentViewController(viewController, animated: true, completion: completion)
        })
    }
}

// MARK: - Delegate

extension HostViewController: WelcomeViewControllerDelegate {
    
    func welcomeViewDidObtainAuthentication(viewController: WelcomeViewController) {
        dispatch_async(dispatch_get_main_queue(), {
            self.dismissViewControllerAnimated(false, completion: nil)
        })
        initAuthenticatedUserFlow()
    }
}

extension HostViewController: UserValidationCoordinatorDelegate {
    
    func userValidationSucceeded(userController: UserController) {
        navigateToMainTabBar(withUserController: userController, completion: { [weak self] in
            if let _ = self?.userActivity {
                self?.handleUserActivity()
            }
        })
        userValidationCoordinator = nil
    }
    
    func userValidationFailed(userController: UserController) {
        userValidationFailureHandler()
    }
    
    func userValidationDeclinedTermsAndPrivacy(userController: UserController) {
        userValidationFailureHandler()
    }
    
    func userValidationIneligibleForService(userController: UserController) {
        userValidationFailureHandler()
    }
    
    private func userValidationFailureHandler() {
        navigateToWelcomeView()
        userValidationCoordinator = nil
        userActivity = nil
    }
}
