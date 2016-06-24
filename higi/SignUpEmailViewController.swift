//
//  SignUpEmailViewController.swift
//  higi
//
//  Created by Remy Panicker on 5/3/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class SignUpEmailViewController: UIViewController {

    @IBOutlet private var emailTextField: UITextField! {
        didSet {
            emailTextField.placeholder = NSLocalizedString("SIGN_UP_EMAIL_VIEW_EMAIL_TEXT_FIELD_PLACEHOLDER", comment: "Placeholder for email text field.")
        }
    }
    
    @IBOutlet private var passwordTextField: UITextField! {
        didSet {
            passwordTextField.placeholder = NSLocalizedString("SIGN_UP_EMAIL_VIEW_PASSWORD_TEXT_FIELD_PLACEHOLDER", comment: "Placeholder for password text field.")
        }
    }
    
    @IBOutlet private var signupButton: UIButton! {
        didSet {
            signupButton.setTitle(NSLocalizedString("SIGN_UP_EMAIL_VIEW_SIGN_UP_BUTTON_TITLE", comment: "Title for sign up button."), forState: .Normal)
        }
    }
    
    lazy private var spinner: CustomLoadingSpinner = {
        let spinner = CustomLoadingSpinner(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width / 2 - 16, UIScreen.mainScreen().bounds.size.height - 150 - self.topLayoutGuide.length, 32, 32))
        spinner.shouldAnimateFull = false
        return spinner
    }()
    
    weak var delegate: SignUpEmailViewControllerDelegate?
    
    private var signUpController = SignUpEmailController()
    
    deinit {
        print("Deinit SIGN UP email VC")
    }
}

// MARK: - View Lifecycle

extension SignUpEmailViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("SIGN_UP_EMAIL_VIEW_TITLE", comment: "Title for Sign Up Email view.")
        
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

extension SignUpEmailViewController {
    
    @IBAction func didTapCancelButton(sender: UIBarButtonItem) {
        delegate?.signUpEmailViewDidCancel(self)
    }
    
    @IBAction func didTapSignUpButton(sender: UIButton) {
        
        toggleElements(false)
        
        let email = emailTextField.text
        let password = passwordTextField.text
        if validateInput(email, password: password) {
            createUser(email!, password: password!)
        } else {
            toggleElements(true)
        }
    }
    
    private func toggleElements(enableInteraction: Bool) {
        emailTextField.enabled = enableInteraction
        passwordTextField.enabled = enableInteraction
        let spinnerAction = enableInteraction ? spinner.stopAnimating : spinner.startAnimating
        spinnerAction()
        spinner.hidden = enableInteraction
        signupButton.enabled = enableInteraction
    }
}

// MARK: - Validation

extension SignUpEmailViewController {
    
    private func validateInput(email: String?, password: String?) -> Bool {
        
        let (validEmail, emailErrorMessage) = EmailValidator.validate(email)
        let (validPassword, passwordErrorMessage) = PasswordValidator.validate(password)
        
        if validEmail && validPassword {
            return true
        } else {
            if let message = emailErrorMessage where !validEmail {
                emailTextField.text = ""
                emailTextField.attributedPlaceholder = NSAttributedString(string: message, attributes: [NSForegroundColorAttributeName: Theme.Color.SignUp.Email.errorPlaceholder])
            } else {
                emailTextField.attributedPlaceholder = nil
                emailTextField.placeholder = NSLocalizedString("SIGN_UP_EMAIL_VIEW_EMAIL_TEXT_FIELD_PLACEHOLDER", comment: "Placeholder for email text field.")
            }
            if let message = passwordErrorMessage where !validPassword {
                passwordTextField.text = ""
                passwordTextField.attributedPlaceholder = NSAttributedString(string: message, attributes: [NSForegroundColorAttributeName: Theme.Color.SignUp.Email.errorPlaceholder])
            } else {
                passwordTextField.attributedPlaceholder = nil
                passwordTextField.placeholder = NSLocalizedString("SIGN_UP_EMAIL_VIEW_PASSWORD_TEXT_FIELD_PLACEHOLDER", comment: "Placeholder for password text field.")
            }
            return false
        }
    }
}

// MARK: - Create User

extension SignUpEmailViewController {
    
    private func createUser(email: String, password: String) {
        signUpController.createUser(email, password: password, success: { [weak self] in
            self?.signUpSuccess(email, password: password)
        }, failure: { [weak self] (error) in
            self?.signUpFailure(error)
        })
    }
    
    private func signUpSuccess(email: String, password: String) {
        signUpController.logIn(email, password: password, success: { [weak self] (user) in
            guard let strongSelf = self else { return }
            
            let userController = UserController(user: user)
            strongSelf.delegate?.signUpEmailViewDidCreateUser(strongSelf, userController: userController)
        }, failure: { [weak self] (error) in
            self?.signUpFailure(error)
        })
    }
    
    private func signUpFailure(error: NSError?) {
        if let error = error where (error.domain == HTTPErrorDomain && error.code == HTTPStatusCode.Conflict.rawValue) {
            displayDuplicateAccountError()
        } else {
            displayServerError()
        }
    }
    
    private func displayDuplicateAccountError() {
        let title = NSLocalizedString("SIGN_UP_EMAIL_VIEW_SIGN_UP_DUPLICATE_ACCOUNT_ALERT_TITLE", comment: "Title for alert displayed if a user attempts to create a duplicate account.")
        let message = NSLocalizedString("SIGN_UP_EMAIL_VIEW_SIGN_UP_DUPLICATE_ACCOUNT_ALERT_MESSAGE", comment: "Message for alert displayed if a user attempts to create a duplicate account.")
        let dismissTitle = NSLocalizedString("SIGN_UP_EMAIL_VIEW_SIGN_UP_DUPLICATE_ACCOUNT_ALERT_ACTION_TITLE_DISMISS", comment: "Title for alert action to dismiss alert displayed if a user attempts to create a duplicate account.")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: dismissTitle, style: .Default, handler: { [weak self] (action) in
            dispatch_async(dispatch_get_main_queue(), {
                self?.emailTextField.text = ""
                self?.passwordTextField.text = ""
            })
        })
        alertController.addAction(dismissAction)
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: { [unowned self] in
                self.toggleElements(true)
                })
        })
    }
    
    private func displayServerError() {
        let title = NSLocalizedString("SIGN_UP_EMAIL_VIEW_SERVER_COMMUNICATION_ERROR_ALERT_TITLE", comment: "Title for alert to display if there is a server communication error.")
        let message = NSLocalizedString("SIGN_UP_EMAIL_VIEW_SERVER_COMMUNICATION_ERROR_ALERT_MESSAGE", comment: "Message for alert to display if there is a server communication error.")
        let dismissTitle = NSLocalizedString("SIGN_UP_EMAIL_VIEW_SERVER_COMMUNICATION_ERROR_ALERT_ACTION_TITLE_DISMISS", comment: "Title for alert action to dismiss alert which is displayed if there is a server communication error.")
        
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

// MARK: - Protocol

protocol SignUpEmailViewControllerDelegate: class {
    
    func signUpEmailViewDidCancel(viewController: SignUpEmailViewController)
    
    func signUpEmailViewDidCreateUser(viewController: SignUpEmailViewController, userController: UserController)
}
