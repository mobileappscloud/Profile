
//
//  ChangePasswordViewController.swift
//  higi
//
//  Created by Dan Harms on 8/18/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class ChangePasswordViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var currentPassword: UITextField! {
        didSet {
            currentPassword.placeholder = NSLocalizedString("CHANGE_PASSWORD_VIEW_CURRENT_PASSWORD_TEXT_FIELD_PLACEHOLDER", comment: "Placeholder for current password text field.")
        }
    }
    @IBOutlet weak var newPassword: UITextField! {
        didSet {
            newPassword.placeholder = NSLocalizedString("CHANGE_PASSWORD_VIEW_NEW_PASSWORD_TEXT_FIELD_PLACEHOLDER", comment: "Placeholder for new password text field.")
        }
    }
    @IBOutlet weak var confirmPassword: UITextField! {
        didSet {
            confirmPassword.placeholder = NSLocalizedString("CHANGE_PASSWORD_VIEW_CONFIRM_PASSWORD_TEXT_FIELD_PLACEHOLDER", comment: "Placeholder for confirm password text field.")
        }
    }
    @IBOutlet weak var changeButton: UIButton! {
        didSet {
            changeButton.setTitle(NSLocalizedString("CHANGE_PASSWORD_VIEW_CHANGE_BUTTON_TITLE", comment: "Title for 'change' button."), forState: .Normal)
        }
    }
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = NSLocalizedString("CHANGE_PASSWORD_VIEW_TITLE", comment: "Title for Change Password view.");
        self.navigationController!.navigationBar.barStyle = .Default;
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()];
        (self.navigationController as! MainNavigationController).revealController.panGestureRecognizer().enabled = false;
        let backButton = UIButton(type: UIButtonType.Custom);
        backButton.setBackgroundImage(UIImage(named: "btn_back_black.png"), forState: UIControlState.Normal);
        backButton.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside);
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        let backBarItem = UIBarButtonItem(customView: backButton);
        self.navigationItem.leftBarButtonItem = backBarItem;
        self.navigationItem.hidesBackButton = true;
    }
    
    @IBAction func attemptChange(sender: AnyObject) {
        currentPassword.enabled = false;
        newPassword.enabled = false;
        confirmPassword.enabled = false;
        changeButton.enabled = false;
        spinner.hidden = false;
        self.navigationItem.leftBarButtonItem!.customView!.hidden = true;
        
        var problem = false;
        
        if (currentPassword.text!.characters.count < 6) {
            currentPassword.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("CHANGE_PASSWORD_VIEW_CURRENT_PASSWORD_TEXT_FIELD_PLACEHOLDER_REQUIREMENT", comment: "Placeholder for current password text field requirement."), attributes: [NSForegroundColorAttributeName: UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)]);
            problem = true;
            currentPassword.text = "";
            newPassword.text = "";
            confirmPassword.text = "";
        }
        
        if (newPassword.text!.characters.count < 6) {
            newPassword.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("CHANGE_PASSWORD_VIEW_NEW_PASSWORD_TEXT_FIELD_PLACEHOLDER_REQUIREMENT", comment: "Placeholder for new password text field requirement."), attributes: [NSForegroundColorAttributeName: UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)]);
            problem = true;
            newPassword.text = "";
            confirmPassword.text = "";
        }
        
        if (newPassword.text != confirmPassword.text) {
            confirmPassword.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("CHANGE_PASSWORD_VIEW_CONFIRM_PASSWORD_TEXT_FIELD_PLACEHOLDER_REQUIREMENT", comment: "Placeholder for confirm password text field requirement."), attributes: [NSForegroundColorAttributeName: UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)]);
            problem = true;
            newPassword.text = "";
            confirmPassword.text = "";
        }
        
        if (problem) {
            reset();
        } else {
            var user = SessionData.Instance.user;
            var encodedEmail = CFURLCreateStringByAddingPercentEscapes(nil, user.email, nil, "!*'();:@&=+$,/?%#[]", CFStringBuiltInEncodings.UTF8.rawValue);
            var encodedCurrentPassword = CFURLCreateStringByAddingPercentEscapes(nil, currentPassword.text, nil, "!*'();:@&=+$,/?%#[]", CFStringBuiltInEncodings.UTF8.rawValue);
            var encodedNewPassword = CFURLCreateStringByAddingPercentEscapes(nil, newPassword.text, nil, "!*'();:@&=+$,/?%#[]", CFStringBuiltInEncodings.UTF8.rawValue);
            
            HigiApi().sendGet("\(HigiApi.higiApiUrl)/login/login?email=\(encodedEmail)&password=\(encodedCurrentPassword)&getphoto=false&ttl=157852800", success: {request,responseObject in
                
                HigiApi().sendGet("\(HigiApi.higiApiUrl)/login/setPassword?id=\(user.userId)&token=\(SessionData.Instance.token)&password=\(encodedNewPassword)", success: {operation, responseObject in
                    
                    let title = NSLocalizedString("CHANGE_PASSWORD_VIEW_PASSWORD_CHANGE_SUCCESS_ALERT_TITLE", comment: "Title for alert displayed after password change succeeds.")
                    let message = NSLocalizedString("CHANGE_PASSWORD_VIEW_PASSWORD_CHANGE_SUCCESS_ALERT_MESSAGE", comment: "Message for alert displayed after password change succeeds.")
                    let dismissTitle = NSLocalizedString("CHANGE_PASSWORD_VIEW_PASSWORD_CHANGE_SUCCESS_ALERT_ACTION_TITLE_DISMISS", comment: "Title for alert action to dismiss alert displayed after password change succeeds.")
                    
                    UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: dismissTitle).show();
                    self.navigationController!.popViewControllerAnimated(true);
                    
                    }, failure: nil);
                
                
                }, failure: {request, object in
                    
                    let title = NSLocalizedString("CHANGE_PASSWORD_VIEW_PASSWORD_CHANGE_FAILURE_ALERT_TITLE", comment: "Title for alert displayed after password change fails.")
                    let message = NSLocalizedString("CHANGE_PASSWORD_VIEW_PASSWORD_CHANGE_FAILURE_ALERT_MESSAGE", comment: "Message for alert displayed after password change fails.")
                    let dismissTitle = NSLocalizedString("CHANGE_PASSWORD_VIEW_PASSWORD_CHANGE_FAILURE_ALERT_ACTION_TITLE_DISMISS", comment: "Title for alert action to dismiss alert displayed after password change fails.")
                    
                    UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: dismissTitle).show();
                    self.reset();
            });
            
        }
        
    }
    
    func reset() {
        currentPassword.enabled = true;
        newPassword.enabled = true;
        confirmPassword.enabled = true;
        changeButton.enabled = true;
        spinner.hidden = true;
        self.navigationItem.leftBarButtonItem!.customView!.hidden = false;
        self.navigationItem.hidesBackButton = true;
    }
    
    func goBack(sender: AnyObject!) {
        self.navigationController!.popViewControllerAnimated(true);
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
}
