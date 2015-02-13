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
    
    var kioskListString: String!;
    
    var seenDashboard, seenBodyStats, seenReminder: Bool!;
    
    let savePath = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String).stringByAppendingPathComponent("HigiSessionData.plist");

    
    init() {
        restore();
    }
    
    func reset() {
        token = "";
        pin = "";
        user = nil;
        seenDashboard = false;
        seenBodyStats = false;
        seenReminder = false;
    }
    
    func save() {
        let saveDictionary = NSMutableDictionary();
        saveDictionary["token"] = token;
        saveDictionary["pin"] = pin;
        saveDictionary["userId"] = user != nil ? user.userId : "";
        saveDictionary["seenDashboard"] = seenDashboard;
        saveDictionary["seenBodyStats"] = seenBodyStats;
        saveDictionary["seenReminder"] = seenReminder;
        saveDictionary["kioskList"] = kioskListString;
        saveDictionary.writeToFile(savePath, atomically: false);
    }
    
    func restore() {
        if (NSFileManager.defaultManager().fileExistsAtPath(savePath)) {
            let savedDictionary = NSDictionary(contentsOfFile: savePath)!;
            token = savedDictionary["token"] as NSString;
            pin = savedDictionary["pin"] as NSString;
            user = HigiUser();
            user.userId = savedDictionary["userId"] as NSString;
            seenDashboard = (savedDictionary["seenDashboard"] ?? false) as Bool;
            seenBodyStats = (savedDictionary["seenBodyStats"] ?? false) as Bool;
            seenReminder = (savedDictionary["seenReminder"] ?? false) as Bool;
            kioskListString = (savedDictionary["kioskList"] ?? "") as NSString;
        } else {
            reset();
        }
    }
    
}

let SessionDataSharedInstance = SessionData();