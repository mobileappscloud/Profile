//
//  BirthdateViewController.swift
//  higi
//
//  Created by Dan Harms on 7/31/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class BirthdateViewController: UIViewController {
 
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var secondTry = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = "When were you born?";
        self.navigationItem.hidesBackButton = true;
        
        datePicker.maximumDate = NSDate();
    }
    
    @IBAction func gotoNext(sender: AnyObject) {
        nextButton.enabled = false;
        datePicker.enabled = false;
        spinner.hidden = false;
        
        var birthday = datePicker.date;
        
        var components = NSCalendar.currentCalendar().components(.YearCalendarUnit, fromDate: birthday, toDate: NSDate(), options: nil);
        
        var age = components.year;
        
        if (age < 13) {
            if (!secondTry) {
                secondTry = true;
                self.title = "Please confirm your age";
                reset();
            } else {
                UIAlertView(title: "", message: "We cannot offer you service at this time", delegate: nil, cancelButtonTitle: "OK").show();
                deleteAccountAndQuit();
            }
        } else {
            var user = SessionData.Instance.user;
            var dateFormatter = NSDateFormatter();
            dateFormatter.dateFormat = "MM/dd/yyyy";
            var contents = NSMutableDictionary();
            contents["dateOfBirth"] = dateFormatter.stringFromDate(birthday);
            HigiApi().sendPost("/data/user/\(user.userId)", parameters: contents, success: {operation, responseObject in
                
                self.navigationController!.pushViewController(ProfileImageViewController(nibName: "ProfileImageView", bundle: nil), animated: true);
                
                }, failure: {operation, error in
                    UIAlertView(title: "", message: "Unable to reach server. Please try again.", delegate: nil, cancelButtonTitle: "OK").show();
                    self.reset();
            });
        }
    }
    
    func reset() {
        self.navigationItem.hidesBackButton = true;
        nextButton.enabled = true;
        datePicker.enabled = true;
        spinner.hidden = true;
        datePicker.setDate(NSDate(), animated: true);
    }
    
    func deleteAccountAndQuit() {
        var user = SessionData.Instance.user;
        var dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "MM/dd/yyyy";
        HigiApi().sendGet("/data/deleteAccountAge13?userId=\(user.userId)&dob=\(dateFormatter.stringFromDate(datePicker.date))", success: nil, failure: nil);
        SessionController.Instance.reset();
        SessionData.Instance.reset();
        var splashViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SplashViewController") as UIViewController;
        (UIApplication.sharedApplication().delegate as AppDelegate).window?.rootViewController = splashViewController;
    }
    
}