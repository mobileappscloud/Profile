//
//  FeedController.swift
//  higi
//
//  Created by Remy Panicker on 6/21/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class FeedController {
    
    private(set) var posts: [Post] = []
    
    private(set) var paging: Paging? = nil
    
    lazy var session: NSURLSession = {
        return HigiAPIClient.session()
    }()
    
    var fetchTask: NSURLSessionDataTask?
    var nextPagingTask: NSURLSessionDataTask?
    
    deinit {
        session.invalidateAndCancel()
    }
}

// MARK: - Network Request

extension FeedController {
    
    func fetch(entity: Post.Entity, entityId: String, success: () -> Void, failure: (error: NSError?) -> Void) {
        FeedCollectionRequest.request(entity, entityId: entityId, completion: { [weak self] (request, error) in
            
            guard let request = request,
                let session = self?.session else {
                    failure(error: nil)
                    return
            }
            
            self?.fetchTask = NSURLSessionTask.JSONTask(session, request: request, success: { [weak self] (JSON, response) in
                
                FeedCollectionDeserializer.parse(JSON, success: { [weak self] (posts, paging) in
                    
                    // TODO: Remove stub!
                    var fakePosts: [Post] = []
                    for index in 0...20 {
                        let post = Post(identifier: String(index), type: .Default, template: .Text, heading: "Hi \(index)", subheading: "This is a subheading", publishDate: NSDate(), topText: nil, bottomText: nil)
                        fakePosts.append(post)
                    }
                    self?.posts = fakePosts
                    
//                    self?.posts.appendContentsOf(posts)
                    
                    self?.paging = paging
                    self?.fetchTask = nil
                    success()
                    
                    }, failure: { (error) in
                        self?.fetchTask = nil
                        failure(error: error)
                })
                
                }, failure: { (error, response) in
                    self?.fetchTask = nil
                    failure(error: error)
            })
            if let fetchTask = self?.fetchTask {
                fetchTask.resume()
            }
            
            })
    }
    
    func fetchNext(success: () -> Void, failure: (error: NSError?) -> Void) {
        if let nextPagingTask = nextPagingTask where nextPagingTask.state == .Running {
            return
        }
        guard let URL = paging?.next else {
            success()
            return
        }
        
        PagingRequest.request(URL, completion: { [weak self] (request, error) in
            
            guard let request = request else {
                failure(error: nil)
                return
            }
            
            self?.performNextFetch(request, success: success, failure: failure)
            })
    }
    
    private func performNextFetch(request: NSURLRequest, success: () -> Void, failure: (error: NSError?) -> Void) {
        
        nextPagingTask = NSURLSessionTask.JSONTask(session, request: request, success: { [weak self] (JSON, response) in
            FeedCollectionDeserializer.parse(JSON, success: { [weak self] (posts, paging) in
                
                self?.posts.appendContentsOf(posts)
                
                self?.paging = paging
                self?.nextPagingTask = nil
                success()
                
                
                }, failure: { (error) in
                    self?.nextPagingTask = nil
                    failure(error: error)
            })
            }, failure: { (error, response) in
                self.nextPagingTask = nil
                failure(error: error)
        })
        
        if let nextPagingTask = nextPagingTask {
            nextPagingTask.resume()
        }
    }
}
