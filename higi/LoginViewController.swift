//
//  LoginViewController.swift
//  higi
//
//  Created by Dan Harms on 6/13/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation
import SafariServices

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var email : UITextField!
    @IBOutlet var password : UITextField!
    @IBOutlet var loginButton : UIButton! {
        didSet {
            loginButton.setTitle(NSLocalizedString("LOGIN_VIEW_LOGIN_BUTTON_TITLE", comment: "Title for login button."), forState: .Normal)
        }
    }
    @IBOutlet var forgotPassword: UIButton! {
        didSet {
            forgotPassword.setTitle(NSLocalizedString("LOGIN_VIEW_FORGOT_PASSWORD_BUTTON_TITLE", comment: "Title for forgot password button."), forState: .Normal)
        }
    }
    @IBOutlet var spinner: CustomLoadingSpinner!
    
    var setup = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = "Log In";
        
        spinner = CustomLoadingSpinner(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width / 2 - 16, UIScreen.mainScreen().bounds.size.height - 150 - self.topLayoutGuide.length, 32, 32))
        spinner.shouldAnimateFull = false;
        spinner.hidden = true;
        self.view.addSubview(spinner);
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        setup = true;
        self.email.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
    }
    
    @IBAction func loginClicked(sender: AnyObject) {
        spinner.startAnimating();
        spinner.hidden = false;
        loginButton.enabled = false;
        email.enabled = false;
        password.enabled = false;
        forgotPassword.enabled = false;
        let emailPlaceholder = NSLocalizedString("LOGIN_VIEW_EMAIL_TEXTFIELD_PLACEHOLDER", comment: "Placeholder for email text field on login view.")
        email.attributedPlaceholder = NSAttributedString(string: emailPlaceholder, attributes: [NSForegroundColorAttributeName: UIColor.lightGrayColor()]);
        let passwordPlaceholder = NSLocalizedString("LOGIN_VIEW_PASSWORD_TEXTFIELD_PLACEHOLDER", comment: "Placeholder for password text field on login view.")
        password.attributedPlaceholder = NSAttributedString(string: passwordPlaceholder, attributes: [NSForegroundColorAttributeName: UIColor.lightGrayColor()]);
        // TODO: regex does not support all character sets, check RFC for guidelines
        if (email.text!.characters.count == 0 || email.text!.rangeOfString("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$", options: NSStringCompareOptions.RegularExpressionSearch, range: nil, locale: nil) == nil) {
            let emailInvalidPlaceholder = NSLocalizedString("LOGIN_VIEW_EMAIL_TEXTFIELD_PLACEHOLDER_INVALID_INPUT", comment: "Placeholder for email text field with invalid input on login view.")
            email.attributedPlaceholder = NSAttributedString(string: emailInvalidPlaceholder, attributes: [NSForegroundColorAttributeName: UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)]);
            email.text = "";
            password.text = "";
            reset();
        } else if (password.text!.characters.count < 6) {
            let passwordInvalidPlaceholder = NSLocalizedString("LOGIN_VIEW_PASSWORD_TEXTFIELD_PLACEHOLDER_INVALID_INPUT", comment: "Placeholder for password text field with invalid input on login view.")
            password.attributedPlaceholder = NSAttributedString(string: passwordInvalidPlaceholder, attributes: [NSForegroundColorAttributeName: UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)]);
            password.text = "";
            reset();
        } else {
            let encodedEmail = CFURLCreateStringByAddingPercentEscapes(nil, email.text, nil, "!*'();:@&=+$,/?%#[]", CFStringBuiltInEncodings.UTF8.rawValue);
            let encodedPassword = CFURLCreateStringByAddingPercentEscapes(nil, password.text, nil, "!*'();:@&=+$,/?%#[]", CFStringBuiltInEncodings.UTF8.rawValue);
            let url = "\(HigiApi.higiApiUrl)/login/qlogin?email=\(encodedEmail)&password=\(encodedPassword)&getphoto=false&ttl=157852800";
            HigiApi().sendGet(url, success: {request, object in self.signInSuccess(request, responseObject: object)}, failure: {request, object in self.signInFailure(request, error: object)});
        }
    }
    
    func signInSuccess(operation: AFHTTPRequestOperation!, responseObject: AnyObject?) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let responseLogin = responseObject as? NSDictionary;
            if (responseLogin != nil) {
                let login = HigiLogin(dictionary: responseObject as! NSDictionary);
                SessionData.Instance.token = login.token as String;
                SessionData.Instance.user = login.user;
                SessionData.Instance.save();
                if (login.user != nil) {
                    ApiUtility.checkTermsAndPrivacy(self, success: { (terms, privacy) in
                        let user = SessionData.Instance.user;
                        let newTerms = terms != user.termsFile;
                        let newPrivacy = privacy != user.privacyFile;
                        if (newTerms || newPrivacy) {
                            let termsController = TermsViewController(nibName: "TermsView", bundle: nil);
                            termsController.newTerms = newTerms
                            termsController.newPrivacy = newPrivacy
                            termsController.termsFile = terms as String;
                            termsController.privacyFile = privacy as String;
                            self.presentViewController(termsController, animated: true, completion: nil);
                        } else if (user.firstName == nil || user.firstName == "" || user.lastName == nil || user.lastName == "") {
                            let nameViewController = SignupNameViewController(nibName: "SignupNameView", bundle: nil);
                            nameViewController.dashboardNext = true;
                            self.presentViewController(nameViewController, animated: true, completion: nil);
                        } else {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.spinner.stopAnimating();
                                self.dismissViewControllerAnimated(true, completion: nil)
                            })
                        }
                        
                        }, failure: self.termsAndPrivacyFailure)
                }
            } else {
                let title = NSLocalizedString("LOGIN_VIEW_LOG_IN_INVALID_CREDENTIALS_ALERT_TITLE", comment: "Title of alert which is displayed if a user is unable to log in due to invalid credentials.")
                let message = NSLocalizedString("LOGIN_VIEW_LOG_IN_INVALID_CREDENTIALS_ALERT_MESSAGE", comment: "Message of alert which is displayed if a user is unable to log in due to invalid credentials.")
                let dismissActionTitle = NSLocalizedString("LOGIN_VIEW_LOG_IN_INVALID_CREDENTIALS_ALERT_ACTION_TITLE_DISMISS", comment: "Title of alert action to dismiss the alert which is displayed if a user is unable to log in due to invalid credentials.")

                let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                let dismissAction = UIAlertAction(title: dismissActionTitle, style: .Default, handler: nil)
                alertController.addAction(dismissAction)
                dispatch_async(dispatch_get_main_queue(), {
                    self.presentViewController(alertController, animated: true, completion: {
                        self.reset()
                    })
                })
            }
        });
    }
    
    func termsAndPrivacyFailure() {
        let title = NSLocalizedString("LOGIN_VIEW_LOG_IN_NETWORK_CONNECTION_ISSUE_ALERT_TITLE", comment: "Title of alert which is displayed if a network connection issue occurs.")
        let message = NSLocalizedString("LOGIN_VIEW_LOG_IN_NETWORK_CONNECTION_ISSUE_ALERT_MESSAGE", comment: "Message of alert which is displayed if a network connection issue occurs.")
        let dismissActionTitle = NSLocalizedString("LOGIN_VIEW_LOG_IN_NETWORK_CONNECTION_ISSUE_ALERT_ACTION_TITLE_DISMISS", comment: "Title of alert action to dismiss the alert which is displayed if a network connection issue occurs.")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: dismissActionTitle, style: .Default, handler: nil)
        alertController.addAction(dismissAction)
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: {
                self.reset()
            })
        })
    }
    
    func signInFailure(operation: AFHTTPRequestOperation!, error: NSError?) {
        let errorCode = error!.code;
        self.navigationItem.hidesBackButton = false;

        let title: String!
        let message: String!
        let dismissTitle: String!
        if (errorCode == -1009 || errorCode == -1004 || errorCode == -1005) {
             title = NSLocalizedString("LOGIN_VIEW_LOG_IN_NETWORK_CONNECTION_ISSUE_ALERT_TITLE", comment: "Title of alert which is displayed if a network connection issue occurs.")
             message = NSLocalizedString("LOGIN_VIEW_LOG_IN_NETWORK_CONNECTION_ISSUE_ALERT_MESSAGE", comment: "Message of alert which is displayed if a network connection issue occurs.")
             dismissTitle = NSLocalizedString("LOGIN_VIEW_LOG_IN_NETWORK_CONNECTION_ISSUE_ALERT_ACTION_TITLE_DISMISS", comment: "Title of alert action to dismiss the alert which is displayed if a network connection issue occurs.")
        } else {
             title = NSLocalizedString("LOGIN_VIEW_LOG_IN_INVALID_CREDENTIALS_ALERT_TITLE", comment: "Title of alert which is displayed if a user is unable to log in due to invalid credentials.")
             message = NSLocalizedString("LOGIN_VIEW_LOG_IN_INVALID_CREDENTIALS_ALERT_MESSAGE", comment: "Message of alert which is displayed if a user is unable to log in due to invalid credentials.")
             dismissTitle = NSLocalizedString("LOGIN_VIEW_LOG_IN_INVALID_CREDENTIALS_ALERT_ACTION_TITLE_DISMISS", comment: "Title of alert action to dismiss the alert which is displayed if a user is unable to log in due to invalid credentials.")
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: dismissTitle, style: .Default, handler: nil)
        alertController.addAction(dismissAction)
        
        self.presentViewController(alertController, animated: true, completion: {
            self.reset()
        })
    }
    
    func reset() {
        self.navigationItem.hidesBackButton = true;
        spinner.stopAnimating();
        spinner.hidden = true;
        loginButton.enabled = true;
        email.enabled = true;
        password.enabled = true;
        forgotPassword.enabled = true;
    }
    
    @IBAction func forgotPasswordClicked(sender: AnyObject) {
        let URLString = "\(HigiApi.webUrl)/login/forgot_password"
        if #available(iOS 9.0, *) {
            let URL = NSURL(string: URLString)!
            let safariViewController = SFSafariViewController(URL: URL, entersReaderIfAvailable: false)
            self.navigationController?.presentViewController(safariViewController, animated: true, completion: nil)
        } else {
            let webController = WebViewController(nibName: "WebView", bundle: nil);
            webController.url = URLString
            self.navigationController?.pushViewController(webController, animated: true);
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
}
