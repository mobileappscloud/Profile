//
//  CommentController.swift
//  higi
//
//  Created by Remy Panicker on 7/18/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class CommentController {
    
//    private(set) var post: Post
    var post: Post
    
    private(set) var comments: [Comment] = []
    
    private(set) var paging: Paging?
    
    lazy private var session: NSURLSession = {
        return APIClient.sharedSession
    }()
    
    init(post: Post) {
        self.post = post
    }
}

extension CommentController {
    
    private func postEntity() -> Comment.Entity {
        return Comment.Entity(identifier: post.identifier, type: .Post)
    }
}

extension CommentController {
    
    func fetchComments(success: () -> Void, failure: () -> Void) {
        
        ChatterCollectionRequest.request(postEntity(), completion: { [weak self] (request, error) in
            guard let strongSelf = self,
                let request = request else {
                    failure()
                    return
            }
            
            let task = NSURLSessionTask.JSONTask(strongSelf.session, request: request, success: { [weak strongSelf] (JSON, response) in
                
                CollectionDeserializer.parse(JSON, resource: Comment.self, success: { [weak strongSelf] (messages, paging) in
                    
                    strongSelf?.comments = messages
                    strongSelf?.paging = paging
                    
                    success()
                    
                    }, failure: { (error) in
                        failure()
                })
                
                
                }, failure: { (error, response) in
                    failure()
            })
            task.resume()
        })
    }
}
