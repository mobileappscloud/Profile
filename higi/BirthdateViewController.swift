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
    @IBOutlet weak var nextButton: UIButton! {
        didSet {
            nextButton.setTitle(NSLocalizedString("BIRTHDATE_VIEW_NEXT_BUTTON_TITLE", comment: "Title for 'next' button on birthdate view."), forState: .Normal);
        }
    }
    var spinner: CustomLoadingSpinner!
    var secondTry = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = NSLocalizedString("BIRTHDATE_VIEW_BIRTHDATE_ENTRY_TITLE", comment: "Title for birthdate view when asking user to enter their birthdate.")
        self.navigationItem.hidesBackButton = true;
        
        datePicker.maximumDate = NSDate();
        
        spinner = CustomLoadingSpinner(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width / 2 - 16, UIScreen.mainScreen().bounds.size.height - 150 - self.topLayoutGuide.length, 32, 32))
        spinner.shouldAnimateFull = false;
        spinner.hidden = true;
        self.view.addSubview(spinner);
    }
    
    @IBAction func gotoNext(sender: AnyObject) {
        nextButton.enabled = false;
        datePicker.enabled = false;
        spinner.startAnimating();
        spinner.hidden = false;
        
        let birthday = datePicker.date;
        
        let components = NSCalendar.currentCalendar().components(.NSYearCalendarUnit, fromDate: birthday, toDate: NSDate(), options: []);
        
        let age = components.year;
        
        if (age < 13) {
            if (!secondTry) {
                secondTry = true;
                self.title = NSLocalizedString("BIRTHDATE_VIEW_AGE_CONFIRMATION_TITLE", comment: "Title for Birthdate view when confirming a user's age.");
                reset();
            } else {
                let message = NSLocalizedString("BIRTHDATE_VIEW_UNDERAGE_ALERT_MESSAGE", comment: "Message for alert displayed when a user is ineligible for higi services due to age restrictions.")
                let buttonTitle = NSLocalizedString("BIRTHDATE_VIEW_UNDERAGE_ALERT_ACTION_TITLE_DISMISS", comment: "Title for alert action to dismiss the underage user alert.")
                let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: buttonTitle, style: .Default, handler: { [unowned self] (action) in
                        self.deleteAccountAndQuit();
                })
                alertController.addAction(cancelAction)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }
        } else {
            let user = SessionData.Instance.user;
            let dateFormatter = NSDateFormatter();
            dateFormatter.dateFormat = "MM/dd/yyyy";
            let contents = NSMutableDictionary();
            contents["dateOfBirth"] = dateFormatter.stringFromDate(birthday);
            HigiApi().sendPost("\(HigiApi.higiApiUrl)/data/user/\(user.userId)", parameters: contents, success: {operation, responseObject in
                
                self.navigationController?.pushViewController(ProfileImageViewController(nibName: "ProfileImageView", bundle: nil), animated: true);
                
                }, failure: {operation, error in
                    let message = NSLocalizedString("BIRTHDATE_VIEW_UPDATE_BIRTHDATE_FAILURE_ALERT_MESSAGE", comment: "Message for alert to display if the server cannot be reached when attempting to update user's birthdate.")
                    let dismissTitle = NSLocalizedString("BIRTHDATE_VIEW_UPDATE_BIRTHDATE_FAILURE_ALERT_ACTION_TITLE_DISMISS", comment: "Title for alert action to dismiss the birthdate update failure alert.")
                    let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: dismissTitle, style: .Default, handler: { [unowned self] (action) in
                        self.reset();
                        })
                    alertController.addAction(cancelAction)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentViewController(alertController, animated: true, completion: nil)
                    })
            });
        }
    }
    
    func reset() {
        self.navigationItem.hidesBackButton = true;
        nextButton.enabled = true;
        datePicker.enabled = true;
        spinner.hidden = true;
        spinner.stopAnimating();
        datePicker.setDate(NSDate(), animated: true);
    }
    
    func deleteAccountAndQuit() {
        let user = SessionData.Instance.user;
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "MM/dd/yyyy";
        HigiApi().sendGet("\(HigiApi.higiApiUrl)/data/deleteAccountAge13?userId=\(user.userId)&dob=\(dateFormatter.stringFromDate(datePicker.date))", success: nil, failure: nil);
        SessionController.Instance.reset();
        SessionData.Instance.reset();
        let hostViewController = UIStoryboard(name: "Host", bundle: nil).instantiateInitialViewController()
        (UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController = hostViewController
    }
    
}