//
//  SessionData.swift
//  higi
//
//  Created by Dan Harms on 8/7/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

final class SessionData {
    
    class var Instance: SessionData {
        return SessionDataSharedInstance;
    }
    
    var token, pin: String!;
    
    var user: HigiUser!;
    
    var seenDashboard, seenMetrics, seenReminder: Bool!;
    
    var lastUpdate: NSDate!;
    
    let documentsSavePath: String = {
        let documentsPath = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])
        let documentsURL = NSURL(fileURLWithPath: documentsPath)
        let writePath = documentsURL.URLByAppendingPathComponent("HigiSessionData.plist")
        return writePath.relativePath!
    }()

    static let sessionSettings: [PersistentSetting] = [.EnableNotifications, .StationNearbyNotification]
    
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
        saveDocumentData()
    }
    
    private func saveDocumentData() {
        KeychainWrapper.setString(token, forKey: "token");
        KeychainWrapper.setString(pin, forKey: "pin");
        let savedUserId: NSString!
        if let user = user, let userId = user.userId {
            savedUserId = userId
        } else {
            savedUserId = ""
        }
        KeychainWrapper.setObject(savedUserId, forKey: "userId");
        
        let saveDictionary = NSMutableDictionary();
        saveDictionary["seenDashboard"] = seenDashboard;
        saveDictionary["seenMetrics"] = seenMetrics;
        saveDictionary["seenReminder"] = seenReminder;
        saveDictionary["lastUpdate"] = lastUpdate;
        
        let dictionary: NSDictionary = saveDictionary.copy() as! NSDictionary
        dictionary.writeToFile(documentsSavePath, atomically: false)
    }
    
    func restore() {
        let fileManager = NSFileManager.defaultManager()
        
        if (fileManager.fileExistsAtPath(documentsSavePath)) {
            if let savedDictionary = NSDictionary(contentsOfFile: documentsSavePath) {
                
                if let savedToken = savedDictionary["token"] as? String {
                    token = savedToken;
                } else if let savedToken = KeychainWrapper.stringForKey("token") {
                    token = savedToken
                } else {
                    token = ""
                }
                
                if let savedPin = savedDictionary["pin"] as? String {
                    pin = savedPin;
                } else if let savedPin = KeychainWrapper.stringForKey("pin") {
                    pin = savedPin
                } else {
                    pin = ""
                }
                
                user = HigiUser();
                if let savedUserId = savedDictionary["userId"] as? NSString {
                    user.userId = savedUserId;
                } else if let savedUserId = KeychainWrapper.objectForKey("userId") as? NSString {
                    user.userId = savedUserId
                } else {
                    user.userId = ""
                }
                
                seenDashboard = (savedDictionary["seenDashboard"] ?? false) as! Bool;
                seenMetrics = (savedDictionary["seenMetrics"] ?? false) as! Bool;
                seenReminder = (savedDictionary["seenReminder"] ?? false) as! Bool;
                lastUpdate = (savedDictionary["lastUpdate"] ?? NSDate()) as! NSDate;
            } else {
                reset()
            }
        } else {
            reset();
        }
    }
    
}

let SessionDataSharedInstance = SessionData();