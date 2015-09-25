//
//  PersistentSettingsController.swift
//  higi
//
//  Created by Remy Panicker on 9/25/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import UIKit

public enum PersistentSetting: String {
    case Unknown
    case EnableNotifications = "GlobalNotificationSettingKey"
    case StationNearbyNotification = "StationNearbyNotificationSettingKey"
    
    static let allValues = [EnableNotifications, StationNearbyNotification];
}

public class PersistentSettingsController {

    private static var sharedInstance = PersistentSettingsController();
    
    private lazy var persistentStore = NSUserDefaults.standardUserDefaults();
    
    // MARK: - Initialize
    
    private init() {
        initializeDefaultValues();
    }
    
    private func initializeDefaultValues() {
        let boolSettings: [PersistentSetting] = [.EnableNotifications, .StationNearbyNotification];
        for setting in boolSettings {
            let key = setting.rawValue;
            if persistentStore.objectForKey(key) == nil {
                persistentStore.setBool(true, forKey: key);
            }
        }
    }
    
    // MARK: - Convenience
    
    private class func store() -> NSUserDefaults {
        return PersistentSettingsController.sharedInstance.persistentStore;
    }
    
    // MARK: - Read
    
    public class func boolForKey(key: PersistentSetting) -> Bool {
        if key == .Unknown {
            return false;
        }
        
        return store().boolForKey(key.rawValue);
    }
    
    // MARK: - Update
    
    public class func setBool(value: Bool, key: PersistentSetting) {
        if key == .Unknown {
            return;
        }
        
        store().setBool(value, forKey: key.rawValue);
        store().synchronize();
    }
    
    public class func reset() {
        for setting in PersistentSetting.allValues {
            store().removeObjectForKey(setting.rawValue);
        }
        PersistentSettingsController.sharedInstance.initializeDefaultValues();
    }
}
