//
//  FeedItem.swift
//  higi
//
//  Created by Remy Panicker on 7/27/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

// MARK: - Content

struct Content {}

// MARK: - Actions

extension Content {
    
    /**
     *  Represents actions that the current user has taken on a content item.
     */
    struct Actions {
        
        /// Whether or not the current user has commented on a content item.
        let hasCommented: Bool
        
        /// Whether or not the current user has liked a content item.
        let hasLiked: Bool
    }
}

// MARK: JSON

extension Content.Actions: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let hasCommented = dictionary["hasCommented"] as? Bool,
            let hasLiked = dictionary["hasCommented"] as? Bool else {
                return nil
        }
        
        self.hasCommented = hasCommented
        self.hasLiked = hasLiked
    }
}

// MARK: - Permissions

extension Content {
    
    /**
     Represents a collection of permissions for actions which can be taken on a content item and specifies which actions the current user can take on that content item.
     */
    struct Permissions {
        
        /// Whether or not the current user can comment on a content item.
        let canComment: Bool
        
        /// Whether or not the current user can edit a content item.
        let canEdit: Bool
        
        /// Whether or not the current user can delete a content item.
        let canDelete: Bool
        
        /// Whether or not the current user can like a content item.
        let canLike: Bool
    }
}

// MARK: JSON

extension Content.Permissions: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let canComment = dictionary["canReply"] as? Bool,
            let canEdit = dictionary["canEdit"] as? Bool,
            let canDelete = dictionary["canDelete"] as? Bool,
            let canLike = dictionary["canLike"] as? Bool else {
                return nil
        }
        
        self.canComment = canComment
        self.canEdit = canEdit
        self.canDelete = canDelete
        self.canLike = canLike
    }
}

// MARK: - Protocols

/**
 *  Types conforming to this protocol represent content items which can have actions performed on them.
 */
protocol ContentActionable {
    
    var actions: Content.Actions { get }
    
    var permissions: Content.Permissions { get }
}

/**
 *  Types conforming to this protocol represent content items which can be commented on.
 */
protocol ContentCommentable {
    
    var commentCount: Int { get }
}

/**
 *  Types conforming to this protocol represent content items which can be liked.
 */
protocol ContentLikeable {
    
    var likeCount: Int { get }
}

/**
 Convenience protocol which specifies conformance to protocols typical of content items which can be interacted with.
 */
protocol ContentInteractable: class, UniquelyIdentifiable, ContentActionable, ContentLikeable, ContentCommentable {}
