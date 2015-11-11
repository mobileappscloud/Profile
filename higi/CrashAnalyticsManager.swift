//
//  CrashAnalyticsManager.swift
//  higi
//
//  Created by Remy Panicker on 10/29/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import Foundation

import Fabric
import Crashlytics

public class CrashAnalyticsManager {
    
    private static var sharedInstance = CrashAnalyticsManager();
    
    lazy private var supportedVendors: [AnalyticsManager.Type]? = {
       
        let vendors: [AnalyticsManager.Type] = [CrashlyticsManager.self]
        
        var supportedVendors: [AnalyticsManager.Type] = []
        for vendor in vendors {
            if vendor.isSupported() {
                supportedVendors.append(vendor)
            }
        }
        return supportedVendors;
    }()
    
    /**
        Running multiple crash reporting services simultaneously can degrade exception handling resulting in
        faulty or less reliable stack traces. If there are multiple supported crash analytic vendors, only 
        the first vendor's services will be initiated.
     */
    public class func setupVendors() {
        if let vendors = sharedInstance.supportedVendors {
            for vendor in vendors {
                vendor.setup()
                // Break after setup so that only one crash reporting service is running.
                break
            }
        }
    }
}

@objc private protocol AnalyticsManager {
    
    static func isSupported() -> Bool;
    
    static func setup();
    
    optional static func logEvent(identifier: String, userInfo: [String : AnyObject]?);
}

private class CrashlyticsManager: AnalyticsManager {
    
    private static let instance = CrashlyticsManager()
    
    lazy private var fabricInfo: FabricInfo? = {
        if let dictionary = NSBundle.mainBundle().objectForInfoDictionaryKey("Fabric") {
            let dict = dictionary as! NSDictionary
            let fabricInfo = FabricInfo(dictionary: dict)
            return fabricInfo;
        }
        return nil
    }()
    
    @objc private class func isSupported() -> Bool {
        var isSupported = false;
        if instance.fabricInfo != nil {
            isSupported = instance.fabricInfo!.containsCrashlytics();
        }
        return isSupported;
    }
    
    @objc private class func setup() {
        #if DEBUG
            Crashlytics.sharedInstance().debugMode = true;
        #endif
        Fabric.with([Crashlytics.self()])
    }
}