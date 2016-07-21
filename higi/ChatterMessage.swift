//
//  ChatterMessage.swift
//  higi
//
//  Created by Remy Panicker on 7/19/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct ChatterMessage {
    
    struct User {
        let identifier: String
        let firstName: String
        let lastName: String
        let avatar: MediaAsset
        let isModerator: Bool
    }
    
    struct Entity {
        let identifier: String
        let type: ChatterRequest.EntityType
    }
    
    let identifier: String
    
    let user: User
    
    let parentEntity: Entity
    
    let nestingLevel: Int
    
    let replies: [ChatterMessage]
    
    let text: String
    
    let date: NSDate
    
    let isDeleted: Bool
}

extension ChatterMessage.User: HigiAPIJSONDeserializer {
    
    init?(dictionary: NSDictionary) {
        guard let identifier = dictionary["Id"] as? String,
            let firstName = dictionary["FirstName"] as? String,
            let lastName = dictionary["LastName"] as? String,
            let avatarDict = dictionary["Avatar"] as? NSDictionary,
            let avatar = MediaAsset(dictionary: avatarDict),
            let isModerator = dictionary["IsModerator"] as? Bool
            else { return nil }
        
        self.identifier = identifier
        self.firstName = firstName
        self.lastName = lastName
        self.avatar = avatar
        self.isModerator = isModerator
    }
}

extension ChatterMessage.Entity: HigiAPIJSONDeserializer {
    
    init?(dictionary: NSDictionary) {
        guard let identifier = dictionary["EntityId"] as? String,
        let typeString = dictionary["EntityType"] as? String,
            let type = ChatterRequest.EntityType.mapping[typeString] else {
                return nil
        }
        
        self.identifier = identifier
        self.type = type
    }
}

extension ChatterMessage: HigiAPIJSONDeserializer {
    
    init?(dictionary: NSDictionary) {
        guard let identifier = dictionary["Id"] as? String,
        let userDict = dictionary["User"] as? NSDictionary,
        let user = ChatterMessage.User(dictionary: userDict),
        let parentEntity = ChatterMessage.Entity(dictionary: dictionary),
        let nestingLevel = dictionary["NestingLevel"] as? Int,
        let text = dictionary["Text"] as? String,
        let dateString = dictionary["Date"] as? String,
        let date = NSDateFormatter.ISO8601DateFormatter.dateFromString(dateString),
        let isDeleted = dictionary["IsDeleted"] as? Bool
            else {
                return nil
        }
        
        var replies: [ChatterMessage] = []
        if let replyCollection = dictionary["Replies"] as? [NSDictionary] {
            for replyDict in replyCollection {
                if let reply = ChatterMessage(dictionary: replyDict) {
                    replies.append(reply)
                }
            }
        }
        
        self.identifier = identifier
        self.user = user
        self.parentEntity = parentEntity
        self.nestingLevel = nestingLevel
        self.text = text
        self.date = date
        self.isDeleted = isDeleted
        self.replies = replies
    }
}
