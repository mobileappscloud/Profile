//
//  CommunitiesController.swift
//  higi
//
//  Created by Remy Panicker on 3/25/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class CommunitiesController {
    
    // MARK: Properties
    
    typealias Filter = CommunityCollection.Filter
    let filter: Filter

    private(set) var communitiesSet: Set<Community> = []
    private(set) var communities: [Community] = []
    
    private(set) var paging: Paging? = nil
    
    lazy var session: NSURLSession = {
        return HigiAPIClient.session()
    }()
 
    var fetchTask: NSURLSessionDataTask?
    var nextPagingTask: NSURLSessionDataTask?
    
    
    // MARK: Init
    
    required init(filter: Filter) {
        self.filter = filter
    }
    
    deinit {
        session.invalidateAndCancel()
    }
}

// MARK: - Network Request

extension CommunitiesController {
    
    func fetch(success: () -> Void, failure: (error: NSError?) -> Void) {
        CommunityCollection.request(filter, completion: { (request, error) in
            
            guard let request = request else {
                failure(error: nil)
                return
            }

            self.fetchTask = NSURLSessionTask.JSONTask(self.session, request: request, success: { (JSON, response) in
                
                CommunityCollectionDeserializer.parse(JSON, success: { (communities, paging) in
                    
                    self.communitiesSet = Set(communities)
                    self.communities = communities
                    self.paging = paging
                    self.fetchTask = nil
                    success()
                    
                    }, failure: { (error) in
                        self.fetchTask = nil
                        failure(error: error)
                })
                
                }, failure: { (error, response) in
                    self.fetchTask = nil
                    failure(error: error)
            })
            if let fetchTask = self.fetchTask {
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
        guard let request = PagingRequest.request(URL) else {
            failure(error: nil)
            return
        }
        
        nextPagingTask = NSURLSessionTask.JSONTask(session, request: request, success: { (JSON, response) in
            CommunityCollectionDeserializer.parse(JSON, success: { (communities, paging) in
                
                // Use server response as basis for set. Union of the two sets will exclude stale data currently in-memory.
                var newSet = Set(communities)
                newSet.unionInPlace(self.communities)
                
                self.communitiesSet = newSet
                
                var newCommunities = self.communities
                newCommunities.appendContentsOf(communities)
                self.communities = newCommunities
                
                self.paging = paging
                self.nextPagingTask = nil
                success()
                
                
                }, failure: { (error) in
                    self.nextPagingTask = nil
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
