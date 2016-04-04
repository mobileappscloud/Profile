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
    
    private(set) var communitiesSet: Set<Community> = []
    private(set) var communities: [Community] = []
    
    private(set) var paging: Paging? = nil
    
    lazy var session: NSURLSession = {
        return HigiAPIClient.session()
    }()
}

extension JoinedCommunitiesController {
    
    func fetch(success: () -> Void, failure: (error: NSError?) -> Void) {
        guard let request = CommunityCollectionRequest.request(.Joined) else {
            failure(error: nil)
            return
        }
        
        
//        let fileName = "communities"
//        let filePath = NSBundle.mainBundle().pathForResource(fileName, ofType: "json")!
//        let data = NSData(contentsOfFile: filePath)!
//        let JSON = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
        
        
//        CommunityCollectionParser.parse(JSON, success: { (communities, paging) in
//            
//            self.communitiesSet = Set(communities)
//            self.communities = communities
//            self.paging = paging
//            success()
//            
//            }, failure: { (error) in
//                failure(error: error)
//        })
        
        
        
        
        let task = NetworkRequest.JSONTask(session, request: request, success: { (JSON, response) in
            
            CommunityCollectionParser.parse(JSON, success: { (communities, paging) in
             
                self.communitiesSet = Set(communities)
                self.communities = communities
                self.paging = paging
                success()
                
                }, failure: { (error) in
                    failure(error: error)
            })
            
            }, failure: { (error, response) in
             failure(error: error)
        })
        task.resume()
    }
    
    func fetchNext(success: () -> Void, failure: (error: NSError?) -> Void) {
        guard let URL = paging?.next else {
            success()
            return
        }
        
        let request = NSURLRequest(URL: URL)
        let task = NetworkRequest.JSONTask(session, request: request, success: { (JSON, response) in
            CommunityCollectionParser.parse(JSON, success: { (communities, paging) in
                
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
        task.resume()
    }
}

//final class UnjoinedCommunitiesController: CommunitiesController {
//    
//    private(set) var communitiesSet: Set<Community> = []
//    private(set) var communities: [Community] = []
//    
//    private(set) var paging: Paging? = nil
//    
//    lazy var session: NSURLSession = {
//        return HigiAPIClient.session()
//    }()
//}
//
//extension UnjoinedCommunitiesController {
//    
//    func fetch(success: () -> Void, failure: () -> Void) {
//        
//    }
//    
//    func fetchNext(success: () -> Void, failure: () -> Void) {
//        
//    }
//}
