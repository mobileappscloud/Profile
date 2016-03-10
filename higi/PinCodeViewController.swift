//
//  PinCodeViewController.swift
//  higi
//
//  Created by Dan Harms on 8/11/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation
import LocalAuthentication

class PinCodeViewController: UIViewController, UITextFieldDelegate {
    
    var touchIdCancelledNotification = "TouchIdCancelledNotification"
    var touchIdSuccessfulNotification = "TouchIdSuccessfulNotification"
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var pinField: UITextField!
    @IBOutlet weak var circleContainer: UIView!
    @IBOutlet weak var topTitle: UILabel! {
        didSet {
            topTitle.text = NSLocalizedString("PIN_CODE_VIEW_HEADER_TITLE_DEFAULT", comment: "Default header title for pin code view.")
        }
    }
    @IBOutlet weak var contents: UIView!
    
    var newCode = false, modifying = false, removing = false, confirming = false;
    
    var tempCode: String!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.navigationItem.hidesBackButton = true;
        if (newCode || modifying || removing) {
            let backButton = UIButton(type: UIButtonType.Custom);
            backButton.setBackgroundImage(UIImage(named: "btn_back_white.png"), forState: UIControlState.Normal);
            backButton.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside);
            backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
            let backBarItem = UIBarButtonItem(customView: backButton);
            self.navigationItem.leftBarButtonItem = backBarItem;
        }
        backgroundImage.image = SessionData.Instance.user.blurredImage;
        for circle in circleContainer.subviews {
            circle.layer.cornerRadius = 30;
            circle.layer.borderWidth = 1;
            circle.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3).CGColor;
        }
        
        if (newCode) {
            topTitle.text = NSLocalizedString("PIN_CODE_VIEW_HEADER_TITLE_DEFAULT", comment: "Default header title for pin code view.");
        } else if (modifying || removing) {
            topTitle.text = NSLocalizedString("PIN_CODE_VIEW_HEADER_TITLE_VERIFY", comment: "Header title for pin code view when verifying a code.");
        } else {
            topTitle.text = NSLocalizedString("PIN_CODE_VIEW_HEADER_TITLE_UNLOCK", comment: "Header title for pin code view when unlocking app.");
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "checkTouchId", name: UIApplicationWillEnterForegroundNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResignActive", name: UIApplicationWillResignActiveNotification, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"displayPinView", name: self.touchIdCancelledNotification, object:nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"closeView", name: self.touchIdSuccessfulNotification, object:nil);
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        checkTouchId();
    }
    
    func applicationWillResignActive() {
        if (self.contents.alpha > 0)
        {
            self.contents.alpha = 0.0;
            self.pinField.resignFirstResponder();
        }
    }
    
    func displayPinView() {
        dispatch_async(dispatch_get_main_queue(), {
            self.contents.alpha = 1.0
            self.pinField.becomeFirstResponder()
        })
    }
    
    func checkTouchId() {
        let authenticationContext = LAContext();
        
        if (SessionController.Instance.askTouchId && authenticationContext.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: nil)) {
            authenticationContext.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: NSLocalizedString("LOCAL_AUTHENTICATION_TOUCH_ID_REASON", comment: "Reason for prompting Touch ID local authentication."), reply: {success, error in
                if (success) {
                    NSNotificationCenter.defaultCenter().postNotificationName(self.touchIdSuccessfulNotification, object: nil);
                } else {
                    NSNotificationCenter.defaultCenter().postNotificationName(self.touchIdCancelledNotification, object: nil);
                }
            });

            SessionController.Instance.askTouchId = true;
        } else {
            self.contents.alpha = 1.0;
            self.pinField.becomeFirstResponder();
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return textField.text!.characters.count < 4 || string.characters.count == 0;
    }
    
    @IBAction func pinChanged(sender: AnyObject!) {
        
        for index in 0..<pinField.text!.characters.count {
            let circle = circleContainer.subviews[index];
            circle.layer.borderWidth = 20;
            circle.subviews.first!.hidden = false;
        }
        
        if (pinField.text!.characters.count < 4) {
            for index in pinField.text!.characters.count...3 {
                let circle = circleContainer.subviews[index];
                circle.layer.borderWidth = 1;
                circle.subviews.first!.hidden = true;
            }
        } else {
            if (newCode) {
                if (!confirming) {
                    confirming = true;
                    tempCode = pinField.text;
                    topTitle.text = NSLocalizedString("PIN_CODE_VIEW_HEADER_TITLE_VERIFY", comment: "Header title for pin code view when verifying a code.")
                    pinField.text = "";
                    pinChanged(nil);
                } else {
                    if (pinField.text == tempCode) {
                        SessionData.Instance.pin = pinField.text;
                        SessionData.Instance.save();
                        closeView();
                    } else {
                        didNotMatch();
                    }
                }
            } else {
                if (pinField.text == SessionData.Instance.pin) {
                    if (removing) {
                        SessionData.Instance.pin = "";
                        SessionData.Instance.save();
                        closeView();
                    } else if (modifying) {
                        topTitle.text = NSLocalizedString("PIN_CODE_VIEW_HEADER_TITLE_DEFAULT", comment: "Default header title for pin code view.")
                        newCode = true;
                        modifying = false;
                        pinField.text = "";
                        pinChanged(nil);
                    } else {
                        closeView();
                    }
                } else {
                    didNotMatch();
                }
            }
        }
    }
    
    func didNotMatch() {
        let title = NSLocalizedString("PIN_CODE_VIEW_PASSCODE_MISMATCH_ALERT_TITLE", comment: "Title for alert displayed if passcode does not match.");
        let message = NSLocalizedString("PIN_CODE_VIEW_PASSCODE_MISMATCH_ALERT_MESSAGE", comment: "Title for alert displayed if passcode does not match.");
        let dismissTitle = NSLocalizedString("PIN_CODE_VIEW_PASSCODE_MISMATCH_ALERT_ACTION_TITLE_DISMISS", comment: "Title for action to dismiss alert displayed if passcode does not match.");

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: dismissTitle, style: .Default, handler: nil)
        alertController.addAction(dismissAction)
        
        self.presentViewController(alertController, animated: true, completion: {
            self.navigationItem.hidesBackButton = true;
            self.pinField.text = "";
            self.pinChanged(nil);
        })
    }
    
    func closeView() {
        if (self.navigationController != nil) {
            self.navigationController!.popViewControllerAnimated(newCode || removing);
        } else {
            self.dismissViewControllerAnimated(false, completion: nil);
        }
    }
    
    func goBack(sender: AnyObject!) {
        self.navigationController!.popViewControllerAnimated(true);
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
    
    override func shouldAutorotate() -> Bool {
        return false;
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait;
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait;
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
}