//
//  SignUpTermsViewController.swift
//  higi
//
//  Created by Remy Panicker on 5/4/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import WebKit

final class SignUpTermsViewController: UIViewController {
    
    /**
     Mode of function for the view controller.
     
     - updating: The view controller will attempt to update a user based on the response.
     - viewing:  The terms and privacy will be shown and the user's response will be reported back to the delegate.
     */
    private enum Mode {
        case updating
        case viewing
    }
    
    @IBOutlet private var headerLabel: UILabel! {
        didSet {
            headerLabel.text = NSLocalizedString("SIGN_UP_TERMS_VIEW_HEADER_TEXT", comment: "Text to display in header of sign up terms view.")
        }
    }
    
    @IBOutlet private var webView: WKWebView! {
        didSet {
            if let URL = NSURL(string: "\(HigiApi.webUrl)/termsandprivacy") {
                let request = NSMutableURLRequest(URL: URL)
                request.addValue("mobile-ios", forHTTPHeaderField: "Higi-Source");
                webView.loadRequest(request)
            }
        }
    }
    
    @IBOutlet private var declineButton: UIButton! {
        didSet {
            declineButton.setTitle(NSLocalizedString("SIGN_UP_TERMS_VIEW_BUTTON_TITLE_DECLINE", comment: "Title for decline button."), forState: .Normal);
            declineButton.layer.cornerRadius = 5.0
            declineButton.layer.borderWidth = 1.0
            declineButton.titleLabel?.textColor = Theme.Color.Primary.charcoal
            declineButton.layer.borderColor = Theme.Color.Primary.charcoal.CGColor
        }
    }
    
    @IBOutlet private var agreeButton: UIButton! {
        didSet {
            agreeButton.setTitle(NSLocalizedString("SIGN_UP_TERMS_VIEW_BUTTON_TITLE_AGREE", comment: "Title for agree button."), forState: .Normal);
            agreeButton.layer.cornerRadius = 5.0
        }
    }
    
    private var mode: Mode!
    
    private(set) var userController: UserController?
    
    private(set) var termsFileName: String?
    
    private(set) var privacyFileName: String?
    
    private weak var updatingDelegate: SignUpTermsViewControllerUpdatingDelegate?
    
    private weak var viewingDelegate: SignUpTermsViewControllerViewingDelegate?
}

// MARK: - Dependency Injection

extension SignUpTermsViewController {
    
    func configure(forUpdatingWithUserController userController: UserController, termsFileName: String, privacyFileName: String, updatingDelegate: SignUpTermsViewControllerUpdatingDelegate?) {
        self.mode = .updating
        self.userController = userController
        self.termsFileName = termsFileName
        self.privacyFileName = privacyFileName
        self.updatingDelegate = updatingDelegate
    }
    
    func configure(forViewingWithDelegate viewingDelegate: SignUpTermsViewControllerViewingDelegate?) {
        self.mode = .viewing
        self.viewingDelegate = viewingDelegate
    }
}

// MARK: - View Lifecycle

extension SignUpTermsViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("SIGN_UP_TERMS_VIEW_TITLE", comment: "Title for view which displays terms of service.")
    }
}

// MARK: - UI Action

extension SignUpTermsViewController {
    
    @IBAction func didTapAgreeButton(sender: UIButton) {
        if mode == .viewing {
            viewingDelegate?.signUpTermsViewDidAgree(self)
        } else if mode == .updating {
            updateUser()
        }
    }
    
    @IBAction func didTapDeclineButton(sender: UIButton) {
        if mode == .viewing {
            viewingDelegate?.signUpTermsViewDidDecline(self)
        } else if mode == .updating {
            updatingDelegate?.signUpTermsViewDidDecline(self)
        }
    }
}

// MARK: - Network Request

extension SignUpTermsViewController {
    
    private func updateUser() {
        guard let userController = userController,
            let termsFileName = termsFileName,
            let privacyFileName = privacyFileName else { return }
        
        toggleElements(false)
        
        userController.update(termsFileName, privacyFileName: privacyFileName, success: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.updateUserSuccessHandler(strongSelf.userController!)
        }, failure: { [weak self] (error) in
            self?.updateUserFailureHandler(error)
        })   
    }
    
    private func updateUserSuccessHandler(userController: UserController) {
        updatingDelegate?.signUpTermsViewDidAgree(self, userController: userController)
    }
    
    private func updateUserFailureHandler(error: NSError?) {
        toggleElements(true)
    }
}

// MARK: -

extension SignUpTermsViewController {
    
    private func toggleElements(enableInteraction: Bool) {
        agreeButton.enabled = enableInteraction
        declineButton.enabled = enableInteraction
    }
}

// MARK: - Updating Protocol

protocol SignUpTermsViewControllerUpdatingDelegate: class {

    func signUpTermsViewDidDecline(viewController: SignUpTermsViewController)
    
    func signUpTermsViewDidAgree(viewController: SignUpTermsViewController, userController: UserController)
}

// MARK: - Viewing Protocol

protocol SignUpTermsViewControllerViewingDelegate: class {
    
    func signUpTermsViewDidDecline(viewController: SignUpTermsViewController)
    
    func signUpTermsViewDidAgree(viewController: SignUpTermsViewController)
}
