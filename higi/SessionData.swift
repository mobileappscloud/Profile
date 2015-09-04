//
//  SessionData.swift
//  higi
//
//  Created by Dan Harms on 8/7/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class SessionData {
    
    class var Instance: SessionData {
        return SessionDataSharedInstance;
    }
    
    var token, pin: String!;
    
    var user: HigiUser!;
    
    var kioskListString: String = "";
    
    var seenDashboard, seenMetrics, seenReminder: Bool!;
    
    var lastUpdate: NSDate!;
    
    let savePath = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String).stringByAppendingPathComponent("HigiSessionData.plist");

    init() {
        restore();
    }
    
    func reset() {
        token = "";
        pin = "";
        user = nil;
        seenDashboard = false;
        seenMetrics = false;
        seenReminder = false;
        lastUpdate = NSDate();
    }
    
    func save() {
        let saveDictionary = NSMutableDictionary();
        saveDictionary["token"] = token;
        saveDictionary["pin"] = pin;
        saveDictionary["userId"] = user != nil ? user.userId : "";
        saveDictionary["seenDashboard"] = seenDashboard;
        saveDictionary["seenMetrics"] = seenMetrics;
        saveDictionary["seenReminder"] = seenReminder;
        saveDictionary["kioskList"] = kioskListString;
        saveDictionary["lastUpdate"] = lastUpdate;
        saveDictionary.writeToFile(savePath, atomically: false);
    }
    
    func restore() {
        if (NSFileManager.defaultManager().fileExistsAtPath(savePath)) {
            let savedDictionary = NSDictionary(contentsOfFile: savePath)!;
            token = savedDictionary["token"] as! String;
            pin = savedDictionary["pin"] as! String;
            user = HigiUser();
            user.userId = savedDictionary["userId"] as! NSString;
            seenDashboard = (savedDictionary["seenDashboard"] ?? false) as! Bool;
            seenMetrics = (savedDictionary["seenMetrics"] ?? false) as! Bool;
            seenReminder = (savedDictionary["seenReminder"] ?? false) as! Bool;
            kioskListString = (savedDictionary["kioskList"] ?? "") as! String;
            lastUpdate = (savedDictionary["lastUpdate"] ?? NSDate()) as! NSDate;
        } else {
            reset();
        }
    }
    
}

let SessionDataSharedInstance = SessionData();