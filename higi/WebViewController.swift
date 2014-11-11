//
//  PulseArticleViewController.swift
//  higi
//
//  Created by Dan Harms on 8/6/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class WebViewController: UIViewController, NSURLConnectionDataDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    var url: NSString!;
    
    var loadData = false;
    
    var webData: NSMutableData!;
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
        var backButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton;
        backButton.setBackgroundImage(UIImage(named: "btn_back_black.png"), forState: UIControlState.Normal);
        backButton.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside);
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        var backBarItem = UIBarButtonItem(customView: backButton);
        self.navigationItem.leftBarButtonItem = backBarItem;
        self.navigationItem.hidesBackButton = true;
        
        var urlRequest = NSMutableURLRequest(URL: NSURL(string: url)!);
        
        urlRequest.addValue("mobile-ios", forHTTPHeaderField: "Higi-Source");
        if (loadData) {
            NSURLConnection(request: urlRequest, delegate: self);
        } else {
            webView.loadRequest(urlRequest);
        }
        
    }
    
    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        webData = NSMutableData();
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        webData.appendData(data);
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        webView.loadData(webData, MIMEType: "text/html", textEncodingName: "UTF-8", baseURL: nil);
    }
    
    func goBack(sender: AnyObject!) {
        self.navigationController!.popViewControllerAnimated(true);
    }
}