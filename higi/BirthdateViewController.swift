//
//  BirthdateViewController.swift
//  higi
//
//  Created by Remy Panicker on 5/12/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class BirthdateViewController: UIViewController {
    
    @IBOutlet private var datePicker: UIDatePicker! {
        didSet {
            datePicker.date = birthdateController.defaultDate()
            datePicker.maximumDate = NSDate()
        }
    }
    
    @IBOutlet private var nextButton: UIButton! {
        didSet {
            nextButton.setTitle(NSLocalizedString("BIRTHDATE_VIEW_NEXT_BUTTON_TITLE", comment: "Title for 'next' button on birthdate view."), forState: .Normal)
        }
    }
    
    lazy private var spinner: CustomLoadingSpinner = {
        let spinner = CustomLoadingSpinner(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width / 2 - 16, UIScreen.mainScreen().bounds.size.height - 150 - self.topLayoutGuide.length, 32, 32))
        spinner.shouldAnimateFull = false
        return spinner
    }()
    
    /// Number of attempts to validate a birth date against service requirements.
    private var attempts = 0
    
    /// Maximum attempts a user can make to validate their birth date against service requirements.
    private let maximumAttempts = 2
    
    private(set) var userController: UserController!
    let birthdateController = BirthdateController()
    
    weak var delegate: BirthdateViewControllerDelegate?
    
    func configure(userController: UserController, delegate: BirthdateViewControllerDelegate) {
        self.delegate = delegate
        self.userController = userController
    }
}

// MARK: - View Lifecycle

extension BirthdateViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = NSLocalizedString("BIRTHDATE_VIEW_BIRTHDATE_ENTRY_TITLE", comment: "Title for birthdate view when asking user to enter their birthdate.")
        
        self.navigationItem.hidesBackButton = true
        
        spinner.hidden = true
        self.view.addSubview(spinner)
    }
}

// MARK: - UI Action

extension BirthdateViewController {
    
    @IBAction func didTapNextButton(sender: UIButton) {
        attemptToUpdateDateOfBirth()
    }
    
    private func attemptToUpdateDateOfBirth() {
        toggleElements(false)
        
        let date = datePicker.date
        if birthdateController.validateAge(date) {
            userController.update(date, success: { [weak self] in
                if let strongSelf = self {
                    strongSelf.updateUserSuccessHandler(strongSelf.userController)
                }
            }, failure: { [weak self] (error) in
                guard let strongSelf = self else { return }
                
                strongSelf.updateUserFailureHandler()
                dispatch_async(dispatch_get_main_queue(), { [weak strongSelf] in
                    strongSelf?.toggleElements(true)
                })
            })
        } else {
            attempts += 1
            if attempts == maximumAttempts {
                birthdateValidationFailureTermination()
            } else {
                birthDateValidationFailureRetry()
                toggleElements(true)
            }
        }
    }
}

extension BirthdateViewController {
    
    private func toggleElements(enableInteraction: Bool) {
        nextButton.enabled = enableInteraction
        datePicker.userInteractionEnabled = enableInteraction
        
        let spinnerAction = enableInteraction ? spinner.stopAnimating : spinner.startAnimating
        spinnerAction()
        spinner.hidden = enableInteraction
    }
}

// MARK: - Validation Handler

extension BirthdateViewController {
    
    private func birthDateValidationFailureRetry() {
        self.title = NSLocalizedString("BIRTHDATE_VIEW_AGE_CONFIRMATION_TITLE", comment: "Title for Birthdate view when confirming a user's age.")
        datePicker.date = birthdateController.defaultDate()
    }
    
    private func birthdateValidationFailureTermination() {
        let message = NSLocalizedString("BIRTHDATE_VIEW_UNDERAGE_ALERT_MESSAGE", comment: "Message for alert displayed when a user is ineligible for higi services due to age restrictions.")
        let buttonTitle = NSLocalizedString("BIRTHDATE_VIEW_UNDERAGE_ALERT_ACTION_TITLE_DISMISS", comment: "Title for alert action to dismiss the underage user alert.")
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: buttonTitle, style: .Default, handler: { (action) in
            // delete account
        })
        alertController.addAction(cancelAction)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
}

// MARK: - Update Handler

extension BirthdateViewController {
    
    private func updateUserSuccessHandler(userController: UserController) {
        delegate?.birthdateViewDidUpdate(self, userController: userController)
    }
    
    private func updateUserFailureHandler() {
        let message = NSLocalizedString("BIRTHDATE_VIEW_UPDATE_BIRTHDATE_FAILURE_ALERT_MESSAGE", comment: "Message for alert to display if the server cannot be reached when attempting to update user's birthdate.")
        let dismissTitle = NSLocalizedString("BIRTHDATE_VIEW_UPDATE_BIRTHDATE_FAILURE_ALERT_ACTION_TITLE_DISMISS", comment: "Title for alert action to dismiss the birthdate update failure alert.")
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: dismissTitle, style: .Default, handler: nil)
        alertController.addAction(cancelAction)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
}

// MARK: - Protocol

protocol BirthdateViewControllerDelegate: class {

    func birthdateViewDidUpdate(viewController: BirthdateViewController, userController: UserController)
    
    func birthdateViewDidFailUserIneligibleForService(viewController: BirthdateViewController, userController: UserController)
}
