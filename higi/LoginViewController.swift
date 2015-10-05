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
    @IBOutlet var loginButton : UIButton!
    @IBOutlet var forgotPassword: UIButton!
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
        email.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: UIColor.lightGrayColor()]);
        password.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor.lightGrayColor()]);
        if (email.text!.characters.count == 0 || email.text!.rangeOfString("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$", options: NSStringCompareOptions.RegularExpressionSearch, range: nil, locale: nil) == nil) {
            email.attributedPlaceholder = NSAttributedString(string: "Valid email required", attributes: [NSForegroundColorAttributeName: UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)]);
            email.text = "";
            password.text = "";
            reset();
        } else if (password.text!.characters.count < 6) {
            password.attributedPlaceholder = NSAttributedString(string: "Password must be at least 6 characters", attributes: [NSForegroundColorAttributeName: UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)]);
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
                    ApiUtility.checkTermsAndPrivacy(self, success: self.gotoDashboard, failure: {
                        UIAlertView(title: "Unable to connect to server", message: "Please check your network connection and try again.", delegate: nil, cancelButtonTitle: "OK").show();
                        self.reset();
                    });
                }
            } else {
                UIAlertView(title: "Invalid credentials", message: "Please check your email and password and try again.", delegate: nil, cancelButtonTitle: "OK").show();
                self.reset();
            }
        });
    }
    
    func signInFailure(operation: AFHTTPRequestOperation!, error: NSError?) {
        let errorCode = error!.code;
        self.navigationItem.hidesBackButton = false;
        var alert: UIAlertView;
        if (errorCode == -1009 || errorCode == -1004 || errorCode == -1005) {
            alert = UIAlertView(title: "Unable to connect to server", message: "Please check your network connection and try again.", delegate: nil, cancelButtonTitle: "OK");
        } else {
            alert = UIAlertView(title: "Invalid credentials", message: "Please check your email and password and try again.", delegate: nil, cancelButtonTitle: "OK");
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