//
//  UserCreationCoordinator.swift
//  higi
//
//  Created by Remy Panicker on 5/3/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class UserCreationCoordinator {
    
    private(set) weak var presentingViewController: UIViewController?
    
    lazy private var signUpEmailView: SignUpEmailViewController = {
        let storyboard = UIStoryboard(name: "CreateUser", bundle: nil)
        guard let nav = storyboard.instantiateInitialViewController() as? UINavigationController,
            let signUp = nav.topViewController as? SignUpEmailViewController else {
                fatalError("Unable to instantiate SignUpEmailViewController")
        }
        signUp.delegate = self
        return signUp
    }()
    
    private weak var delegate: UserCreationCoordinatorDelegate?
    
    private var userValidationCoordinator: UserValidationCoordinator?
    
    required init(delegate: UserCreationCoordinatorDelegate, presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
        self.delegate = delegate
    }
    
    deinit {
        print("release user creation coordinator")
    }
}

extension UserCreationCoordinator {
    
    func beginOnboarding() {
        navigateToSignUp()
    }
    
    private func navigateToSignUp() {
        let nav = UINavigationController(rootViewController: signUpEmailView)
        
        Flurry.logEvent("Signup_Pressed")
        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            self?.presentingViewController?.navigationController?.presentViewController(nav, animated: true, completion: nil)
        })
    }
    
    private func navigateToProfileImageView(userController: UserController) {
        let storyboard = UIStoryboard(name: "ProfileImage", bundle: nil)
        guard let nav = storyboard.instantiateInitialViewController() as? UINavigationController,
            let profileImageView = nav.topViewController as? ProfileImageViewController else { return }
        profileImageView.configure(userController, delegate: self)
        profileImageView.navigationItem.hidesBackButton = true
        profileImageView.hideSkipButton = false
        
        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            self?.signUpEmailView.navigationController?.pushViewController(profileImageView, animated: true)
            })
    }
}

// MARK: - Sign Up (Email/Password)

extension UserCreationCoordinator: SignUpEmailViewControllerDelegate {
    
    func signUpEmailViewDidCancel(viewController: SignUpEmailViewController) {
        dispatch_async(dispatch_get_main_queue(), {
            viewController.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    func signUpEmailViewDidCreateUser(viewController: SignUpEmailViewController, userController: UserController) {
        userValidationCoordinator = UserValidationCoordinator(userController: userController, presentingViewController: signUpEmailView, delegate: self)
        userValidationCoordinator!.beginValidation()
    }
}

// MARK: - User Validation

extension UserCreationCoordinator: UserValidationCoordinatorDelegate {
    
    func userValidationSucceeded(userController: UserController) {
        if let _ = userController.user.photo {
            delegate?.userCreationSucceeded()
        } else {
            navigateToProfileImageView(userController)
        }
        
        userValidationCoordinator = nil
    }
    
    func userValidationFailed(userController: UserController) {
        self.delegate?.userCreationFailed()
        userValidationCoordinator = nil
    }
    
    func userValidationDeclinedTermsAndPrivacy(userController: UserController) {
        dispatch_async(dispatch_get_main_queue(), {
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            self.delegate?.userCreationFailed()
        })
        userValidationCoordinator = nil
    }
    
    func userValidationIneligibleForService(userController: UserController) {
        dispatch_async(dispatch_get_main_queue(), {
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            self.delegate?.userCreationFailed()
        })
        userValidationCoordinator = nil
    }
}


// MARK: - Profile Picture

extension UserCreationCoordinator: ProfileImageViewControllerDelegate {
    
    func profileImageViewDidUpdateUserImage(viewController: ProfileImageViewController, userController: UserController) {
        delegate?.userCreationSucceeded()
    }
    
    func profileImageViewDidCancel(viewController: ProfileImageViewController) {
        delegate?.userCreationSucceeded()
    }
}

// MARK: - Protocol

protocol UserCreationCoordinatorDelegate: class {

    func userCreationSucceeded()
    
    func userCreationFailed()
}

