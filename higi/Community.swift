//
//  Community.swift
//  higi
//
//  Created by Remy Panicker on 3/17/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class Community {
    
    let identifier: String
    let organizationIdentifier: String
    let memberCount: Int
    let isMember: Bool
    let canLeave: Bool
    let isActive: Bool
    let isPublished: Bool
    let name: String
    let description: String
    let missionStatement: String
    let locale: String
    let isPublic: Bool
    
    var logoURL: NSURL?
    var headerImageURL: NSURL?
    
    required init(identifier: String, organizationIdentifier: String, memberCount: Int, isMember: Bool, canLeave: Bool, isActive: Bool, isPublished: Bool, name: String, description: String, missionStatement: String, locale: String, isPublic: Bool) {
        self.identifier = identifier
        self.organizationIdentifier = organizationIdentifier
        self.memberCount = memberCount
        self.isMember = isMember
        self.canLeave = canLeave
        self.isActive = isActive
        self.isPublished = isPublished
        self.name = name
        self.description = description
        self.missionStatement = missionStatement
        self.locale = locale
        self.isPublic = isPublic
    }
}

extension Community {

    convenience init?(dictionary: NSDictionary) {
        guard let identifier = dictionary["id"] as? String,
            let organizationIdentifier = dictionary["organizationId"] as? String,
            let memberCount = dictionary["memberCount"] as? Int,
            let isMember = dictionary["isMember"] as? Bool,
            let canLeave = dictionary["canLeave"] as? Bool,
            let isActive = dictionary["isActive"] as? Bool,
            let isPublished = dictionary["isPublished"] as? Bool,
            let name = dictionary["name"] as? String,
            let description = dictionary["description"] as? String,
            let missionStatement = dictionary["missionStatement"] as? String,
            let locale = dictionary["locale"] as? String,
            let isPublic = dictionary["isPublic"] as? Bool else { return nil }
        
        self.init(identifier: identifier, organizationIdentifier: organizationIdentifier, memberCount: memberCount, isMember: isMember, canLeave: canLeave, isActive: isActive, isPublished: isPublished, name: name, description: description, missionStatement: missionStatement, locale: locale, isPublic: isPublic)
        
        if let logoURI = dictionary["logoUri"] as? String {
            self.logoURL = NSURL(string: logoURI)
        }
        if let headerImageURI = dictionary["headerImageUri"] as? String {
            self.headerImageURL = NSURL(string: headerImageURI)
        }
    }
}
