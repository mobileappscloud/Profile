//
//  FeedItem.swift
//  higi
//
//  Created by Remy Panicker on 7/27/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct Content {
    
    struct Actions {
        let hasCommented: Bool
        let hasLiked: Bool
    }
    
    struct Permissions {
        let canComment: Bool
        let canEdit: Bool
        let canDelete: Bool
        let canLike: Bool
    }
}

// MARK: - Actions

extension Content.Actions: JSONDeserializable, JSONInitializable {
    
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

extension Content.Permissions: JSONDeserializable, JSONInitializable {
    
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

protocol ContentActionable {
    
    var actions: Content.Actions { get }
    
    var permissions: Content.Permissions { get }
}

protocol ContentCommentable {
    
    var commentCount: Int { get }
}

protocol ContentLikeable {
    
    var likeCount: Int { get }
}

protocol ContentInteractable: class, UniquelyIdentifiable, ContentActionable, ContentLikeable, ContentCommentable {}
