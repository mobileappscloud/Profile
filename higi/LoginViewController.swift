//
//  LoginViewController.swift
//  higi
//
//  Created by Dan Harms on 6/13/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

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
        self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
        
        spinner = CustomLoadingSpinner(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width / 2 - 16, UIScreen.mainScreen().bounds.size.height - 100, 32, 32));
        spinner.shouldAnimateFull = false;
        spinner.hidden = true;
        self.view.addSubview(spinner);
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        if (!setup) {
            self.navigationController!.navigationBar.hidden = false;
            let backButton = UIButton(type: UIButtonType.Custom);
            backButton.setBackgroundImage(UIImage(named: "btn_back_black.png"), forState: UIControlState.Normal);
            backButton.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside);
            backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
            let backBarItem = UIBarButtonItem(customView: backButton);
            self.navigationItem.leftBarButtonItem = backBarItem;
            self.navigationItem.hidesBackButton = true;
        
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        setup = true;
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
        self.navigationItem.leftBarButtonItem!.customView!.hidden = true;
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
        let responseLogin = responseObject as? NSDictionary;
        if (responseLogin != nil) {
            let login = HigiLogin(dictionary: responseObject as! NSDictionary);
            SessionData.Instance.token = login.token as String;
            SessionData.Instance.user = login.user;
            SessionData.Instance.save();
            if (login.user != nil) {
                ApiUtility.checkTermsAndPrivacy(self, success: gotoDashboard, failure: {
                    let title = NSLocalizedString("LOGIN_VIEW_LOG_IN_NETWORK_CONNECTION_ISSUE_ALERT_TITLE", comment: "Title of alert which is displayed if a network connection issue occurs.")
                    let message = NSLocalizedString("LOGIN_VIEW_LOG_IN_NETWORK_CONNECTION_ISSUE_ALERT_MESSAGE", comment: "Message of alert which is displayed if a network connection issue occurs.")
                    let dismissAction = NSLocalizedString("LOGIN_VIEW_LOG_IN_NETWORK_CONNECTION_ISSUE_ALERT_ACTION_TITLE_DISMISS", comment: "Title of alert action to dismiss the alert which is displayed if a network connection issue occurs.")
                    UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: dismissAction).show();
                    self.reset();
                });
            }
        } else {
            let title = NSLocalizedString("LOGIN_VIEW_LOG_IN_INVALID_CREDENTIALS_ALERT_TITLE", comment: "Title of alert which is displayed if a user is unable to log in due to invalid credentials.")
            let message = NSLocalizedString("LOGIN_VIEW_LOG_IN_INVALID_CREDENTIALS_ALERT_MESSAGE", comment: "Message of alert which is displayed if a user is unable to log in due to invalid credentials.")
            let dismissAction = NSLocalizedString("LOGIN_VIEW_LOG_IN_INVALID_CREDENTIALS_ALERT_ACTION_TITLE_DISMISS", comment: "Title of alert action to dismiss the alert which is displayed if a user is unable to log in due to invalid credentials.")
            UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: dismissAction).show();
            reset();
        }
    }
    
    func signInFailure(operation: AFHTTPRequestOperation!, error: NSError?) {
        let errorCode = error!.code;
        self.navigationItem.hidesBackButton = false;
        var alert: UIAlertView;
        if (errorCode == -1009 || errorCode == -1004 || errorCode == -1005) {
            let title = NSLocalizedString("LOGIN_VIEW_LOG_IN_NETWORK_CONNECTION_ISSUE_ALERT_TITLE", comment: "Title of alert which is displayed if a network connection issue occurs.")
            let message = NSLocalizedString("LOGIN_VIEW_LOG_IN_NETWORK_CONNECTION_ISSUE_ALERT_MESSAGE", comment: "Message of alert which is displayed if a network connection issue occurs.")
            let dismissAction = NSLocalizedString("LOGIN_VIEW_LOG_IN_NETWORK_CONNECTION_ISSUE_ALERT_ACTION_TITLE_DISMISS", comment: "Title of alert action to dismiss the alert which is displayed if a network connection issue occurs.")
            alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: dismissAction);
        } else {
            let title = NSLocalizedString("LOGIN_VIEW_LOG_IN_INVALID_CREDENTIALS_ALERT_TITLE", comment: "Title of alert which is displayed if a user is unable to log in due to invalid credentials.")
            let message = NSLocalizedString("LOGIN_VIEW_LOG_IN_INVALID_CREDENTIALS_ALERT_MESSAGE", comment: "Message of alert which is displayed if a user is unable to log in due to invalid credentials.")
            let dismissAction = NSLocalizedString("LOGIN_VIEW_LOG_IN_INVALID_CREDENTIALS_ALERT_ACTION_TITLE_DISMISS", comment: "Title of alert action to dismiss the alert which is displayed if a user is unable to log in due to invalid credentials.")
            UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: dismissAction).show();
            alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: dismissAction);
        }
        alert.show();
        reset();
    }
    
    func reset() {
        self.navigationItem.hidesBackButton = true;
        spinner.stopAnimating();
        spinner.hidden = true;
        loginButton.enabled = true;
        email.enabled = true;
        password.enabled = true;
        forgotPassword.enabled = true;
        self.navigationItem.leftBarButtonItem!.customView!.hidden = false;
    }
    
    func gotoDashboard() {
        if (SessionController.Instance.checkins != nil && SessionController.Instance.challenges != nil && SessionController.Instance.kioskList != nil && SessionController.Instance.pulseArticles.count > 0) {
            spinner.stopAnimating();
            (UIApplication.sharedApplication().delegate as! AppDelegate).startLocationManager();
            Utility.gotoDashboard(self);
        }
    }
    
    @IBAction func forgotPasswordClicked(sender: AnyObject) {
        let webController = WebViewController(nibName: "WebView", bundle: nil);
        webController.url = "\(HigiApi.webUrl)/login/forgot_password";
        self.navigationController!.pushViewController(webController, animated: true);
    }
    
    func goBack(sender: AnyObject!) {
        self.navigationController!.popViewControllerAnimated(true);
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
       
}