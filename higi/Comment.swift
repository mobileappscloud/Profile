//
//  Comment.swift
//  higi
//
//  Created by Remy Panicker on 7/19/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class Comment: UniquelyIdentifiable, ContentInteractable {
    
    struct User: UniquelyIdentifiable {
        let identifier: String
        let firstName: String
        let lastName: String
        let avatar: MediaAsset
        let isModerator: Bool
    }
    
    struct Entity: UniquelyIdentifiable {
        let identifier: String
        let type: ChatterRequest.EntityType
    }
    
    /// Unique identifier for the comment.
    let identifier: String
    
    /// Author of the comment.
    let user: User
    
    /// Entity which this comment is targeted towards.
    let parentEntity: Entity
    
    /// Nesting level of the current comment within a conversation thread.
    let nestingLevel: Int
    
    /**
     Collection of comments targeted towards the current comment.
     
    _Note: This can be considered a collection of replies because a comment targeted towards a comment is denoted as a reply._
     */
    let replies: [Comment]
    
    /// Message content for the comment.
    let text: String
    
    /// Date the comment was posted.
    let date: NSDate
    
    /// Whether or not the current comment is deleted.
    let isDeleted: Bool
    
    /// Number of comments targeted towards the current comment.
    let commentCount: Int
    
    /// Number of likes for the current comment.
    let likeCount: Int
    
    /// Actions the current user has taken towards the current comment.
    let actions: Content.Actions
    
    /// Permissions on actions which the current user can take on the current comment.
    let permissions: Content.Permissions
    
    required init(identifier: String, user: User, parentEntity: Entity, nestingLevel: Int, text: String, date: NSDate, isDeleted: Bool, replies: [Comment], commentCount: Int, likeCount: Int, actions: Content.Actions, permissions: Content.Permissions) {
        
        self.identifier = identifier
        self.user = user
        self.parentEntity = parentEntity
        self.nestingLevel = nestingLevel
        self.text = text
        self.date = date
        self.isDeleted = isDeleted
        self.replies = replies
        self.commentCount = commentCount
        self.likeCount = likeCount
        self.actions = actions
        self.permissions = permissions
    }
}

extension Comment {
    
    /// Whether or not a comment is a reply to another comment.
    var isReply: Bool {
        return parentEntity.type == .Comment && nestingLevel > 0
    }
}

// MARK: - Copying

extension Comment {
    
    func copy(likeCount: Int, actions: Content.Actions) -> Comment {
        return Comment(identifier: self.identifier, user: self.user, parentEntity: self.parentEntity, nestingLevel: self.nestingLevel, text: self.text, date: self.date, isDeleted: self.isDeleted, replies: self.replies, commentCount: self.commentCount, likeCount: likeCount, actions: actions, permissions: self.permissions)
    }
}

extension Comment {
    
    func copy(replies: [Comment]) -> Comment {
        return Comment(identifier: self.identifier, user: self.user, parentEntity: self.parentEntity, nestingLevel: self.nestingLevel, text: self.text, date: self.date, isDeleted: self.isDeleted, replies: replies, commentCount: replies.count, likeCount: self.likeCount, actions: self.actions, permissions: self.permissions)
    }
}

// MARK: - JSON

extension Comment.User: JSONDeserializable, JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let identifier = dictionary["id"] as? String,
            let firstName = dictionary["firstName"] as? String,
            let lastName = dictionary["lastName"] as? String,
            let avatarDict = dictionary["avatar"] as? NSDictionary,
            let avatar = MediaAsset(dictionary: avatarDict),
            let isModerator = dictionary["isModerator"] as? Bool
            else { return nil }
        
        self.identifier = identifier
        self.firstName = firstName
        self.lastName = lastName
        self.avatar = avatar
        self.isModerator = isModerator
    }
}

extension Comment.Entity: JSONDeserializable, JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let identifier = dictionary["entityId"] as? String,
            let typeString = dictionary["entityType"] as? String,
            let type = Comment.Entity.typeStrings[typeString]
            else { return nil }
        
        self.identifier = identifier
        self.type = type
    }
    
    private static let typeStrings: [String : ChatterRequest.EntityType] = [
        "Achievement" : .Achievement,
        "Challenge" : .Challenge,
        "Comment" : .Comment,
        "Reward" : .Reward,
        "Post" : .Post,
        "Community" : .Community
    ]
}

extension Comment: JSONDeserializable, JSONInitializable {
    
    convenience init?(dictionary: NSDictionary) {
        guard let identifier = dictionary["id"] as? String,
            let userDict = dictionary["user"] as? NSDictionary,
            let user = Comment.User(dictionary: userDict),
            let parentEntity = Comment.Entity(dictionary: dictionary),
            let nestingLevel = dictionary["nestingLevel"] as? Int,
            let text = dictionary["text"] as? String,
            let dateString = dictionary["date"] as? String,
            let date = NSDateFormatter.ISO8601DateFormatter.dateFromString(dateString),
            let isDeleted = dictionary["isDeleted"] as? Bool,
            let commentCount = dictionary["commentCount"] as? Int,
            let likeCount = dictionary["likeCount"] as? Int,
            let actionsDict = dictionary["actions"] as? NSDictionary,
            let actions = Content.Actions(dictionary: actionsDict),
            let permissionsDict = dictionary["permissions"] as? NSDictionary,
            let permissions = Content.Permissions(dictionary: permissionsDict)
            else { return nil }
        
        var replies: [Comment] = []
        if let replyCollection = dictionary["replies"] as? [NSDictionary] {
            for replyDict in replyCollection {
                if let comment = Comment(dictionary: replyDict) {
                    replies.append(comment)
                }
            }
        }
        
        self.init(identifier: identifier, user: user, parentEntity: parentEntity, nestingLevel: nestingLevel, text: text, date: date, isDeleted: isDeleted, replies: replies, commentCount: commentCount, likeCount: likeCount, actions: actions, permissions: permissions)
    }
}
