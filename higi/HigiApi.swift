//
//  HigiApi.swift
//  higi
//
//  Created by Dan Harms on 6/16/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation


class HigiApi {
    
    class var PRODUCTION: Bool {
        return true;
    }
    
    var manager: AFHTTPRequestOperationManager;
    
    class var higiApiUrl: String {
        return HigiApi.PRODUCTION == true ? BASE_URL : DEV_BASE_URL;
    }
    
    class var earnditApiUrl: String {
        return HigiApi.PRODUCTION == true ? EARNDIT_URL : DEV_EARNDIT_URL;
    }
    
    class var webUrl: String {
        return HigiApi.PRODUCTION == true ? WEB_URL : DEV_EARNDIT_URL;
    }
    
    class var apiKey: String {
        return API_KEY;
    }
    
    init() {
        manager = AFHTTPRequestOperationManager(baseURL: NSURL(string: BASE_URL));
        manager.requestSerializer = AFJSONRequestSerializer(writingOptions: NSJSONWritingOptions.allZeros);
        manager.responseSerializer = AFJSONResponseSerializer(readingOptions: NSJSONReadingOptions.AllowFragments);
        manager.requestSerializer.setValue(API_KEY, forHTTPHeaderField: "ApiToken");
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type");
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept");
        manager.requestSerializer.setValue("application/vnd.higi.earndit;version=2", forHTTPHeaderField: "Accept");
        
        if (HigiApi.PRODUCTION) {
            manager.requestSerializer.setValue("rQIpgKhmd0qObDSr5SkHbw", forHTTPHeaderField: "Dev-Token");  // Grant
        }
        manager.requestSerializer.setValue("iOSv\(Utility.appVersion()).\(Utility.appBuild())", forHTTPHeaderField: "X-Consumer-Id");
        if (!SessionData.Instance.token.isEmpty) {
            manager.requestSerializer.setValue(SessionData.Instance.token, forHTTPHeaderField: "Token");
        }
    }
    
    func sendPost(url: String, parameters: NSDictionary?, success: ((AFHTTPRequestOperation!, AnyObject!) -> Void)?, failure: ((AFHTTPRequestOperation!, NSError!) -> Void)?) {
        manager.POST(url, parameters: parameters, success: success, failure: failure);
    }
    
    func sendGet(url: String, success: ((AFHTTPRequestOperation!, AnyObject!) -> Void)?, failure: ((AFHTTPRequestOperation!, NSError!) -> Void)?) {
        manager.GET(url, parameters: NSDictionary(), success: success, failure: failure);
    }
    
    func sendPut(url: String, parameters: NSDictionary?, success: ((AFHTTPRequestOperation!, AnyObject!) -> Void)?, failure: ((AFHTTPRequestOperation!, NSError!) -> Void)?) {
        manager.PUT(url, parameters: parameters, success: success, failure: failure);
    }
    
    func sendBytePost(url: String, contentType: String, body: NSData, parameters: NSDictionary?, success: ((AFHTTPRequestOperation!, AnyObject!) -> Void)?, failure: ((AFHTTPRequestOperation!, NSError!) -> Void)?) {
        var request = NSMutableURLRequest(URL: NSURL(string: url)!);
        request.HTTPMethod = "POST";
        request.setValue(contentType, forHTTPHeaderField: "Content-Type");
        request.setValue(HigiApi.apiKey, forHTTPHeaderField: "ApiToken");
        request.setValue("application/vnd.higi.earndit;version=2", forHTTPHeaderField: "Accept");
        if (!SessionData.Instance.token.isEmpty) {
            request.setValue(SessionData.Instance.token, forHTTPHeaderField: "Token");
        }
        request.HTTPBody = body;
        
        var op = AFHTTPRequestOperation(request: request);
        op.setCompletionBlockWithSuccess(success, failure: failure);
        op.start();
    }
    
}

let BASE_URL = "https://api.higi.com";
let DEV_BASE_URL = "http://higiapi2.cloudapp.net";

let EARNDIT_URL = "https://earndit.com/higiApi";
let DEV_EARNDIT_URL = "http://earndit-web-qa2.cloudapp.net/higiApi";

let WEB_URL = "https://higi.com";
let DEV_WEB_URL = "https://webqa.superbuddytime.com";

let API_KEY = "SyNAqa1DNkeph3P6pvMw8kCdbAh0mMNaJ0quimRPHNZH5jKvzBZulRhn31mGfPfUIZ7l2HBazU9tMeWMJ7eNPn35ZVxw9liS3mQ20Bj780MBAA==";