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
    
    let tempSavePath: String = {
        let tempPath = (NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0])
        let tempURL = NSURL(fileURLWithPath: tempPath)
        let writePath = tempURL.URLByAppendingPathComponent("TempSessionData.plist")
        return writePath.relativePath!
    }()
    
    let documentsSavePath: String = {
        let documentsPath = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])
        let documentsURL = NSURL(fileURLWithPath: documentsPath)
        let writePath = documentsURL.URLByAppendingPathComponent("HigiSessionData.plist")
        return writePath.relativePath!
    }()

    
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
        saveCachedData()
    }
    
    private func saveDocumentData() {
        KeychainWrapper.setString(token, forKey: "token");
        KeychainWrapper.setString(pin, forKey: "pin");
        let userId = user != nil ? user.userId : "";
        KeychainWrapper.setObject(userId, forKey: "userId");
        
        let saveDictionary = NSMutableDictionary();
        saveDictionary["seenDashboard"] = seenDashboard;
        saveDictionary["seenMetrics"] = seenMetrics;
        saveDictionary["seenReminder"] = seenReminder;
        saveDictionary["lastUpdate"] = lastUpdate;
        
        let dictionary: NSDictionary = saveDictionary.copy() as! NSDictionary
        dictionary.writeToFile(documentsSavePath, atomically: false)
    }
    
    private func saveCachedData() {
        let tempDictionary = NSMutableDictionary()
        tempDictionary["kioskList"] = kioskListString
        
        let immutableTempDict: NSDictionary = tempDictionary.copy() as! NSDictionary
        immutableTempDict.writeToFile(tempSavePath, atomically: false)
    }
    
    func restore() {
        let fileManager = NSFileManager.defaultManager()
        
        if (fileManager.fileExistsAtPath(documentsSavePath)) {
            if let savedDictionary = NSDictionary(contentsOfFile: documentsSavePath) {
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
                    user.userId = KeychainWrapper.objectForKey("userId") as? NSString;
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
        
        if (fileManager.fileExistsAtPath(tempSavePath)) {
            guard let tempDictionary = NSDictionary(contentsOfFile: tempSavePath) else { return }
            kioskListString = (tempDictionary["kioskList"] ?? "") as! String;
        }
    }
    
}

let SessionDataSharedInstance = SessionData();