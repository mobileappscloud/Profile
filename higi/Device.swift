//
//  Device.swift
//  higi
//
//  Created by Remy Panicker on 8/25/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

/**
 *  Third-party activity tracking partner.
 */
struct Device {
    
    // MARK: Required
    
    /// Identifier for the device.
    let identifier: Identifier
    
    /// Name of the device.
    let name: String
    
    /// Description of the device.
    let description: String
    
    /// Icon image for the device.
    let image: MediaAsset
    
    // MARK: Optional
    
    /// Whether or not the device is connected for the current authenticated user.
    let isConnected: Bool
    
    /// `URL` which will connect the device to the current authenticated user's account.
    let connectURL: NSURL?
    
    /// `URL` which will disconnect the device from the current authenticated user's account.
    let disconnectURL: NSURL?
}

extension Device: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let identifier = Device.Identifier(rawJSONValue: dictionary["id"]),
            let name = dictionary["name"] as? String,
            let description = dictionary["description"] as? String,
            let image = MediaAsset(fromLegacyJSONObject: dictionary, imageTypeKey: "icon"),
            let userRelation = dictionary["userRelation"] as? NSDictionary else { return nil }
        
        self.identifier = identifier
        self.name = name
        self.description = description
        self.image = image
        
        self.isConnected = userRelation["connected"] as? Bool ?? false
        self.connectURL = NSURL(responseObject: userRelation["disconnectUrl"]) ?? nil
        self.disconnectURL = NSURL(responseObject: userRelation["disconnectUrl"]) ?? nil
    }
}
