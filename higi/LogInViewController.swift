//
//  LogInViewController.swift
//  higi
//
//  Created by Remy Panicker on 5/10/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import SafariServices

final class LogInViewController: UIViewController {

    @IBOutlet private var emailTextField: UITextField! {
        didSet {
            emailTextField.placeholder = NSLocalizedString("LOG_IN_VIEW_EMAIL_TEXT_FIELD_PLACEHOLDER", comment: "Placeholder for email text field.")
        }
    }
    
    @IBOutlet private var passwordTextField: UITextField! {
        didSet {
            passwordTextField.placeholder = NSLocalizedString("LOG_IN_VIEW_PASSWORD_TEXT_FIELD_PLACEHOLDER", comment: "Placeholder for password text field.")
        }
    }
    
    @IBOutlet private var logInButton : UIButton! {
        didSet {
            logInButton.setTitle(NSLocalizedString("LOG_IN_VIEW_LOGIN_BUTTON_TITLE", comment: "Title for login button."), forState: .Normal)
        }
    }
    
    @IBOutlet private var forgotPasswordButton: UIButton! {
        didSet {
            forgotPasswordButton.setTitle(NSLocalizedString("LOG_IN_VIEW_FORGOT_PASSWORD_BUTTON_TITLE", comment: "Title for forgot password button."), forState: .Normal)
        }
    }
    
    lazy private var spinner: CustomLoadingSpinner = {
        let spinner = CustomLoadingSpinner(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width / 2 - 16, UIScreen.mainScreen().bounds.size.height - 150 - self.topLayoutGuide.length, 32, 32))
        spinner.shouldAnimateFull = false
        return spinner
    }()
    
    private let dataController = LogInController()
    
    weak var delegate: LogInViewControllerDelegate?
    
    deinit {
        print("Deinit LOG IN vc")
    }
}

// MARK: - View Lifecycle

extension LogInViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("LOG_IN_VIEW_TITLE", comment: "Title for Log In view.")
        
        spinner.hidden = true
        self.view.addSubview(spinner)
        self.view.sendSubviewToBack(spinner)
        
        self.emailTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
}

// MARK: - UI Action

extension LogInViewController {
    
    @IBAction func didTapCancelButton(sender: UIBarButtonItem) {
        if let delegate = delegate {
            delegate.logInViewDidCancel(self)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func didTapLoginButton(sender: UIButton) {
        
        toggleElements(false)
        
        let email = emailTextField.text
        let password = passwordTextField.text
        if validateInput(email, password: password) {
            authenticate(email!, password: password!)
        } else {
            toggleElements(true)
        }
    }
    
    @IBAction func didTapForgotPasswordButton(sender: UIButton) {
        let URLString = "\(HigiApi.webUrl)/login/forgot_password"
        let URL = NSURL(string: URLString)!
        let safariViewController = SFSafariViewController(URL: URL, entersReaderIfAvailable: false)
        self.navigationController?.presentViewController(safariViewController, animated: true, completion: nil)
    }
    
    private func toggleElements(enableInteraction: Bool) {
        emailTextField.enabled = enableInteraction
        passwordTextField.enabled = enableInteraction
        let spinnerAction = enableInteraction ? spinner.stopAnimating : spinner.startAnimating
        spinnerAction()
        spinner.hidden = enableInteraction
        logInButton.enabled = enableInteraction
        forgotPasswordButton.enabled = enableInteraction
    }
}

// MARK: - Validation

extension LogInViewController {
    
    private func validateInput(email: String?, password: String?) -> Bool {
        
        let (validEmail, emailErrorMessage) = EmailValidator.validate(email)
        let (validPassword, passwordErrorMessage) = PasswordValidator.validate(password)
        
        if validEmail && validPassword {
            return true
        } else {
            if let message = emailErrorMessage where !validEmail {
                emailTextField.text = ""
                emailTextField.attributedPlaceholder = NSAttributedString(string: message, attributes: [NSForegroundColorAttributeName: Theme.Color.LogIn.errorPlaceholder])
            }
            if let message = passwordErrorMessage where !validPassword {
                passwordTextField.text = ""
                passwordTextField.attributedPlaceholder = NSAttributedString(string: message, attributes: [NSForegroundColorAttributeName: Theme.Color.LogIn.errorPlaceholder])
            }
            return false
        }
    }
}

// MARK: Authentication

extension LogInViewController {
    
    private func authenticate(email: String, password: String) {
        dataController.authenticate(email, password: password, success: { [weak self] (user) in
            self?.authenticationSuccessHandler(user)
        }, failure: { [weak self] (error) in
            self?.authenticationFailureHandler(error)
        })
    }
    
    private func authenticationSuccessHandler(user: User) {
        delegate?.logInViewDidAuthenticate(self, user: user)
    }
    
    private func authenticationFailureHandler(error: NSError?) {
        let title = NSLocalizedString("LOG_IN_VIEW_AUTHENTICATION_FAILURE_ALERT_TITLE", comment: "Title for alert displayed if email/password authentication fails.")
        let message = NSLocalizedString("LOG_IN_VIEW_AUTHENTICATION_FAILURE_ALERT_MESSAGE", comment: "Message for alert displayed if email/password authentication fails.")
        let dismissTitle = NSLocalizedString("LOG_IN_VIEW_AUTHENTICATION_FAILURE_ALERT_DISMISS_ACTION_TITLE", comment: "Title for alert action to dismiss alert displayed if email/password authentication fails.")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: dismissTitle, style: .Default, handler: nil)
        alertController.addAction(dismissAction)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: { [unowned self] in
                self.toggleElements(true)
                })
        })
    }
}

// MARK: - Text Field Delegate

extension LogInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
}

// MARK: - Protocol

protocol LogInViewControllerDelegate: class {
    
    func logInViewDidCancel(viewController: LogInViewController)
    
    func logInViewDidAuthenticate(viewController: LogInViewController, user: User)
}
