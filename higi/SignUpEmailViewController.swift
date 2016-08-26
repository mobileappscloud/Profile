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
    
    private lazy var signUpController = SignUpEmailController()
    
    private var _validatedEmail: String?
    
    private var _validatedPassword: String?
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
            _validatedEmail = email
            _validatedPassword = password
            navigateToTermsAndPrivacy()
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

// MARK: - Terms and Conditions

extension SignUpEmailViewController {

    private func navigateToTermsAndPrivacy() {
        performSegueWithIdentifier(Storyboard.Segue.showTerms, sender: nil)
    }
}

// MARK: - Create User

extension SignUpEmailViewController {
    
    private func createUser(withTermsFileName termsFileName: String, privacyFileName: String) {
        guard let email = _validatedEmail,
            let password = _validatedPassword else { return }
        
        signUpController.createUser(email, password: password, termsFileName: termsFileName, privacyFileName: privacyFileName, success: { [weak self] (user) in
            self?.signUpSuccess(user)
        }, failure: { [weak self] (error) in
            self?.signUpFailure(error)
        })
    }
    
    private func signUpSuccess(user: User) {
        let userController = UserController(user: user)
        delegate?.signUpEmailViewDidCreateUser(self, userController: userController)
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

// MARK: - Segue

extension SignUpEmailViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        
        if identifier == Storyboard.Segue.showTerms {
            guard let navigationController = segue.destinationViewController as? UINavigationController,
                let signUpTermsViewController = navigationController.topViewController as? SignUpTermsViewController else { return }
            
            signUpTermsViewController.configure(forViewingWithDelegate: self)
        }
    }
}

// MARK: - Terms and Privacy Viewing Delegate

extension SignUpEmailViewController: SignUpTermsViewControllerViewingDelegate {
    
    func signUpTermsViewDidAgree(viewController: SignUpTermsViewController) {
        dispatch_async(dispatch_get_main_queue(), {
            self.dismissViewControllerAnimated(false, completion: nil)
            })
        
        signUpController.fetchTermsAndPrivacyInfo({ [weak self] (termsFileName, privacyFileName) in
            self?.createUser(withTermsFileName: termsFileName, privacyFileName: privacyFileName)
            }, failure: { [weak self] (error) in
                self?.displayServerError()
            })
    }
    
    func signUpTermsViewDidDecline(viewController: SignUpTermsViewController) {
        dispatch_async(dispatch_get_main_queue(), {
            self.dismissViewControllerAnimated(false, completion: nil)
            self.delegate?.signUpEmailViewDidCancel(self)
        })
    }
}

// MARK: - Text Field Delegate 

extension SignUpEmailViewController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == emailTextField {
            _validatedEmail = nil
        } else if textField == passwordTextField {
            _validatedPassword = nil
        }
        return true
    }
}

// MARK: - Storyboard

private extension SignUpEmailViewController {

    struct Storyboard {
        static let name = "CreateUser"
        
        struct Segue {
            static let showTerms = "signUpTermsSegue"
        }
    }
}

// MARK: - Protocol

protocol SignUpEmailViewControllerDelegate: class {
    
    func signUpEmailViewDidCancel(viewController: SignUpEmailViewController)
    
    func signUpEmailViewDidCreateUser(viewController: SignUpEmailViewController, userController: UserController)
}
