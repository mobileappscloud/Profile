//
//  Fabric.swift
//  higi
//
//  Created by Remy Panicker on 10/29/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import Foundation

private enum Kits: String {
    case Crashlytics
}

public class FabricInfo {
    
    private var APIKey: String!
    private var kits: [FabricKit] = []
    
    public init(dictionary: NSDictionary) {
        APIKey = dictionary["APIKey"] as! String
        
        if let fabricKits = dictionary["Kits"] as? NSArray {
            for fabricKit in fabricKits {
                let kitDict = fabricKit as! NSDictionary
                let kit = FabricKit(dictionary: kitDict)
                kits.append(kit)
            }
        }
    }
    
    public func containsCrashlytics() -> Bool {
        var containsKit = false;
        for kit in self.kits {
            if kit.name == Kits.Crashlytics.rawValue {
                containsKit = true;
                break;
            }
        }
        return containsKit;
    }
}

private class FabricKit {
    
    private var name: String!
    
    private init(dictionary: NSDictionary) {
        name = dictionary["KitName"] as! String
    }
}