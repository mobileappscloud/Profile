//
//  CommunitiesController.swift
//  higi
//
//  Created by Remy Panicker on 3/25/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class CommunitiesController {
    
    // MARK: Properties
    
    typealias Filter = CommunityCollectionRequest.Filter
    let filter: Filter

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
        CommunityCollectionRequest.request(filter, completion: { [weak self] (request, error) in
            
            guard let request = request,
            let session = self?.session else {
                failure(error: nil)
                return
            }

            self?.fetchTask = NSURLSessionTask.JSONTask(session, request: request, success: { [weak self] (JSON, response) in
                
                CommunityCollectionDeserializer.parse(JSON, success: { [weak self] (communities, paging) in
                    
                    self?.append(communities)
                    
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
            CommunityCollectionDeserializer.parse(JSON, success: { [weak self] (communities, paging) in
                
                self?.append(communities)
                
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

extension CommunitiesController {
    
    func remove(communities: [Community]) {
        var newCollection = self.communities
        for community in communities {
            guard let index = newCollection.indexOf({$0.identifier == community.identifier }) else { continue }
            
            newCollection.removeAtIndex(index)
        }
        sort(&newCollection, filter: filter)
        self.communities = newCollection
    }
    
    func append(communities: [Community]) {
        var newCollection = self.communities
        newCollection.appendContentsOf(communities)
        sort(&newCollection, filter: filter)
        self.communities = newCollection
    }
}

extension CommunitiesController {
    
    private func sort(inout communities: [Community], filter: Filter) {
        if filter == .Joined {
            communities.sortInPlace({
                if let aJoinDate = $0.joinDate, let bJoinDate = $1.joinDate {
                    return aJoinDate.compare(bJoinDate) == .OrderedDescending
                } else {
                    return false
                }
            })
        } else if filter == .Unjoined {
            communities.sortInPlace({
                if let aCreateDate = $0.createDate, let bCreateDate = $1.createDate {
                    return aCreateDate.compare(bCreateDate) == .OrderedDescending
                } else {
                    return false
                }
            })
        }
    }
}
