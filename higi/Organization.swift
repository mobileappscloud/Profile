//
//  Organization.swift
//  higi
//
//  Created by Remy Panicker on 3/17/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class Organization {
    
    let identifier: String
    let isActive: Bool
    let name: String
    let description: String
    let locale: String
    
    var logoURL: NSURL?
    var defaultCommunityIdentifier: String?
    
    required init(identifier: String, isActive: Bool, name: String, description: String, locale: String) {
        self.identifier = identifier
        self.isActive = isActive
        self.name = name
        self.description = description
        self.locale = locale
    }
}

extension Organization {

    convenience init?(dictionary: NSDictionary) {
        guard let identifier = dictionary["id"] as? String,
            let isActive = dictionary["isActive"] as? Bool,
            let name = dictionary["name"] as? String,
            let description = dictionary["description"] as? String,
            let locale = dictionary["locale"] as? String else { return nil }

        self.init(identifier: identifier, isActive: isActive, name: name, description: description, locale: locale)
        
        if let logoURI = dictionary["logoUri"] as? String {
            self.logoURL = NSURL(string: logoURI)
        }
        self.defaultCommunityIdentifier = dictionary["defaultCommunityId"] as? String
    }
}
