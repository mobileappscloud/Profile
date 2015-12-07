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
    case DidAskToConnectActivityTracker = "DidAskToConnectActivityTrackerKey"
    case DidShowActivityTrackerAuthorizationRequest = "DidShowActivityTrackerAuthorizationRequestKey"
    
    static let allValues = [EnableNotifications, StationNearbyNotification, DidShowActivityTrackerAuthorizationRequest];
}

public class PersistentSettingsController {

    private static var sharedInstance = PersistentSettingsController();
    
    private lazy var persistentStore = NSUserDefaults.standardUserDefaults();
    
    // MARK: - Initialize
    
    private init() {
        initializeDefaultValues();
    }
    
    private func initializeDefaultValues() {
        let trueSettings: [PersistentSetting] = [.EnableNotifications, .StationNearbyNotification];
        initializeDefaultValues(trueSettings, boolValue: true);
        
        let falseSettings: [PersistentSetting] = [.DidAskToConnectActivityTracker, .DidShowActivityTrackerAuthorizationRequest];
        initializeDefaultValues(falseSettings, boolValue: false);
    }
    
    private func initializeDefaultValues(boolKeyTypes: [PersistentSetting], boolValue: Bool) {
        let boolKeyTypes: [PersistentSetting] = [.EnableNotifications, .StationNearbyNotification];
        for keyType in boolKeyTypes {
            let key = keyType.rawValue;
            if persistentStore.objectForKey(key) == nil {
                persistentStore.setBool(boolValue, forKey: key);
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
