//
//  CommunityDetailController.swift
//  higi
//
//  Created by Remy Panicker on 6/9/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class CommunityDetailController {
    
    private(set) var community: Community
    
    private lazy var session: NSURLSession = APIClient.sharedSession
    
    init(community: Community) {
        self.community = community
    }
}

extension CommunityDetailController {
    
    func updateSubscription(community: Community, filter: CommunitySubscribeRequest.Filter, user: User, success: (community: Community) -> Void, failure: (error: NSError?) -> Void) {
        
        CommunitySubscribeRequest(filter: filter, communityId: community.identifier, userId: user.identifier).request({ [weak self] (request, error) in
            
            guard let strongSelf = self,
                let request = request else {
                    failure(error: nil)
                    return
            }
            
            let task = NSURLSessionTask.JSONTask(strongSelf.session, request: request, success: { [weak strongSelf] (JSON, response) in
                guard let strongSelf = strongSelf else { return }
                strongSelf.fetch(community, success: success, failure: failure)
                }, failure: { (error, response) in
                    failure(error: error)
            })
            task.resume()
            })
    }
    
    func fetch(community: Community, success: (community: Community) -> Void, failure: (error: NSError?) -> Void) {
        
        CommunityRequest(communityId: community.identifier).request({ [weak self] (request, error) in
            
            guard let strongSelf = self, let request = request else {
                failure(error: nil)
                return
            }
            
            let task = NSURLSessionTask.JSONTask(strongSelf.session, request: request, success: { [weak strongSelf] (JSON, response) in
                guard strongSelf != nil else { return }
                
                if let community = ResourceDeserializer.parse(JSON, resource: Community.self) {
                    success(community: community)
                } else {
                    failure(error: nil)
                }
                
                }, failure: { [weak strongSelf] (error, response) in
                    guard strongSelf != nil else { return }
                    
                    failure(error: error)
                })
            task.resume()
            })
    }
}
