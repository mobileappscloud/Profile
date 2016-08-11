//
//  CommentNetworkController.swift
//  higi
//
//  Created by Remy Panicker on 8/3/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

/// Network controller which interfaces with comments from the chatter service.
final class CommentNetworkController: NetworkRequestable {
    
    private(set) lazy var session: NSURLSession = APIClient.sharedSession
}

extension CommentNetworkController {
    
    /**
     Requests a collection of comments for a content item.
     
     - parameter entityType: The type of content item being commented on.
     - parameter entityId:   The identifier of the content item being commented on.
     - parameter success:    Completion block executed upon success.
     - parameter failure:    Completion block executed upon failure.
     */
    func fetchComments(entityType: ChatterRequest.EntityType, entityId: String, success: (comment: [Comment], paging: Paging?) -> Void, failure: (error: NSError?) -> Void) {
        
        ChatterCollectionRequest(entityType: entityType, entityId: entityId).request({ [weak self] (request, error) in
            guard let strongSelf = self,
                let request = request where error == nil else {
                    failure(error: error)
                    return
            }
            
            let task = NSURLSessionTask.JSONTask(strongSelf.session, request: request, success: { [weak strongSelf] (JSON, response) in
                guard let strongSelf = strongSelf else { return }
                
                CollectionDeserializer.parse(JSON, resource: Comment.self, success: { [weak strongSelf] (comments, paging) in
                    guard strongSelf != nil else { return }
                    
                    success(comment: comments, paging: paging)
                    }, failure: { [weak strongSelf] (error) in
                        guard strongSelf != nil else { return }
                        
                        failure(error: error)
                })
                
                }, failure: { [weak strongSelf] (error, response) in
                    guard strongSelf != nil else { return }
                    
                    failure(error: error)
            })
            task.resume()
            })
    }
}

extension CommentNetworkController {
    
    /**
     Adds a comment targeted at a content item.
     
     - parameter targetContent: Content item a comment is being targeted towards.
     - parameter text:          Text for the comment.
     - parameter user:          User authoring the comment.
     - parameter success:       Completion block executed upon success.
     - parameter failure:       Completion block executed upon failure.
     */
    func postComment(targetContent: ContentInteractable, text: String, user: User, success: (comment: Comment) -> Void, failure: (error: NSError?) -> Void) {
        
        let entityType: ChatterRequest.EntityType
        if targetContent is Post {
            entityType = .Post
        } else if targetContent is Comment {
            entityType = .Comment
        } else {
            fatalError("Unsupported target interactive content detected!")
        }
        let entityId = targetContent.identifier
        
        ChatterCommentCreateRequest(text: text, userId: user.identifier, entityType: entityType, entityId: entityId).request({ [weak self] (request, error) in
            
            guard let strongSelf = self,
                let request = request where error == nil else {
                    failure(error: error)
                    return
            }
            
            let task = NSURLSessionTask.JSONTask(strongSelf.session, request: request, success: { [weak strongSelf] (JSON, response) in
                guard let strongSelf = strongSelf else { return }
                
                ResourceDeserializer.parse(JSON, resource: Comment.self, success: { [weak strongSelf] (comment) in
                    guard strongSelf != nil else { return }
                    
                    success(comment: comment)
                    }, failure: { [weak strongSelf] error in
                        guard strongSelf != nil else { return }
                        
                        failure(error: error)
                })
                
                }, failure: { [weak strongSelf] (error, response) in
                    guard strongSelf != nil else { return }
                    
                    failure(error: error)
                })
            task.resume()
            })
    }
}
