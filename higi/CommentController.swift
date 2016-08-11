//
//  CommentController.swift
//  higi
//
//  Created by Remy Panicker on 7/18/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class CommentController {

    /// Parent post from which comment thread originated from
    private(set) var post: Post

    /// Interactive content which a comment is targeted towards. Ex: If a user is replying to a comment, this property would refer to the comment being replied to.
    var targetInteractiveContent: ContentInteractable
    
    private(set) var comments: [Comment] = []
    
    private(set) var paging: Paging?
    
    private(set) var fetchTask: NSURLSessionTask?
    private(set) var postCommentTask: NSURLSessionTask?
    
    private lazy var likeNetworkController = LikeNetworkController()
    
    private lazy var commentNetworkController = CommentNetworkController()
    
    init(post: Post, targetInteractiveContent: ContentInteractable) {
        self.post = post
        self.targetInteractiveContent = targetInteractiveContent
    }
}

// MARK: - Network Requests

extension CommentController {
    
    func fetchComments(success: () -> Void, failure: () -> Void) {
        
        let entity = Comment.Entity(identifier: post.identifier, type: .Post)
        
        commentNetworkController.fetchComments(entity.type, entityId: entity.identifier, success: { [weak self] (comments, paging) in
            guard let strongSelf = self else { return }
            
            strongSelf.comments = comments
            strongSelf.paging = paging
            success()
            }, failure: { [weak self] (error) in
                guard self != nil else { return }
                
                failure()
        })
    }
}

extension CommentController {
    
    func postComment(text: String, user: User, success: () -> Void, failure: () -> Void) {
        
        commentNetworkController.postComment(targetInteractiveContent, text: text, user: user, success: { [weak self] (comment) in
            guard let strongSelf = self else { return }
            
            strongSelf.insert(comment)
            success()
            }, failure: { [weak self] (error) in
                guard self != nil else { return }
                failure()
            })
    }
}

extension CommentController {
    
    func like<T: ContentInteractable>(content: T, forUser user: User, success: (() -> Void)?, failure: ((error: NSError?) -> Void)?) -> T {
        
        let entityType = (content is Post) ? ChatterRequest.EntityType.Post : ChatterRequest.EntityType.Comment
        let entityId = content.identifier
        
        likeNetworkController.like(entityType, entityId: entityId, forUser: user, success: success, failure: failure)
        
        return locallyUpdate(content, incrementedLikeCount: 1)
    }
    
    func unlike<T: ContentInteractable>(content: T, success: (() -> Void)?, failure: ((error: NSError?) -> Void)?) -> T {
        
        let entityType = (content is Post) ? ChatterRequest.EntityType.Post : ChatterRequest.EntityType.Comment
        let entityId = content.identifier
        
        likeNetworkController.unlike(entityType, entityId: entityId, success: success, failure: failure)
        
        return locallyUpdate(content, incrementedLikeCount: -1)
    }
}

// MARK: - CRUD

extension CommentController {
    
    func locallyUpdate<T: ContentInteractable>(content: T, incrementedLikeCount: Int) -> T {
        let newContent = ActionBarUtility.copy(content, incrementedLikeCount: incrementedLikeCount)
        update(newContent)
        return newContent
    }
    
    private func update<T: ContentInteractable>(content: T) {
        if let post = content as? Post {
            self.post = post
        } else if let comment = content as? Comment {
            if comment.isReply {
                guard let parentCommentIndex = comments.indexOf({ $0.identifier == comment.parentEntity.identifier }) else { return }
                
                let parentComment = comments[parentCommentIndex]
                guard let replyIndex = parentComment.replies.indexOf({ $0.identifier == comment.identifier }) else { return }
                
                var newReplies = parentComment.replies
                newReplies[replyIndex] = comment
                let newParentComment = parentComment.copy(newReplies)
                comments[parentCommentIndex] = newParentComment
            } else {
                guard let commentIndex = comments.indexOf({ $0.identifier == comment.identifier }) else { return }
                comments[commentIndex] = comment
            }
        }
    }
    
    private func insert(comment: Comment) {
        if comment.isReply {
            if let parentCommentIndex = comments.indexOf({ $0.identifier == comment.parentEntity.identifier }) {
                let parentComment = comments[parentCommentIndex]
                var newReplies = parentComment.replies
                newReplies.insert(comment, atIndex: 0)
                let newParentComment = parentComment.copy(newReplies)
                comments[parentCommentIndex] = newParentComment
            }
        } else {
            var newComments = comments
            newComments.insert(comment, atIndex: 0)
            comments = newComments
            
            let updatedPost = post.copy(comments.count)
            post = updatedPost
        }
    }
}
