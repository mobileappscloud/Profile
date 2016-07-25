//
//  UserValidationCoordinator.swift
//  higi
//
//  Created by Remy Panicker on 5/12/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class UserValidationCoordinator {
    
    private(set) var userController: UserController

    private(set) weak var presentingViewController: UIViewController?

    private(set) weak var delegate: UserValidationCoordinatorDelegate?

    // Shortcut implementation for caching with expiration
    private var termsFileName: String?
    private var privacyFileName: String?
    private var termsAndPrivacyFetchDate: NSDate?
    private let termsAndPrivacyMaxCachedTimeInterval: NSTimeInterval = 600
    
    init(userController: UserController, presentingViewController: UIViewController, delegate: UserValidationCoordinatorDelegate) {
        self.userController = userController
        self.presentingViewController = presentingViewController
        self.delegate = delegate
    }
}

// MARK: - Validation

extension UserValidationCoordinator {
    
    func beginValidation() {
        if let _ = termsFileName,
            let _ = privacyFileName,
            let lastFetch = termsAndPrivacyFetchDate where lastFetch.timeIntervalSinceNow < termsAndPrivacyMaxCachedTimeInterval {
            validateUserInfo()
        } else {
            termsFileName = nil
            privacyFileName = nil
            termsAndPrivacyFetchDate = nil
            
            fetchLatestTermsAndPrivacy({ [weak self] in
                self?.validateUserInfo()
            }, failure: { [weak self] in
                if let strongSelf = self {
                    strongSelf.delegate?.userValidationFailed(strongSelf.userController)
                }
            })
        }
    }
    
    private func validateUserInfo() {
        let user = userController.user
        if user.terms == nil || user.privacy == nil ||
            user.terms?.fileName != termsFileName || user.privacy?.fileName != privacyFileName {
            navigateToTermsAndPrivacyAgreementView()
        } else if user.firstName == nil || user.lastName == nil {
            navigateToSignUpNameView()
        } else if user.dateOfBirth == nil {
            navigateToBirthdateView()
        } else {
            delegate?.userValidationSucceeded(userController)
        }
    }
}

// MARK: - Network Request

extension UserValidationCoordinator {
    
    private func fetchLatestTermsAndPrivacy(success: () -> Void, failure: () -> Void) {
        
        guard let request = TermsInfoRequest.request() else {
            failure()
            return
        }
        
        let session = APIClient.sharedSession
        let task = NSURLSessionTask.JSONTask(session, request: request, success: { [weak self] (JSON, response) in
            guard let dictionary = JSON as? NSDictionary,
                let termsFileName = dictionary["termsFilename"] as? String,
                let privacyFileName = dictionary["privacyFilename"] as? String else {
                    failure()
                    return
            }
            
            if let strongSelf = self {
                strongSelf.termsFileName = termsFileName
                strongSelf.privacyFileName = privacyFileName
                strongSelf.termsAndPrivacyFetchDate = NSDate()
            }
            success()
            
        }, failure: { (error, response) in
            failure()
        })
        task.resume()
    }
}

// MARK: - Navigation

extension UserValidationCoordinator {
    
    private func navigateToTermsAndPrivacyAgreementView() {
        let storyboard = UIStoryboard(name: "CreateUser", bundle: nil)
        guard let terms = storyboard.instantiateViewControllerWithIdentifier("SignUpTermsViewControllerIdentifier") as? SignUpTermsViewController,
            let termsFileName = termsFileName,
            let privacyFileName = privacyFileName else {
                return
        }
        terms.configure(userController, termsFileName: termsFileName, privacyFileName: privacyFileName, delegate: self)
        let nav = UINavigationController(rootViewController: terms)

        dispatch_async(dispatch_get_main_queue(), {
            self.presentingViewController?.presentViewController(nav, animated: true, completion: nil)
        })
    }
    
    private func navigateToSignUpNameView() {
        let storyboard = UIStoryboard(name: "CreateUser", bundle: nil)
        guard let signUpName = storyboard.instantiateViewControllerWithIdentifier("SignUpNameViewControllerIdentifier") as? SignUpNameViewController else {
                return
        }
        signUpName.configure(userController, delegate: self)
        
        if let navigationController = self.presentingViewController?.navigationController {
            dispatch_async(dispatch_get_main_queue(), {
                navigationController.pushViewController(signUpName, animated: true)
            })
        } else {
            let nav = UINavigationController(rootViewController: signUpName)
            dispatch_async(dispatch_get_main_queue(), {
                self.presentingViewController?.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
                self.presentingViewController?.presentViewController(nav, animated: true, completion: nil)
            })
        }
    }
    
    private func navigateToBirthdateView() {
        let storyboard = UIStoryboard(name: "CreateUser", bundle: nil)
        guard let birthDateView = storyboard.instantiateViewControllerWithIdentifier("BirthDateViewControllerIdentifier") as? BirthdateViewController else {
            return
        }
        birthDateView.configure(userController, delegate: self)
        
        if let navigationController = self.presentingViewController?.navigationController {
            dispatch_async(dispatch_get_main_queue(), {
                navigationController.pushViewController(birthDateView, animated: true)
            })
        } else {
            let nav = UINavigationController(rootViewController: birthDateView)
            dispatch_async(dispatch_get_main_queue(), {
                self.presentingViewController?.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
                self.presentingViewController?.presentViewController(nav, animated: true, completion: nil)
            })
        }
    }
}

// MARK: - Delegates

extension UserValidationCoordinator: SignUpTermsViewControllerDelegate {
    
    func signUpTermsViewDidDecline(viewController: SignUpTermsViewController) {
        if let presentingViewController = self.presentingViewController {
            dispatch_async(dispatch_get_main_queue(), {
                presentingViewController.dismissViewControllerAnimated(true, completion: nil)
            })
        }
        delegate?.userValidationDeclinedTermsAndPrivacy(userController)
    }
    
    func signUpTermsViewDidAgree(viewController: SignUpTermsViewController, userController: UserController) {
        dispatch_async(dispatch_get_main_queue(), {
            viewController.dismissViewControllerAnimated(true, completion: nil)
        })
        self.userController = userController
        beginValidation()
    }
}

extension UserValidationCoordinator: SignUpNameViewControllerDelegate {
    
    func signUpNameViewDidUpdate(viewController: SignUpNameViewController, userController: UserController) {
        self.userController = userController
        beginValidation()
    }
}

extension UserValidationCoordinator: BirthdateViewControllerDelegate {
    
    func birthdateViewDidUpdate(viewController: BirthdateViewController, userController: UserController) {
        self.userController = userController
        beginValidation()
    }
    
    func birthdateViewDidFailUserIneligibleForService(viewController: BirthdateViewController, userController: UserController) {
        if let presentingViewController = self.presentingViewController {
            dispatch_async(dispatch_get_main_queue(), {
                presentingViewController.dismissViewControllerAnimated(true, completion: nil)
            })
        }
        delegate?.userValidationIneligibleForService(userController)
    }
}

// MARK: - Protocol

protocol UserValidationCoordinatorDelegate: class {
    
    func userValidationSucceeded(userController: UserController)
    
    func userValidationFailed(userController: UserController)
    
    func userValidationDeclinedTermsAndPrivacy(userController: UserController)
    
    func userValidationIneligibleForService(userController: UserController)
}
