//
//  SignupEmailViewController.swift
//  higi
//
//  Created by Dan Harms on 6/13/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation
import WebKit

class SignupEmailViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var email: UITextField! {
        didSet {
            email.placeholder = NSLocalizedString("SIGN_UP_EMAIL_VIEW_EMAIL_TEXT_FIELD_PLACEHOLDER", comment: "Placeholder for email text field.");
        }
    }
    @IBOutlet weak var password: UITextField! {
        didSet {
            password.placeholder = NSLocalizedString("SIGN_UP_EMAIL_VIEW_PASSWORD_TEXT_FIELD_PLACEHOLDER", comment: "Placeholder for password text field.");
        }
    }
    @IBOutlet weak var signupButton: UIButton! {
        didSet {
            signupButton.setTitle(NSLocalizedString("SIGN_UP_EMAIL_VIEW_SIGN_UP_BUTTON_TITLE", comment: "Title for sign up button."), forState: .Normal);
        }
    }
    @IBOutlet weak var termsView: UIView!
    @IBOutlet weak var termsWebView: WKWebView!
    @IBOutlet weak var declineButton: UIButton! {
        didSet {
            declineButton.setTitle(NSLocalizedString("SIGN_UP_EMAIL_VIEW_DECLINE_BUTTON_TITLE", comment: "Title for decline button."), forState: .Normal);
        }
    }
    var spinner: CustomLoadingSpinner!
    var setup = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = NSLocalizedString("SIGN_UP_EMAIL_VIEW_TITLE", comment: "Title for Sign Up Email view.");
        
        let urlRequest = NSMutableURLRequest(URL: NSURL(string: "\(HigiApi.webUrl)/termsandprivacy")!);
        urlRequest.addValue("mobile-ios", forHTTPHeaderField: "Higi-Source");
        termsWebView.loadRequest(urlRequest);

        spinner = CustomLoadingSpinner(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width / 2 - 16, UIScreen.mainScreen().bounds.size.height - 150 - self.topLayoutGuide.length, 32, 32))
        spinner.shouldAnimateFull = false;
        spinner.hidden = true;
        self.view.addSubview(spinner);
        self.view.sendSubviewToBack(spinner);
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        setup = true;
    }
    
    @IBAction func attemptSignup(sender: AnyObject) {
        self.navigationItem.hidesBackButton = true;
        email.enabled = false;
        password.enabled = false;
        spinner.startAnimating();
        spinner.hidden = false;
        signupButton.enabled = false;

        var problemFound = false;
        if (email.text!.characters.count == 0 || email.text!.rangeOfString("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$", options: NSStringCompareOptions.RegularExpressionSearch, range: nil, locale: nil) == nil) {
            problemFound = true;
            email.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("SIGN_UP_EMAIL_VIEW_EMAIL_TEXT_FIELD_PLACEHOLDER_REQUIREMENTS", comment: "Placeholder for email text field which indicates email requirements."), attributes: [NSForegroundColorAttributeName: UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)]);
        } else {
            email.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("SIGN_UP_EMAIL_VIEW_EMAIL_TEXT_FIELD_PLACEHOLDER", comment: "Placeholder for email text field."), attributes: [NSForegroundColorAttributeName: UIColor.lightGrayColor()]);
        }
        
        if (password.text!.characters.count < 6) {
            problemFound = true;
            password.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("SIGN_UP_EMAIL_VIEW_PASSWORD_TEXT_FIELD_PLACEHOLDER_REQUIREMENTS", comment: "Placeholder for password text field if password does not meet minimum requirements."), attributes: [NSForegroundColorAttributeName: UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)]);
        } else {
            password.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("SIGN_UP_EMAIL_VIEW_PASSWORD_TEXT_FIELD_PLACEHOLDER", comment: "Placeholder for password text field."), attributes: [NSForegroundColorAttributeName: UIColor.lightGrayColor()]);
        }
        
        if (!problemFound) {
            self.title = "";
            termsView.hidden = false;
        } else {
            reset(true);
        }
    }
    
    @IBAction func signup(sender: AnyObject) {
        termsView.hidden = true;
        let encodedEmail = CFURLCreateStringByAddingPercentEscapes(nil, email.text, nil, "!*'();:@&=+$,/?%#[]", CFStringBuiltInEncodings.UTF8.rawValue);
        let encodedPassword = CFURLCreateStringByAddingPercentEscapes(nil, password.text, nil, "!*'();:@&=+$,/?%#[]", CFStringBuiltInEncodings.UTF8.rawValue);
        HigiApi().sendGet("\(HigiApi.higiApiUrl)/data/emailUsed/\(encodedEmail)", success: {operation, responseObject in
            
            if (responseObject as! Bool) {
                let title = NSLocalizedString("SIGN_UP_EMAIL_VIEW_SIGN_UP_DUPLICATE_ACCOUNT_ALERT_TITLE", comment: "Title for alert displayed if a user attempts to create a duplicate account.")
                let message = NSLocalizedString("SIGN_UP_EMAIL_VIEW_SIGN_UP_DUPLICATE_ACCOUNT_ALERT_MESSAGE", comment: "Message for alert displayed if a user attempts to create a duplicate account.")
                let dismissTitle = NSLocalizedString("SIGN_UP_EMAIL_VIEW_SIGN_UP_DUPLICATE_ACCOUNT_ALERT_ACTION_TITLE_DISMISS", comment: "Title for alert action to dismiss alert displayed if a user attempts to create a duplicate account.")
                
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                let dismissAction = UIAlertAction(title: dismissTitle, style: .Default, handler: nil)
                alertController.addAction(dismissAction)
                dispatch_async(dispatch_get_main_queue(), {
                    self.presentViewController(alertController, animated: true, completion: {
                        self.reset(false)
                    })
                })
            } else {
                HigiApi().sendGet("\(HigiApi.webUrl)/termsinfo", success: {operation, responseObject in
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {

                        let termsInfo = responseObject as! NSDictionary;
                        
                        let termsFile = (termsInfo["termsFilename"] ?? "termsofuse_v7_08112014") as! NSString;
                        let privacyFile = (termsInfo["privacyFilename"] ?? "privacypolicy_v7_08112014") as! NSString;
                        
                        let dateFormatter = NSDateFormatter();
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ";
                        let agreedDate = dateFormatter.stringFromDate(NSDate());
                        
                        let contents = NSMutableDictionary();
                        let terms = NSMutableDictionary();
                        let privacy = NSMutableDictionary();
                        contents["email"] = self.email.text;
                        terms["termsFileName"] = termsFile;
                        terms["termsAgreedDate"] = agreedDate;
                        privacy["privacyFileName"] = privacyFile;
                        privacy["privacyAgreedDate"] = agreedDate;
                        contents["terms"] = terms;
                        contents["privacyAgreed"] = privacy;
                        HigiApi().sendPut("\(HigiApi.higiApiUrl)/data/user?password=\(encodedPassword)", parameters: contents, success: {operation, responseObject in
                            
                            let userInfo = responseObject as! NSDictionary;
                            
                            let user = HigiUser();
                            
                            user.userId = userInfo["id"] as! NSString;
                            
                            SessionData.Instance.user = user;
                            SessionData.Instance.token = userInfo["token"] as! String;
                            SessionData.Instance.save();
                            SessionController.Instance.checkins = [];
                            SessionController.Instance.activities = [:];
                            
                            self.navigationController?.pushViewController(SignupNameViewController(nibName: "SignupNameView", bundle: nil), animated: true);
                            
                            }, failure: {operation, error in
                                self.showErrorAlert();
                        });
                    });
                    
                    }, failure: {operation, error in
                        self.showErrorAlert();
                });
                
                
            }
            
            }, failure: {operation, error in
                self.showErrorAlert();
        });
        
    }
    
    func showErrorAlert() {
        let title = NSLocalizedString("SIGN_UP_EMAIL_VIEW_SERVER_COMMUNICATION_ERROR_ALERT_TITLE", comment: "Title for alert to display if there is a server communication error.")
        let message = NSLocalizedString("SIGN_UP_EMAIL_VIEW_SERVER_COMMUNICATION_ERROR_ALERT_MESSAGE", comment: "Message for alert to display if there is a server communication error.")
        let dismissTitle = NSLocalizedString("SIGN_UP_EMAIL_VIEW_SERVER_COMMUNICATION_ERROR_ALERT_ACTION_TITLE_DISMISS", comment: "Title for alert action to dismiss alert which is displayed if there is a server communication error.")

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: dismissTitle, style: .Default, handler: nil)
        alertController.addAction(dismissAction)
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: {
                self.reset(false)
            })
        })
    }
    
    func reset(clearFields: Bool) {
        self.navigationItem.hidesBackButton = true;
        if (clearFields) {
            email.text = "";
            password.text = "";
        }
        email.enabled = true;
        password.enabled = true;
        signupButton.enabled = true;
        spinner.hidden = true;
        spinner.stopAnimating();
        self.title = "Sign Up";
    }
    
    @IBAction func decline(sender: AnyObject) {
        let hostViewController = UIStoryboard(name: "Host", bundle: nil).instantiateInitialViewController()
        (UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController = hostViewController
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
}