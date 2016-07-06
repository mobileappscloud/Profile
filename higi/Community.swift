//
//  Community.swift
//  higi
//
//  Created by Remy Panicker on 3/17/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class Community: NSObject {
    
    let identifier: String
    let organizationIdentifier: String
    let memberCount: Int
    let isMember: Bool
    let isActive: Bool
    let isPublished: Bool
    let name: String
    let desc: String
    let missionStatement: String
    let locale: String
    let isVisibleToVisitors: Bool
    let isShareable: Bool
    let isWellnessGroup: Bool
    let isSponsored: Bool
    let isLocked: Bool
    
    var joinDate: NSDate?
    var createDate: NSDate?
    var logo: MediaAsset?
    var header: MediaAsset?
    
    required init(identifier: String, organizationIdentifier: String, memberCount: Int, isMember: Bool, isActive: Bool, isPublished: Bool, name: String, description: String, missionStatement: String, locale: String, isVisibleToVisitors: Bool, isShareable: Bool, isWellnessGroup: Bool, isSponsored: Bool, isLocked: Bool) {
        self.identifier = identifier
        self.organizationIdentifier = organizationIdentifier
        self.memberCount = memberCount
        self.isMember = isMember
        self.isActive = isActive
        self.isPublished = isPublished
        self.name = name
        self.desc = description
        self.missionStatement = missionStatement
        self.locale = locale
        self.isVisibleToVisitors = isVisibleToVisitors
        self.isShareable = isShareable
        self.isWellnessGroup = isWellnessGroup
        self.isSponsored = isSponsored
        self.isLocked = isLocked
    }
}

extension Community: HigiAPIJSONDeserializer {

    convenience init?(dictionary: NSDictionary) {
        guard let identifier = dictionary["id"] as? String,
            let organizationIdentifier = dictionary["organizationId"] as? String,
            let memberCount = dictionary["memberCount"] as? Int,
            let isMember = dictionary["isMember"] as? Bool,
            let isActive = dictionary["isActive"] as? Bool,
            let isPublished = dictionary["isPublished"] as? Bool,
            let name = dictionary["name"] as? String,
            let description = dictionary["description"] as? String,
            let missionStatement = dictionary["missionStatement"] as? String,
            let locale = dictionary["locale"] as? String,
            let isVisibleToVisitors = dictionary["isVisibleToVisitors"] as? Bool,
            let isShareable = dictionary["isShareable"] as? Bool,
            let isWellnessGroup = dictionary["isWellnessGroup"] as? Bool,
            let isSponsored = dictionary["isSponsored"] as? Bool,
            let isLocked = dictionary["isLocked"] as? Bool
            else { return nil }
        
        self.init(identifier: identifier, organizationIdentifier: organizationIdentifier, memberCount: memberCount, isMember: isMember, isActive: isActive, isPublished: isPublished, name: name, description: description, missionStatement: missionStatement, locale: locale, isVisibleToVisitors: isVisibleToVisitors, isShareable: isShareable, isWellnessGroup: isWellnessGroup, isSponsored: isSponsored, isLocked: isLocked)
        
        if let createDateString = dictionary["createdOn"] as? String {
            self.createDate = NSDateFormatter.ISO8601DateFormatter.dateFromString(createDateString)
        }
        if let joinDateString = dictionary["joinDate"] as? String {
            self.joinDate = NSDateFormatter.ISO8601DateFormatter.dateFromString(joinDateString)
        }
        if let logoDict = dictionary["logo"] as? NSDictionary {
            self.logo = MediaAsset(dictionary: logoDict)
        }
        if let headerDict = dictionary["headerImage"] as? NSDictionary {
            self.header = MediaAsset(dictionary: headerDict)
        }
    }
}
