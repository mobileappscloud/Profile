//
//  SignupNameViewController.swift
//  higi
//
//  Created by Dan Harms on 6/13/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class SignupNameViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    var spinner: CustomLoadingSpinner!
    
    var dashboardNext = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = "What's your name?";
        self.navigationItem.hidesBackButton = true;
        
        let user = SessionData.Instance.user;
        if (user.firstName != nil) {
            firstName.text = user.firstName as String;
        }
        if (user.lastName != nil) {
            lastName.text = user.lastName as String;
        }
        spinner = CustomLoadingSpinner(frame: CGRectMake(self.view.frame.size.width / 2 - 16, UIScreen.mainScreen().bounds.size.height - 66, 32, 32));
        spinner.shouldAnimateFull = false;
        spinner.hidden = true;
        self.view.addSubview(spinner);
    }
    
    @IBAction func gotoNext(sender: AnyObject) {
        nextButton.enabled = false;
        firstName.enabled = false;
        lastName.enabled = false;
        spinner.startAnimating();
        spinner.hidden = false;
        var problemFound = false;
        
        if (firstName.text!.characters.count == 0) {
            problemFound = true;
            firstName.attributedPlaceholder = NSAttributedString(string: "First name is required", attributes: [NSForegroundColorAttributeName: UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)]);
        }
        
        if (lastName.text!.characters.count == 0) {
            problemFound = true;
            lastName.attributedPlaceholder = NSAttributedString(string: "Last name is required", attributes: [NSForegroundColorAttributeName: UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)]);
        }
        
        if (!problemFound) {
            var user = SessionData.Instance.user;
            user.firstName = firstName.text;
            user.lastName = lastName.text;
            var contents = NSMutableDictionary();
            var notifications = NSMutableDictionary();
            notifications["EmailCheckins"] = "True";
            notifications["EmailHigiNews"] = "True";
            contents["firstName"] = firstName.text;
            contents["lastName"] = lastName.text;
            contents["Notifications"] = notifications;
            
            HigiApi().sendPost("\(HigiApi.higiApiUrl)/data/user/\(user.userId)", parameters: contents, success: {operation, responseObject in
                
                    if (self.dashboardNext) {
                        ApiUtility.initializeApiData();
                        Utility.gotoDashboard(self);
                    } else {
                        self.navigationController!.pushViewController(BirthdateViewController(nibName: "BirthdateView", bundle: nil), animated: true);
                    }
                }, failure: {operation, error in
                    
                    UIAlertView(title: "Something went wrong!", message: "There was an error in communicating with the server. Please try again.", delegate: nil, cancelButtonTitle: "OK").show();
                    self.reset();
            });
        } else {
            reset();
        }
        
    }
    
    func reset() {
        self.navigationItem.hidesBackButton = true;
        firstName.enabled = true;
        lastName.enabled = true;
        nextButton.enabled = true;
        spinner.hidden = true;
        spinner.stopAnimating();
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
}