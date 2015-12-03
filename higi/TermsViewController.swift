//
//  TermsViewController.swift
//  higi
//
//  Created by Dan Harms on 8/19/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation
import WebKit

class TermsViewController: UIViewController {
    
    @IBOutlet weak var termsTitle: UILabel! {
        didSet {
            termsTitle.text = NSLocalizedString("TERMS_VIEW_HEADER_TEXT_UPDATED_TERMS_AND_PRIVACY", comment: "Text to display in header view when terms of use and privacy policy has changed.");
        }
    }
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var agreeButton: UIButton! {
        didSet {
            agreeButton.setTitle(NSLocalizedString("TERMS_VIEW_AGREE_BUTTON_TITLE", comment: "Title for button to agree to terms of use and/or privacy policy."), forState: .Normal)
        }
    }
    @IBOutlet weak var declineButton: UIButton! {
        didSet {
            declineButton.setTitle(NSLocalizedString("TERMS_VIEW_DECLINE_BUTTON_TITLE", comment: "Title for button to decline to terms of use and/or privacy policy."), forState: .Normal)
        }
    }
    @IBOutlet weak var loadingView: UIView!
    
    var termsFile, privacyFile: String!;
    
    var newTerms = false, newPrivacy = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        declineButton.layer.borderWidth = 1;
        declineButton.layer.borderColor = Utility.colorFromHexString(Constants.higiGreen).CGColor;
        var url = "";
        if (newTerms && newPrivacy) {
            termsTitle.text = NSLocalizedString("TERMS_VIEW_HEADER_TEXT_UPDATED_TERMS_AND_PRIVACY", comment: "Text to display in header view when terms of use and privacy policy has changed.");
            url = "/termsandprivacy";
        } else if (newTerms) {
            termsTitle.text = NSLocalizedString("TERMS_VIEW_HEADER_TEXT_UPDATED_TERMS", comment: "Text to display in header view when terms of use has changed.");
            url = "/terms";
        } else if (newPrivacy) {
            termsTitle.text = NSLocalizedString("TERMS_VIEW_HEADER_TEXT_UPDATED_PRIVACY", comment: "Text to display in header view when privacy policy has changed.");
            url = "/privacy";
        } else {
            agree(nil);
            return;
        }
        
        let urlRequest = NSMutableURLRequest(URL: NSURL(string: "\(HigiApi.webUrl)\(url)")!);
        urlRequest.addValue("mobile-ios", forHTTPHeaderField: "Higi-Source");
        webView.loadRequest(urlRequest);
    }
    
    @IBAction func agree(sender: AnyObject!) {
        loadingView.hidden = false;
        agreeButton.enabled = false;
        declineButton.enabled = false;
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ";
        let agreedDate = dateFormatter.stringFromDate(NSDate());
        let contents = NSMutableDictionary();
        
        if (newTerms) {
            let terms = NSMutableDictionary();
            terms["termsFileName"] = termsFile;
            terms["termsAgreedDate"] = agreedDate;
            contents["terms"] = terms;
        }
        
        if (newPrivacy) {
            let privacy = NSMutableDictionary();
            privacy["privacyFileName"] = privacyFile;
            privacy["privacyAgreedDate"] = agreedDate;
            contents["privacyAgreed"] = privacy;
        }
        
        HigiApi().sendPost("\(HigiApi.higiApiUrl)/data/user/\(SessionData.Instance.user.userId)", parameters: contents, success: {operation, responseObject in
            
            ApiUtility.initializeApiData();
            (UIApplication.sharedApplication().delegate as! AppDelegate).startLocationManager();
            Utility.gotoDashboard(self);
            
            }, failure: {operation, error in
                self.reset();
        });
    }
    
    func gotoDashboard() {
        if (SessionController.Instance.checkins != nil && SessionController.Instance.challenges != nil && SessionController.Instance.kioskList != nil && SessionController.Instance.pulseArticles.count > 0) {
            Utility.gotoDashboard(self);
        }
    }
    
    @IBAction func decline(sender: AnyObject) {
        SessionController.Instance.reset();
        SessionData.Instance.reset();
        SessionData.Instance.save();
        let splashViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SplashViewController") ;
        (UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController = splashViewController;
        
    }
    
    func reset() {
        loadingView.hidden = true;
        agreeButton.enabled = true;
        declineButton.enabled = true;
    }
}