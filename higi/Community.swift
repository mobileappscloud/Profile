//
//  Community.swift
//  higi
//
//  Created by Remy Panicker on 3/17/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

/// Represents a community.
final class Community: UniquelyIdentifiable {
    
    // MARK: Required
    
    /// Unique identifier.
    let identifier: UniqueId
    
    /// Identifier of the organization the community belongs to.
    let organizationIdentifier: String
    
    /// Number of users who are members of the community.
    let memberCount: Int
    
    /// Whether or not the current user is a member of the community.
    let isMember: Bool
    
    /// Whether or not the community is active.
    let isActive: Bool
    
    /// Whether or not the community has been published.
    let isPublished: Bool
    
    /// Name of the community.
    let name: String
    
    /// Description of the community.
    let description: String
    
    /// Mission statement for the community.
    let missionStatement: String
    
    /// Locale of the community.
    let locale: String
    
    /// Whether or not the community is visible to users who are not members of the community.
    let isVisibleToVisitors: Bool
    
    /// Whether or not the community can be shared.
    let isShareable: Bool
    
    /// Whether or not the community is a wellness group.
    let isWellnessGroup: Bool
    
    /// Whether or not the community is sponsored.
    let isSponsored: Bool
    
    /// Whether or not the community is locked.
    let isLocked: Bool
    
    /// Whether or not the community has challenges. (Does this comment add any value?)
    let hasChallenges: Bool
    
    // MARK: Optional
    
    /// Date a user joined the community, if applicable.
    let joinDate: NSDate?
    
    /// Date the community was created.
    let createDate: NSDate?
    
    /// Logo asset for the community.
    let logo: MediaAsset?
    
    /// Header (banner) asset for the community.
    let header: MediaAsset?
    
    // MARK: Init
    
    required init(identifier: String, organizationIdentifier: String, memberCount: Int, isMember: Bool, isActive: Bool, isPublished: Bool, name: String, description: String, missionStatement: String, locale: String, isVisibleToVisitors: Bool, isShareable: Bool, isWellnessGroup: Bool, isSponsored: Bool, isLocked: Bool, hasChallenges: Bool, joinDate: NSDate? = nil, createDate: NSDate? = nil, logo: MediaAsset? = nil, header: MediaAsset? = nil) {
        self.identifier = identifier
        self.organizationIdentifier = organizationIdentifier
        self.memberCount = memberCount
        self.isMember = isMember
        self.isActive = isActive
        self.isPublished = isPublished
        self.name = name
        self.description = description
        self.missionStatement = missionStatement
        self.locale = locale
        self.isVisibleToVisitors = isVisibleToVisitors
        self.isShareable = isShareable
        self.isWellnessGroup = isWellnessGroup
        self.isSponsored = isSponsored
        self.isLocked = isLocked
        self.hasChallenges = hasChallenges
        
        self.joinDate = joinDate
        self.createDate = createDate
        self.logo = logo
        self.header = header
    }
}

// MARK: - JSON

extension Community: JSONInitializable {
    
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
            let isLocked = dictionary["isLocked"] as? Bool,
            let hasChallenges = dictionary["hasChallenges"] as? Bool
            else { return nil }
        
        let createDate = NSDateFormatter.ISO8601DateFormatter.date(fromObject: dictionary["createdOn"])
        let joinDate = NSDateFormatter.ISO8601DateFormatter.date(fromObject: dictionary["joinDate"])
        let logo = MediaAsset(fromJSONObject: dictionary["logo"])
        let header = MediaAsset(fromJSONObject: dictionary["headerImage"])
        
        self.init(identifier: identifier, organizationIdentifier: organizationIdentifier, memberCount: memberCount, isMember: isMember, isActive: isActive, isPublished: isPublished, name: name, description: description, missionStatement: missionStatement, locale: locale, isVisibleToVisitors: isVisibleToVisitors, isShareable: isShareable, isWellnessGroup: isWellnessGroup, isSponsored: isSponsored, isLocked: isLocked, hasChallenges: hasChallenges, joinDate: joinDate, createDate: createDate, logo: logo, header: header)
    }
}
