//
//  CommunitiesController.swift
//  higi
//
//  Created by Remy Panicker on 3/25/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

protocol CommunityCollectionStorage {
    
    var communitiesSet: Set<Community> { get }
    var communities: [Community] { get }
}

protocol CommunitiesNetworkRequest {
    
    var session: NSURLSession { get }
    
    var paging: Paging? { get }
    
    func fetch(success: () -> Void, failure: (error: NSError?) -> Void)
    
    func fetchNext(success: () -> Void, failure: (error: NSError?) -> Void)
}

protocol CommunitiesController: CommunityCollectionStorage, CommunitiesNetworkRequest {}

final class JoinedCommunitiesController: CommunitiesController {
    
    enum State {
        case Unknown
        case PerformingInitialDataTask
        case CompletedInitialDataTask
        case FailedInitialDataTask
        case PerformingPagingTask
        case CompletedPagingTask
        case FailedPagingTask
    }
    
    private(set) var communitiesSet: Set<Community> = []
    private(set) var communities: [Community] = []
    
    private(set) var paging: Paging? = nil
    
    lazy var session: NSURLSession = {
        return HigiAPIClient.session()
    }()
 
    private var fetchTask: NSURLSessionDataTask?
    private var nextPagingTask: NSURLSessionDataTask?
    
    deinit {
        session.invalidateAndCancel()
    }
}

extension JoinedCommunitiesController {
    
    func taskState() -> State {
        if let fetchTask = fetchTask {
            switch fetchTask.state {
            case .Suspended:
                fallthrough
            case .Running:
                return .PerformingInitialDataTask
            case .Canceling:
                return .FailedInitialDataTask
            case .Completed:
                return .CompletedInitialDataTask
            }
        } else if let nextPagingTask = nextPagingTask {
            switch nextPagingTask.state {
            case .Suspended:
                fallthrough
            case .Running:
                return .PerformingPagingTask
            case .Canceling:
                return .FailedPagingTask
            case .Completed:
                return .CompletedPagingTask
            }
        } else {
            return .Unknown
        }
    }
}

extension JoinedCommunitiesController {
    
    func fetch(success: () -> Void, failure: (error: NSError?) -> Void) {
//        guard let request = CommunityCollectionRequest.request(.Joined) else {
//            failure(error: nil)
//            return
//        }
//        
//        fetchTask = NSURLSessionTask.JSONTask(session, request: request, success: { (JSON, response) in
//            
//            CommunityCollectionDeserializer.parse(JSON, success: { (communities, paging) in
//             
//                self.communitiesSet = Set(communities)
//                self.communities = communities
//                self.paging = paging
//                success()
//                
//                }, failure: { (error) in
//                    failure(error: error)
//            })
//            
//            }, failure: { (error, response) in
//             failure(error: error)
//        })
//        if let fetchTask = fetchTask {
//            fetchTask.resume()
//        }
        
        
        let fileName = "communities-collection"
        let filePath = NSBundle.mainBundle().pathForResource(fileName, ofType: "json")!
        let data = NSData(contentsOfFile: filePath)!
        let JSON = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as! NSDictionary
        
        CommunityCollectionDeserializer.parse(JSON, success: { (communities, paging) in
            
            self.communitiesSet = Set(communities)
            self.communities = communities
            self.paging = paging
            success()
            
            }, failure: { (error) in
                failure(error: error)
        })
    }
    
    func fetchNext(success: () -> Void, failure: (error: NSError?) -> Void) {
        guard let URL = paging?.next else {
            success()
            return
        }
        
        let request = NSURLRequest(URL: URL)
        nextPagingTask = NSURLSessionTask.JSONTask(session, request: request, success: { (JSON, response) in
            CommunityCollectionDeserializer.parse(JSON, success: { (communities, paging) in
                
                // Use server response as basis for set. Union of the two sets will exclude stale data currently in-memory.
                var newSet = Set(communities)
                newSet.unionInPlace(self.communities)
                
                let sortedCommunities = newSet.sort({ community1, community2 in
                    guard let date1 = community1.joinDate,
                        let date2 = community2.joinDate else {
                            return true
                    }
                    return (date1.compare(date2) != .OrderedAscending)
                })
                
                self.communitiesSet = newSet
                self.communities = sortedCommunities
                self.paging = paging
                success()
                
                
                }, failure: { (error) in
                    failure(error: error)
            })
            }, failure: { (error, response) in
                failure(error: error)
        })
        if let nextPagingTask = nextPagingTask {
            nextPagingTask.resume()
        }
    }
}
