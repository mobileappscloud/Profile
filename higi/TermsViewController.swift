//
//  TermsViewController.swift
//  higi
//
//  Created by Dan Harms on 8/19/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class TermsViewController: UIViewController {
    
    @IBOutlet weak var termsTitle: UILabel!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
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
            termsTitle.text = "The higi Terms of Use and Privacy Policy have changed.";
            url = "/termsandprivacy";
        } else if (newTerms) {
            termsTitle.text = "The higi Terms of Use has changed.";
            url = "/terms";
        } else if (newPrivacy) {
            termsTitle.text = "The higi Privacy Policy has changed.";
            url = "/privacy";
        } else {
            agree(nil);
            return;
        }
        
        var urlRequest = NSMutableURLRequest(URL: NSURL(string: "\(HigiApi.webUrl)\(url)")!);
        urlRequest.addValue("mobile-ios", forHTTPHeaderField: "Higi-Source");
        webView.loadRequest(urlRequest);
    }
    
    @IBAction func agree(sender: AnyObject!) {
        loadingView.hidden = false;
        agreeButton.enabled = false;
        declineButton.enabled = false;
        var dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ";
        var agreedDate = dateFormatter.stringFromDate(NSDate());
        var contents = NSMutableDictionary();
        
        if (newTerms) {
            var terms = NSMutableDictionary();
            terms["termsFileName"] = termsFile;
            terms["termsAgreedDate"] = agreedDate;
            contents["terms"] = terms;
        }
        
        if (newPrivacy) {
            var privacy = NSMutableDictionary();
            privacy["privacyFileName"] = privacyFile;
            privacy["privacyAgreedDate"] = agreedDate;
            contents["privacyAgreed"] = privacy;
        }
        
        HigiApi().sendPost("\(HigiApi.higiApiUrl)/data/user/\(SessionData.Instance.user.userId)", parameters: contents, success: {operation, responseObject in
            
            ApiUtility.initializeApiData();
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
        var splashViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SplashViewController") as! UIViewController;
        (UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController = splashViewController;
        
    }
    
    func reset() {
        loadingView.hidden = true;
        agreeButton.enabled = true;
        declineButton.enabled = true;
    }
}