//
//  SignupNameViewController.swift
//  higi
//
//  Created by Dan Harms on 6/13/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class SignupNameViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstName: UITextField! {
        didSet {
            firstName.placeholder = NSLocalizedString("SIGN_UP_NAME_VIEW_FIRST_NAME_TEXT_FIELD_PLACEHOLDER", comment: "Placeholder for first name text field.")
        }
    }
    @IBOutlet weak var lastName: UITextField! {
        didSet {
            lastName.placeholder = NSLocalizedString("SIGN_UP_NAME_VIEW_LAST_NAME_TEXT_FIELD_PLACEHOLDER", comment: "Placeholder for last name text field.")
        }
    }
    @IBOutlet weak var nextButton: UIButton! {
        didSet {
            nextButton.setTitle(NSLocalizedString("SIGN_UP_NAME_VIEW_NEXT_BUTTON_TITLE", comment: "Title for 'next' button on sign up view."), forState: .Normal)
        }
    }
    var spinner: CustomLoadingSpinner!
    
    weak var dismissOnSuccess: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = NSLocalizedString("SIGN_UP_NAME_VIEW_TITLE", comment: "Title for Sign Up Name view.");
        self.navigationItem.hidesBackButton = true;
        
        let user = SessionData.Instance.user;
        if (user.firstName != nil) {
            firstName.text = user.firstName as String;
        }
        if (user.lastName != nil) {
            lastName.text = user.lastName as String;
        }
        spinner = CustomLoadingSpinner(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width / 2 - 16, UIScreen.mainScreen().bounds.size.height - 150 - self.topLayoutGuide.length, 32, 32))
        spinner.shouldAnimateFull = false;
        spinner.hidden = true;
        self.view.addSubview(spinner);
        
        self.firstName.becomeFirstResponder()
    }
    
    @IBAction func gotoNext(sender: AnyObject) {
        nextButton.enabled = false;
        firstName.enabled = false;
        lastName.enabled = false;
        spinner.startAnimating();
        spinner.hidden = false;
        var problemFound = false;
        
        if (firstName.text!.characters.count == 0) {
            problemFound = true;
            firstName.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("SIGN_UP_NAME_VIEW_FIRST_NAME_TEXT_FIELD_PLACEHOLDER_REQUIREMENT", comment: "Placeholder for first name text field indicating name requirement."), attributes: [NSForegroundColorAttributeName: UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)]);
        }
        
        if (lastName.text!.characters.count == 0) {
            problemFound = true;
            lastName.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("SIGN_UP_NAME_VIEW_LAST_NAME_TEXT_FIELD_PLACEHOLDER_REQUIREMENT", comment: "Placeholder for last name text field indicating name requirement."), attributes: [NSForegroundColorAttributeName: UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)]);
        }
        
        if (!problemFound) {
            let user = SessionData.Instance.user;
            user.firstName = firstName.text;
            user.lastName = lastName.text;
            let contents = NSMutableDictionary();
            let notifications = NSMutableDictionary();
            notifications["EmailCheckins"] = "True";
            notifications["EmailHigiNews"] = "True";
            contents["firstName"] = firstName.text;
            contents["lastName"] = lastName.text;
            contents["Notifications"] = notifications;
            
            HigiApi().sendPost("\(HigiApi.higiApiUrl)/data/user/\(user.userId)", parameters: contents, success: {operation, responseObject in
                
                    if let viewController = self.dismissOnSuccess {
                        dispatch_async(dispatch_get_main_queue(), {
                            viewController.dismissViewControllerAnimated(true, completion: nil)
                        })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.navigationController?.pushViewController(BirthdateViewController(nibName: "BirthdateView", bundle: nil), animated: true);
                        })
                    }
                }, failure: {operation, error in
                    
                    let title = NSLocalizedString("SIGN_UP_NAME_VIEW_SERVER_COMMUNICATION_ERROR_ALERT_TITLE", comment: "Title for alert to display when server communication error occurs.")
                    let message = NSLocalizedString("SIGN_UP_NAME_VIEW_SERVER_COMMUNICATION_ERROR_ALERT_MESSAGE", comment: "Message for alert to display when server communication error occurs.")
                    let dismissTitle = NSLocalizedString("SIGN_UP_NAME_VIEW_SERVER_COMMUNICATION_ERROR_ALERT_ACTION_TITLE_DISMISS", comment: "Title for alert action to dismiss alert displayed when server communication error occurs.")
                    
                    let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                    let dismissAction = UIAlertAction(title: dismissTitle, style: .Default, handler: nil)
                    alertController.addAction(dismissAction)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentViewController(alertController, animated: true, completion: {
                            self.reset()
                        })
                    })
            });
        } else {
            reset();
        }
        
    }
    
    func reset() {
        self.navigationItem.hidesBackButton = true;
        firstName.enabled = true;
        lastName.enabled = true;
        nextButton.enabled = true;
        spinner.hidden = true;
        spinner.stopAnimating();
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
}