//
//  SignupEmailViewController.swift
//  higi
//
//  Created by Dan Harms on 6/13/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class SignupEmailViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var termsView: UIView!
    @IBOutlet weak var termsWebView: UIWebView!
    @IBOutlet weak var declineButton: UIButton!
    var spinner: CustomLoadingSpinner!
    var setup = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = "Sign Up";
        self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
        let urlRequest = NSMutableURLRequest(URL: NSURL(string: "\(HigiApi.webUrl)/termsandprivacy")!);
        urlRequest.addValue("mobile-ios", forHTTPHeaderField: "Higi-Source");
        termsWebView.loadRequest(urlRequest);

        spinner = CustomLoadingSpinner(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width / 2 - 16, UIScreen.mainScreen().bounds.size.height - 66, 32, 32));
        spinner.shouldAnimateFull = false;
        spinner.hidden = true;
        self.view.addSubview(spinner);
        self.view.sendSubviewToBack(spinner);
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        if (!setup) {
            self.navigationController!.navigationBar.hidden = false;
            declineButton.layer.borderWidth = 1;
            declineButton.layer.borderColor = UIColor.darkGrayColor().CGColor;
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
    
    @IBAction func attemptSignup(sender: AnyObject) {
        self.navigationItem.hidesBackButton = true;
        email.enabled = false;
        password.enabled = false;
        spinner.startAnimating();
        spinner.hidden = false;
        signupButton.enabled = false;
        self.navigationItem.leftBarButtonItem!.customView!.hidden = true;
        var problemFound = false;
        if (email.text!.characters.count == 0 || email.text!.rangeOfString("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$", options: NSStringCompareOptions.RegularExpressionSearch, range: nil, locale: nil) == nil) {
            problemFound = true;
            email.attributedPlaceholder = NSAttributedString(string: "Valid email required", attributes: [NSForegroundColorAttributeName: UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)]);
        } else {
            email.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: UIColor.lightGrayColor()]);
        }
        
        if (password.text!.characters.count < 6) {
            problemFound = true;
            password.attributedPlaceholder = NSAttributedString(string: "Password must be at least 6 characters", attributes: [NSForegroundColorAttributeName: UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)]);
        } else {
            password.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor.lightGrayColor()]);
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
                UIAlertView(title: "I knew you looked familiar...", message: "There is already a higi account with this email.", delegate: nil, cancelButtonTitle: "OK").show();
                self.reset(false);
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
                            
                            self.navigationController!.pushViewController(SignupNameViewController(nibName: "SignupNameView", bundle: nil), animated: true);
                            
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
        UIAlertView(title: "Something went wrong!", message: "There was an error in communicating with the server. Please try again.", delegate: nil, cancelButtonTitle: "OK").show();
        self.reset(false);
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
        self.navigationItem.leftBarButtonItem!.customView!.hidden = false;
    }
    
    @IBAction func decline(sender: AnyObject) {
        let splashViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SplashViewController") ;
        (UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController = splashViewController;
    }
    
    func goBack(sender: AnyObject!) {
        self.navigationController!.popViewControllerAnimated(true);
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
}