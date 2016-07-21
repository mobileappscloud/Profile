//
//  SignUpNameViewController.swift
//  higi
//
//  Created by Remy Panicker on 5/5/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class SignUpNameViewController: UIViewController {

    @IBOutlet private weak var firstNameTextField: UITextField! {
        didSet {
            firstNameTextField.placeholder = NSLocalizedString("SIGN_UP_NAME_VIEW_FIRST_NAME_TEXT_FIELD_PLACEHOLDER", comment: "Placeholder for first name text field.")
        }
    }
    
    @IBOutlet private weak var lastNameTextField: UITextField! {
        didSet {
            lastNameTextField.placeholder = NSLocalizedString("SIGN_UP_NAME_VIEW_LAST_NAME_TEXT_FIELD_PLACEHOLDER", comment: "Placeholder for last name text field.")
        }
    }
    
    @IBOutlet private weak var nextButton: UIButton! {
        didSet {
            nextButton.setTitle(NSLocalizedString("SIGN_UP_NAME_VIEW_NEXT_BUTTON_TITLE", comment: "Title for 'next' button on sign up view."), forState: .Normal)
        }
    }
    
    lazy private var spinner: CustomLoadingSpinner = {
        let spinner = CustomLoadingSpinner(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width / 2 - 16, UIScreen.mainScreen().bounds.size.height - 150 - self.topLayoutGuide.length, 32, 32))
        spinner.shouldAnimateFull = false
        return spinner
    }()
    
    private(set) var userController: UserController!
    
    private(set) weak var delegate: SignUpNameViewControllerDelegate?
    
    func configure(userController: UserController, delegate: SignUpNameViewControllerDelegate) {
        self.userController = userController
        self.delegate = delegate
    }
}

// MARK: - View Lifecycle

extension SignUpNameViewController {
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("SIGN_UP_NAME_VIEW_TITLE", comment: "Title for Sign Up Name view.")
        self.navigationItem.hidesBackButton = true
        
        spinner.hidden = true
        self.view.addSubview(spinner)
        self.view.sendSubviewToBack(spinner)
        
        self.firstNameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
    }
}

// MARK: - UI Action

extension SignUpNameViewController {
    
    @IBAction func didTapNextButton(sender: UIButton) {
        
        toggleElements(false)
        
        let firstName = firstNameTextField.text
        let lastName = lastNameTextField.text
        if validateInput(firstName, lastName: lastName) {
            updateUser(firstName!, lastName: lastName!)
        } else {
            toggleElements(true)
        }
    }
    
    private func toggleElements(enableInteraction: Bool) {
        firstNameTextField.enabled = enableInteraction
        lastNameTextField.enabled = enableInteraction
        let spinnerAction = enableInteraction ? spinner.stopAnimating : spinner.startAnimating
        spinnerAction()
        spinner.hidden = enableInteraction
        nextButton.enabled = enableInteraction
    }
}

// MARK: - Validation

extension SignUpNameViewController {
    
    private func validateInput(firstName: String?, lastName: String?) -> Bool {
        
        let (validFirstName, firstNameError) = NameValidator.validate(firstName, type: .First)
        let (validLastName, lastNameErrorMessage) = NameValidator.validate(lastName, type: .Last)
        
        if validFirstName && validLastName {
            return true
        } else {
            if let message = firstNameError where !validFirstName {
                firstNameTextField.text = ""
                firstNameTextField.attributedPlaceholder = NSAttributedString(string: message, attributes: [NSForegroundColorAttributeName: Theme.Color.SignUp.Name.errorPlaceholder])
            } else {
                firstNameTextField.attributedPlaceholder = nil
                firstNameTextField.placeholder = NSLocalizedString("SIGN_UP_NAME_VIEW_FIRST_NAME_TEXT_FIELD_PLACEHOLDER", comment: "Placeholder for first name text field.")
            }
            if let message = lastNameErrorMessage where !validLastName {
                lastNameTextField.text = ""
                lastNameTextField.attributedPlaceholder = NSAttributedString(string: message, attributes: [NSForegroundColorAttributeName: Theme.Color.SignUp.Name.errorPlaceholder])
            } else {
                lastNameTextField.attributedPlaceholder = nil
                lastNameTextField.placeholder = NSLocalizedString("SIGN_UP_NAME_VIEW_LAST_NAME_TEXT_FIELD_PLACEHOLDER", comment: "Placeholder for last name text field.")
            }
            return false
        }
    }
}

// MARK: - Update User

extension SignUpNameViewController {

    private func updateUser(firstName: String, lastName: String) {
        userController.update(firstName, lastName: lastName, success: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.updateSuccessHandler(strongSelf.userController)
        }, failure: { [weak self] (error) in
            self?.updateFailureHandler()
        })
    }
    
    private func updateSuccessHandler(userController: UserController) {
        delegate?.signUpNameViewDidUpdate(self, userController: userController)
    }
    
    private func updateFailureHandler() {
        dispatch_async(dispatch_get_main_queue(), {
            self.toggleElements(true)
        })
        
    }
}

// MARK: - Protocol

protocol SignUpNameViewControllerDelegate: class {
    
    func signUpNameViewDidUpdate(viewController: SignUpNameViewController, userController: UserController)
}
