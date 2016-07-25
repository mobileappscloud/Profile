//
//  FeedCommentController.swift
//  higi
//
//  Created by Remy Panicker on 7/18/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class FeedCommentController {
    
//    private(set) var post: Post
    var post: Post
    
    private(set) var comments: [ChatterMessage] = []
    
    private(set) var paging: Paging?
    
    lazy private var session: NSURLSession = {
        return APIClient.session()
    }()
    
    init(post: Post) {
        self.post = post
    }
}

extension FeedCommentController {
    
    private func postEntity() -> ChatterMessage.Entity {
        return ChatterMessage.Entity(identifier: post.identifier, type: .FeedPost)
    }
}

extension FeedCommentController {
    
    func fetchComments(success: () -> Void, failure: () -> Void) {
        
        ChatterCollectionRequest.request(postEntity(), completion: { [weak self] (request, error) in
            guard let strongSelf = self,
                let request = request else {
                    failure()
                    return
            }
            
            let task = NSURLSessionTask.JSONTask(strongSelf.session, request: request, success: { [weak strongSelf] (JSON, response) in
                
                CollectionDeserializer.parse(JSON, resource: ChatterMessage.self, success: { [weak strongSelf] (messages, paging) in
                    
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
