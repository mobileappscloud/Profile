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
    
    private lazy var session: NSURLSession = APIClient.sharedSession
    
    var fetchTask: NSURLSessionDataTask?
    var nextPagingTask: NSURLSessionDataTask?
    
    lazy private var likeNetworkController = LikeNetworkController()
    
    weak var refreshTimer: NSTimer?
    private var refreshCompletionHandler: (() -> Void)?
    
    deinit {
        fetchTask?.cancel()
        nextPagingTask?.cancel()
    }
}

// MARK: - Network Request

extension FeedController {
    
    func fetch(entity: Post.Entity, entityId: String, success: () -> Void, failure: (error: NSError?) -> Void) {

        FeedCollectionRequest(entity: entity, entityId: entityId).request({ [weak self] (request, error) in
            
            guard let request = request,
                let session = self?.session else {
                    failure(error: nil)
                    return
            }
            
            self?.fetchTask = NSURLSessionTask.JSONTask(session, request: request, success: { [weak self] (JSON, response) in
                
                guard let strongSelf = self else { return }
                
                let result = CollectionDeserializer.parse(collectionJSONResponse: JSON, forResource: Post.self)
                strongSelf.posts = result.collection
                strongSelf.paging = result.paging
                strongSelf.fetchTask = nil
                success()
                
                }, failure: { [weak self] (error, response) in
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
        
        PagingRequest(URL: URL).request({ [weak self] (request, error) in
            
            guard let request = request else {
                failure(error: nil)
                return
            }
            
            self?.performNextFetch(request, success: success, failure: failure)
            })
    }
    
    private func performNextFetch(request: NSURLRequest, success: () -> Void, failure: (error: NSError?) -> Void) {
        
        nextPagingTask = NSURLSessionTask.JSONTask(session, request: request, success: { [weak self] (JSON, response) in
            
            guard let strongSelf = self else { return }
            
            let result = CollectionDeserializer.parse(collectionJSONResponse: JSON, forResource: Post.self)
            strongSelf.posts.appendContentsOf(result.collection)
            strongSelf.paging = result.paging
            strongSelf.nextPagingTask = nil
            success()
            
            }, failure: { (error, response) in
                self.nextPagingTask = nil
                failure(error: error)
        })
        
        if let nextPagingTask = nextPagingTask {
            nextPagingTask.resume()
        }
    }
}

extension FeedController {
    
    func like<T: ContentInteractable>(post: T, forUser user: User, success: (() -> Void)?, failure: ((error: NSError?) -> Void)?) -> T {
        
        let entityType = ChatterRequest.EntityType.Post
        let entityId = post.identifier
        
        likeNetworkController.like(entityType, entityId: entityId, forUser: user, success: success, failure: failure)
        
        return locallyUpdate(post, incrementedLikeCount: 1)
    }
    
    func unlike<T: ContentInteractable>(post: T, success: (() -> Void)?, failure: ((error: NSError?) -> Void)?) -> T {
        
        let entityType = ChatterRequest.EntityType.Post
        let entityId = post.identifier
        
        likeNetworkController.unlike(entityType, entityId: entityId, success: success, failure: failure)
        
        return locallyUpdate(post, incrementedLikeCount: -1)
    }
    
    func locallyUpdate<T: ContentInteractable>(post: T, incrementedLikeCount: Int) -> T {
        let newPost = ActionBarUtility.copy(post, incrementedLikeCount: incrementedLikeCount) as! Post
        if let index = posts.indexOf({ $0.identifier == post.identifier }) {
            var newPosts = posts
            newPosts[index] = newPost
            posts = newPosts
            
            return newPost as! T
        } else {
            return post
        }
    }
}

// MARK: - Scheduled Refresh

/** @internal: This timer is kept on the data controller to prevent retain cycle which can occur when storing the timer on the view controller. The run loop holds a strong reference to the target of the scheduled event. Even if the view controller stores the timer as a weak property, `deinit` will never be called on the view controller because the run loop is holding a strong reference to the view controller. Moving the timer to the data controller allows us to deinit our view controller and send a message to invalidate and release the timer on our data controller, thus cleaning up all memory. For a detailed explanation, reference https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/Timers/Timers.html#//apple_ref/doc/uid/10000061i
 */

extension FeedController {
    
    func scheduleRefresh(completion: (() -> Void)?) {
        let oneHour: NSTimeInterval = 3600
        let timer = NSTimer(timeInterval: oneHour, target: self, selector: #selector(self.handleRefreshTimer(_:)), userInfo: nil, repeats: true)
        timer.tolerance = oneHour * 0.10
        
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
        
        self.refreshTimer = timer
        self.refreshCompletionHandler = completion
    }
    
    @objc private func handleRefreshTimer(sender: NSTimer) {
        refreshCompletionHandler?()
    }
}
