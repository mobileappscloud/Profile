
//
//  ChangePasswordViewController.swift
//  higi
//
//  Created by Dan Harms on 8/18/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class ChangePasswordViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = "Change Password";
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
            currentPassword.attributedPlaceholder = NSAttributedString(string: "Invalid password", attributes: [NSForegroundColorAttributeName: UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)]);
            problem = true;
            currentPassword.text = "";
            newPassword.text = "";
            confirmPassword.text = "";
        }
        
        if (newPassword.text!.characters.count < 6) {
            newPassword.attributedPlaceholder = NSAttributedString(string: "Must be at least 6 characters long", attributes: [NSForegroundColorAttributeName: UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)]);
            problem = true;
            newPassword.text = "";
            confirmPassword.text = "";
        }
        
        if (newPassword.text != confirmPassword.text) {
            confirmPassword.attributedPlaceholder = NSAttributedString(string: "Confirmed password does not match", attributes: [NSForegroundColorAttributeName: UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)]);
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
                    
                    UIAlertView(title: "Success!", message: "Your password has been changed", delegate: nil, cancelButtonTitle: "OK").show();
                    self.navigationController!.popViewControllerAnimated(true);
                    
                    }, failure: nil);
                
                
                }, failure: {request, object in
                    UIAlertView(title: "Incorrect password", message: "Your password did not match, please try again.", delegate: nil, cancelButtonTitle: "OK").show();
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
