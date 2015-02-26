//
//  SettingsViewController.swift
//  higi
//
//  Created by Dan Harms on 8/4/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class SettingsViewController: BaseViewController, UIScrollViewDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var blurredImage: UIImageView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var resizeButton: UIButton!
    @IBOutlet var newButton: UIButton!
    
    @IBOutlet var emailCheckinsSwitch: UISwitch!
    @IBOutlet var emailNewsSwitch: UISwitch!
    @IBOutlet weak var changePasscodeLabel: UILabel!
    @IBOutlet weak var changePasscode: UIButton!
    @IBOutlet var passcodeSwitch: UISwitch!
    @IBOutlet weak var versionNumber: UILabel!
    
    var user = SessionData.Instance.user;
    
    override func viewDidLoad()  {
        super.viewDidLoad();
        self.title = "Settings";
        
        profileImage.layer.borderColor = UIColor.whiteColor().CGColor;
        resizeButton.layer.borderColor = UIColor.whiteColor().CGColor;
        newButton.layer.borderColor = UIColor.whiteColor().CGColor;
        
        profileImage.layer.borderWidth = 1.0;
        resizeButton.layer.borderWidth = 1.0;
        newButton.layer.borderWidth = 1.0;
        
        emailCheckinsSwitch.on = user.emailCheckins;
        emailNewsSwitch.on = user.emailHigiNews;
        
        versionNumber.text = "Version \(Utility.appVersion()).\(Utility.appBuild())";
        
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        updateNavBar();
        var hasPasscode = SessionData.Instance.pin != "";
        passcodeSwitch.on = hasPasscode
        changePasscode.enabled = hasPasscode;
        if (hasPasscode) {
            changePasscodeLabel.textColor = UIColor.blackColor();
        } else {
            changePasscodeLabel.textColor = UIColor.lightGrayColor();
        }
        resizeButton.enabled = SessionData.Instance.user.hasPhoto;
        blurredImage.image = user.blurredImage;
        profileImage.image = user.profileImage;
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        scrollView.contentSize = CGSize(width: scrollView.bounds.size.width, height: 698);
    }
    
    @IBAction func newProfileImage(sender: AnyObject) {
        var profileViewController = ProfileImageViewController(nibName: "ProfileImageView", bundle: nil);
        profileViewController.fromSettings = true;
        self.navigationController!.pushViewController(profileViewController, animated: true);
    }

    @IBAction func resizeProfileImage(sender: AnyObject) {
        var modifyImageViewController = ModifyImageViewController(nibName: "ModifyImageView", bundle: nil);
        modifyImageViewController.profileImage = SessionData.Instance.user.fullProfileImage;
        modifyImageViewController.resizing = true;
        modifyImageViewController.fromSettings = true;
        self.navigationController!.pushViewController(modifyImageViewController, animated: true);
    }
    
    @IBAction func emailCheckins(sender: AnyObject) {
        var isOn = (sender as UISwitch).on;
        var contents = NSMutableDictionary();
        var notifications = NSMutableDictionary();
        notifications.setObject(isOn ? "True" : "False", forKey: "EmailCheckins");
        contents.setObject(notifications, forKey: "Notifications");
        user.emailCheckins = isOn;
        HigiApi().sendPost("\(HigiApi.higiApiUrl)/data/user/\(user.userId)", parameters: contents, success: nil, failure: { operation, error in
            
            (sender as UISwitch).on = !isOn;
            self.user.emailCheckins = !isOn;
            
            });
    }
    
    @IBAction func emailNews(sender: AnyObject) {
        var isOn = (sender as UISwitch).on;
        var contents = NSMutableDictionary();
        var notifications = NSMutableDictionary();
        notifications.setObject(isOn ? "True" : "False", forKey: "EmailHigiNews");
        contents.setObject(notifications, forKey: "Notifications");
        user.emailHigiNews = isOn;
        HigiApi().sendPost("\(HigiApi.higiApiUrl)/data/user/\(user.userId)", parameters: contents, success: nil, failure: { operation, error in
                
                (sender as UISwitch).on = !isOn;
                self.user.emailHigiNews = !isOn;
                
            });
    }
    
    @IBAction func changePasscode(sender: AnyObject) {
        resetColor(sender);
        var pinCodeViewController = PinCodeViewController(nibName: "PinCodeView", bundle: nil);
        pinCodeViewController.modifying = true;
        self.navigationController!.pushViewController(pinCodeViewController, animated: true);
    }
    
    @IBAction func passCodeSwitchChange(sender: AnyObject) {
        var pinCodeViewController = PinCodeViewController(nibName: "PinCodeView", bundle: nil);
        if (passcodeSwitch.on) {
            Flurry.logEvent("CreatePasscode_Pressed");
            pinCodeViewController.newCode = true;
        } else {
            pinCodeViewController.removing = true;
        }
        self.navigationController!.pushViewController(pinCodeViewController, animated: true);
    }
    
    @IBAction func changePassword(sender: AnyObject) {
        resetColor(sender);
        self.navigationController!.pushViewController(ChangePasswordViewController(nibName: "ChangePasswordView", bundle: nil), animated: true);
    }
    
    @IBAction func showTerms(sender: AnyObject) {
        resetColor(sender);
        var webController = WebViewController(nibName: "WebView", bundle: nil);
        webController.url = "https://higi.com/terms";
        self.navigationController!.pushViewController(webController, animated: true);
    }
    
    @IBAction func showPrivacy(sender: AnyObject) {
        resetColor(sender);
        var webController = WebViewController(nibName: "WebView", bundle: nil);
        webController.url = "https://higi.com/privacy";
        self.navigationController!.pushViewController(webController, animated: true);
    }
    
    
    @IBAction func logout(sender: AnyObject) {
        resetColor(sender);
        SessionController.Instance.reset();
        SessionData.Instance.reset();
        SessionData.Instance.save();
        var splashViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SplashViewController") as UIViewController;
        (UIApplication.sharedApplication().delegate as AppDelegate).window?.rootViewController = splashViewController;
    }
    
    @IBAction func buttonTouched(sender: AnyObject) {
        (sender as UIButton).backgroundColor = Utility.colorFromHexString("#EEEEEE");
    }
    
    @IBAction func resetColor(sender: AnyObject) {
        (sender as UIButton).backgroundColor = UIColor.clearColor();
    }
    
    @IBAction func connectDevices(sender: AnyObject) {
        Flurry.logEvent("ConnectDevice_Pressed");
        self.navigationController!.pushViewController(ConnectDeviceViewController(nibName: "ConnectDeviceView", bundle: nil), animated: true);
        (sender as UIButton).backgroundColor = Utility.colorFromHexString("#FFFFFF");
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView!) {
        updateNavBar();
    }
    
    func updateNavBar() {
        var scrollY = scrollView.contentOffset.y;
        var alpha = min(scrollY / 100, 1);
        self.fakeNavBar.alpha = alpha;
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 1.0 - alpha, alpha: 1.0)];
        if (alpha < 0.5) {
            toggleButton!.setBackgroundImage(UIImage(named: "nav_ocmicon"), forState: UIControlState.Normal);
            toggleButton!.alpha = 1 - alpha;
            self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        } else {
            toggleButton!.setBackgroundImage(UIImage(named: "nav_ocmicon_inverted"), forState: UIControlState.Normal);
            toggleButton!.alpha = alpha;
            self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
        }
    }
    
}