//
//  ChangePasswordViewController.swift
//  higi
//
//  Created by Dan Harms on 8/18/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

final class ChangePasswordViewController: UIViewController {
    
    @IBOutlet weak var currentPasswordTextField: UITextField! {
        didSet {
            currentPasswordTextField.placeholder = NSLocalizedString("CHANGE_PASSWORD_VIEW_CURRENT_PASSWORD_TEXT_FIELD_PLACEHOLDER", comment: "Placeholder for current password text field.")
        }
    }
    
    @IBOutlet weak var newPasswordTextField: UITextField! {
        didSet {
            newPasswordTextField.placeholder = NSLocalizedString("CHANGE_PASSWORD_VIEW_NEW_PASSWORD_TEXT_FIELD_PLACEHOLDER", comment: "Placeholder for new password text field.")
        }
    }
    
    @IBOutlet weak var confirmPasswordTextField: UITextField! {
        didSet {
            confirmPasswordTextField.placeholder = NSLocalizedString("CHANGE_PASSWORD_VIEW_CONFIRM_PASSWORD_TEXT_FIELD_PLACEHOLDER", comment: "Placeholder for confirm password text field.")
        }
    }
    
    @IBOutlet weak var changeButton: UIButton! {
        didSet {
            changeButton.setTitle(NSLocalizedString("CHANGE_PASSWORD_VIEW_CHANGE_BUTTON_TITLE", comment: "Title for 'change' button."), forState: .Normal)
        }
    }

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    lazy private(set) var changePasswordController: ChangePasswordController = {
        return ChangePasswordController()
    }()
}

extension ChangePasswordViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = NSLocalizedString("CHANGE_PASSWORD_VIEW_TITLE", comment: "Title for Change Password view.");
    }
}

extension ChangePasswordViewController {
    
    @IBAction func attemptChange(sender: AnyObject) {
        toggleElements(false)
        
        let currentPassword = currentPasswordTextField.text
        let newPassword = newPasswordTextField.text
        let confirmedPassword = confirmPasswordTextField.text
        if validateInput(currentPassword, newPassword: newPassword, confirmPassword: confirmedPassword) {
            changePasswordController.update(currentPassword!, newPassword: newPassword!, success: { [weak self] in
                self?.showSuccessAlert()
            }, failure: { [weak self] in
                self?.showFailureAlert()
            })
        } else {
            toggleElements(true)
        }
    }
}

extension ChangePasswordViewController {
    
    private func validateInput(currentPassword: String?, newPassword: String?, confirmPassword: String?) -> Bool {
        
        let (currentValidated, currentError) = PasswordValidator.validate(currentPassword)
        let (newValidated, newError) = PasswordValidator.validate(newPassword)
        let (confirmValidated, confirmError) = PasswordValidator.validate(confirmPassword)
        
        if currentValidated &&
            newValidated &&
            confirmValidated &&
            newPassword == confirmPassword {
            return true
        }
        
        if let message = currentError where !currentValidated {
            currentPasswordTextField.text = ""
            currentPasswordTextField.attributedPlaceholder = NSAttributedString(string: message, attributes: [NSForegroundColorAttributeName: Theme.Color.ChangePassword.errorPlaceholder])
        }
        if let message = newError where !newValidated {
            newPasswordTextField.text = ""
            newPasswordTextField.attributedPlaceholder = NSAttributedString(string: message, attributes: [NSForegroundColorAttributeName: Theme.Color.ChangePassword.errorPlaceholder])
        }
        if newPassword != confirmPassword {
            confirmPasswordTextField.text = ""
            let message = NSLocalizedString("CHANGE_PASSWORD_VIEW_CONFIRM_PASSWORD_TEXT_FIELD_PLACEHOLDER_REQUIREMENT", comment: "Placeholder for confirm password text field requirement.")
            confirmPasswordTextField.attributedPlaceholder = NSAttributedString(string: message, attributes: [NSForegroundColorAttributeName: Theme.Color.ChangePassword.errorPlaceholder])
        } else if let message = confirmError where !confirmValidated {
            confirmPasswordTextField.text = ""
            confirmPasswordTextField.attributedPlaceholder = NSAttributedString(string: message, attributes: [NSForegroundColorAttributeName: Theme.Color.ChangePassword.errorPlaceholder])
        }
        
        return false
    }
    
    private func toggleElements(enableInteraction: Bool) {
        currentPasswordTextField.enabled = enableInteraction
        newPasswordTextField.enabled = enableInteraction
        confirmPasswordTextField.enabled = enableInteraction
        let spinnerAction = enableInteraction ? spinner.stopAnimating : spinner.startAnimating
        spinnerAction()
        spinner.hidden = enableInteraction
        changeButton.enabled = enableInteraction
    }
    
    private func showSuccessAlert() {
        let title = NSLocalizedString("CHANGE_PASSWORD_VIEW_PASSWORD_CHANGE_SUCCESS_ALERT_TITLE", comment: "Title for alert displayed after password change succeeds.")
        let message = NSLocalizedString("CHANGE_PASSWORD_VIEW_PASSWORD_CHANGE_SUCCESS_ALERT_MESSAGE", comment: "Message for alert displayed after password change succeeds.")
        let dismissTitle = NSLocalizedString("CHANGE_PASSWORD_VIEW_PASSWORD_CHANGE_SUCCESS_ALERT_ACTION_TITLE_DISMISS", comment: "Title for alert action to dismiss alert displayed after password change succeeds.")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: dismissTitle, style: .Default, handler: { [weak self] (action) in
            dispatch_async(dispatch_get_main_queue(), {
                self?.navigationController!.popViewControllerAnimated(true);
            })
            })
        alertController.addAction(cancelAction)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    private func showFailureAlert() {
        let title = NSLocalizedString("CHANGE_PASSWORD_VIEW_PASSWORD_CHANGE_FAILURE_ALERT_TITLE", comment: "Title for alert displayed after password change fails.")
        let message = NSLocalizedString("CHANGE_PASSWORD_VIEW_PASSWORD_CHANGE_FAILURE_ALERT_MESSAGE", comment: "Message for alert displayed after password change fails.")
        let dismissTitle = NSLocalizedString("CHANGE_PASSWORD_VIEW_PASSWORD_CHANGE_FAILURE_ALERT_ACTION_TITLE_DISMISS", comment: "Title for alert action to dismiss alert displayed after password change fails.")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: dismissTitle, style: .Default, handler: { [unowned self] (action) in
            self.toggleElements(true)
            })
        alertController.addAction(cancelAction)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
}

extension ChangePasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
}
