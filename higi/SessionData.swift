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
        KeychainWrapper.removeObjectForKey("token");
        KeychainWrapper.removeObjectForKey("pin");
        KeychainWrapper.removeObjectForKey("userId");
        seenDashboard = false;
        seenMetrics = false;
        seenReminder = false;
        lastUpdate = NSDate();
    }
    
    func save() {
        KeychainWrapper.setString(token, forKey: "token");
        KeychainWrapper.setString(pin, forKey: "pin");
        var userId = user != nil ? user.userId : "";
        KeychainWrapper.setObject(userId, forKey: "userId");
        
        let saveDictionary = NSMutableDictionary();
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

            if let savedToken = savedDictionary["token"] as? String {
                token = savedToken;
            } else {
                token = KeychainWrapper.stringForKey("token");
            }
            if let savedPin = savedDictionary["pin"] as? String {
                pin = savedPin;
            } else {
                pin = KeychainWrapper.stringForKey("pin");
            }
            user = HigiUser();
            if let savedUserId = savedDictionary["userId"] as? NSString {
                user.userId = savedUserId;
            } else {
                user.userId = KeychainWrapper.objectForKey("userId") as! NSString;
            }
            
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