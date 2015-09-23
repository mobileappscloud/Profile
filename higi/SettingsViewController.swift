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
    var pictureChanged = false;
    
    // MARK: - View Lifecycle
    
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
        (self.navigationController as! MainNavigationController).drawerController?.selectRowAtIndex(5);
        updateNavBar();
        
        let hasPasscode = SessionData.Instance.pin != "";
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
        
        if (pictureChanged) {
            SessionData.Instance.user.profileImage = user.profileImage;
            SessionData.Instance.user.blurredImage = user.blurredImage;
            (self.navigationController as! MainNavigationController).drawerController.refreshData();
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        scrollView.contentSize = CGSize(width: scrollView.bounds.size.width, height: 853);
    }
    
    // MARK: - UI Actions
    
    @IBAction func newProfileImage(sender: AnyObject) {
        let profileViewController = ProfileImageViewController(nibName: "ProfileImageView", bundle: nil);
        profileViewController.fromSettings = true;
        self.navigationController!.pushViewController(profileViewController, animated: true);
    }

    @IBAction func resizeProfileImage(sender: AnyObject) {
        let modifyImageViewController = ModifyImageViewController(nibName: "ModifyImageView", bundle: nil);
        modifyImageViewController.profileImage = SessionData.Instance.user.fullProfileImage;
        modifyImageViewController.resizing = true;
        modifyImageViewController.fromSettings = true;
        self.navigationController!.pushViewController(modifyImageViewController, animated: true);
    }
    
    @IBAction func emailCheckins(sender: AnyObject) {
        let isOn = (sender as! UISwitch).on;
        let contents = NSMutableDictionary();
        let notifications = NSMutableDictionary();
        notifications.setObject(isOn ? "True" : "False", forKey: "EmailCheckins");
        contents.setObject(notifications, forKey: "Notifications");
        user.emailCheckins = isOn;
        HigiApi().sendPost("\(HigiApi.higiApiUrl)/data/user/\(user.userId)", parameters: contents, success: nil, failure: { operation, error in
            
            (sender as! UISwitch).on = !isOn;
            self.user.emailCheckins = !isOn;
            
            });
    }
    
    @IBAction func emailNews(sender: AnyObject) {
        let isOn = (sender as! UISwitch).on;
        let contents = NSMutableDictionary();
        let notifications = NSMutableDictionary();
        notifications.setObject(isOn ? "True" : "False", forKey: "EmailHigiNews");
        contents.setObject(notifications, forKey: "Notifications");
        user.emailHigiNews = isOn;
        HigiApi().sendPost("\(HigiApi.higiApiUrl)/data/user/\(user.userId)", parameters: contents, success: nil, failure: { operation, error in
                
                (sender as! UISwitch).on = !isOn;
                self.user.emailHigiNews = !isOn;
                
            });
    }
    
    @IBAction func didTapNotificationSettingsButton(sender: AnyObject) {
        resetColor(sender);
        let notificationSettingsViewController = UIStoryboard(name: "NotificationSettings", bundle: nil).instantiateInitialViewController() as UIViewController!;
        self.navigationController!.pushViewController(notificationSettingsViewController, animated: true);
    }
    
    @IBAction func changePasscode(sender: AnyObject) {
        resetColor(sender);
        let pinCodeViewController = PinCodeViewController(nibName: "PinCodeView", bundle: nil);
        pinCodeViewController.modifying = true;
        self.navigationController!.pushViewController(pinCodeViewController, animated: true);
    }
    
    @IBAction func passCodeSwitchChange(sender: AnyObject) {
        let pinCodeViewController = PinCodeViewController(nibName: "PinCodeView", bundle: nil);
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
        let webController = WebViewController(nibName: "WebView", bundle: nil);
        webController.url = "https://higi.com/terms";
        self.navigationController!.pushViewController(webController, animated: true);
    }
    
    @IBAction func showPrivacy(sender: AnyObject) {
        resetColor(sender);
        let webController = WebViewController(nibName: "WebView", bundle: nil);
        webController.url = "https://higi.com/privacy";
        self.navigationController!.pushViewController(webController, animated: true);
    }
    
    @IBAction func logout(sender: AnyObject) {
        resetColor(sender);
        SessionController.Instance.reset();
        SessionData.Instance.reset();
        SessionData.Instance.save();
        let splashViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SplashViewController") ;
        (UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController = splashViewController;
    }
    
    @IBAction func buttonTouched(sender: AnyObject) {
        (sender as! UIButton).backgroundColor = Utility.colorFromHexString("#EEEEEE");
    }
    
    @IBAction func resetColor(sender: AnyObject) {
        (sender as! UIButton).backgroundColor = UIColor.clearColor();
    }
    
    @IBAction func connectDevices(sender: AnyObject) {
        Flurry.logEvent("ConnectDevice_Pressed");
        self.navigationController!.pushViewController(ConnectDeviceViewController(nibName: "ConnectDeviceView", bundle: nil), animated: true);
        (sender as! UIButton).backgroundColor = Utility.colorFromHexString("#FFFFFF");
    }
    
    @IBAction func shareAction(sender: AnyObject) {
        Flurry.logEvent("BodystatShare_Pressed");
        let activityItems = ["higi_results.csv", exportData()];
        let shareScreen = UIActivityViewController(activityItems: activityItems, applicationActivities: nil);
        self.presentViewController(shareScreen, animated: true, completion: nil);
        (sender as! UIButton).backgroundColor = Utility.colorFromHexString("#FFFFFF");
    }
    
    // MARK: - Helper
    
    func exportData() -> NSURL {
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "MM/dd/yyy";
        var contents = "Date,Location,Address of higi Station,Systolic Pressure (mmHg),Diastolic Pressure (mmHg),Pulse (bpm),Mean Arterial Pressure (mmHg), Weight (lbs),Body Mass Index\n";
        
        for index in Array((0..<SessionController.Instance.checkins.count).reverse()) {
            let checkin = SessionController.Instance.checkins[index];
            var address = "", systolic = "", diastolic = "", pulse = "", map = "", weight = "", bmi = "";
            var organization = checkin.sourceVendorId!;
            if (checkin.kioskInfo != nil) {
                organization = checkin.kioskInfo!.organizations[0];
                address = "\"\(checkin.kioskInfo!.fullAddress)\"";
            }
            
            if (checkin.systolic != nil && checkin.pulseBpm != nil) {
                systolic = "\(checkin.systolic!)";
                diastolic = "\(checkin.diastolic!)";
                pulse = "\(checkin.pulseBpm!)";
                map = String(format: "%.1f", checkin.map!);
            }
            
            if (checkin.bmi != nil) {
                bmi = String(format: "%.2f", checkin.bmi!);
                weight = "\(Int(checkin.weightLbs!))";
            }
            
            let row = "\(dateFormatter.stringFromDate(checkin.dateTime)),\(organization),\(address),\(systolic),\(diastolic),\(pulse),\(map),\(weight),\(bmi)\n";
            contents += row;
        }
        
        let filePath = getShareFilePath();
        
        do {
            try contents.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
        } catch _ {
        };
        
        return NSURL(fileURLWithPath: filePath);
        
    }
    
    func getShareFilePath() -> String {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] + "higi_results.csv";
    }
    
    // MARK: - Scroll View
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateNavBar();
    }
    
    func updateNavBar() {
        let scrollY = scrollView.contentOffset.y;
        let alpha = min(scrollY / 100, 1);
        self.fakeNavBar.alpha = alpha;
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 1.0 - alpha, alpha: 1.0)];
        if (alpha < 0.5) {
            toggleButton!.setBackgroundImage(UIImage(named: "nav_ocmicon"), forState: UIControlState.Normal);
            toggleButton!.alpha = 1 - alpha;
            pointsMeter.setLightText();
            self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        } else {
            toggleButton!.setBackgroundImage(UIImage(named: "nav_ocmicon_inverted"), forState: UIControlState.Normal);
            toggleButton!.alpha = alpha;
            pointsMeter.setDarkText();
            self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
        }
    }
    
}