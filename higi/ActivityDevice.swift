//
//  ActivityDevice.swift
//  higi
//
//  Created by Dan Harms on 11/4/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

final class ActivityDevice {
    
    var name, description: NSString!;
    var url, connectUrl, partnerHomepage, iconUrl, colorCode, disconnectUrl, imageName: NSString?;
    
    var connected: Bool!;
    
    init(dictionary: NSDictionary) {
        name = dictionary["name"] as! NSString;
        description = dictionary["description"] as! NSString;
        url = dictionary["url"] as? NSString;
        connectUrl = dictionary["connectUrl"] as? NSString;
        partnerHomepage = dictionary["partnerHomepage"] as? NSString;
        colorCode = dictionary["colorCode"] as? NSString;
        let imageUrls = dictionary["imageUrl"] as! NSDictionary;
        iconUrl = imageUrls["icon"] as? NSString;
        let userRelation = dictionary["userRelation"] as! NSDictionary;
        connected = userRelation["connected"] as? Bool;
        disconnectUrl = userRelation["disconnectUrl"] as? NSString;
    }
    
    init(name: NSString, description: NSString, imageName: NSString, connected: Bool) {
        self.name = name
        self.description = description
        self.imageName = imageName
        self.connected = connected
    }
}