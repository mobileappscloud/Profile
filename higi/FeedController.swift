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
    
    weak var refreshTimer: NSTimer?
    private var refreshCompletionHandler: (() -> Void)?
    
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
