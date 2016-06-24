//
//  CommunityDetailController.swift
//  higi
//
//  Created by Remy Panicker on 6/9/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class CommunityDetailController {
    
    private(set) var community: Community
    
    lazy var session: NSURLSession = {
        return HigiAPIClient.session()
    }()
    
    init(community: Community) {
        self.community = community
    }
    
    deinit {
        session.invalidateAndCancel()
    }
}

extension CommunityDetailController {
    
    func updateSubscription(community: Community, filter: CommunitySubscribeRequest.Filter, user: User, success: (community: Community) -> Void, failure: (error: NSError?) -> Void) {
        
        CommunitySubscribeRequest.request(filter, community: community, user: user, completion: { [weak self] (request, error) in
            
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
        
        CommunityRequest.request(community, completion: { [weak self] (request, error) in
            
            guard let strongSelf = self, let request = request else {
                failure(error: nil)
                return
            }
            
            let task = NSURLSessionTask.JSONTask(strongSelf.session, request: request, success: { [weak strongSelf] (JSON, response) in
                
                guard let strongSelf = strongSelf,
                    let JSON = JSON as? NSDictionary,
                    let dictionary = JSON["data"] as? NSDictionary else {
                        failure(error: nil)
                        return
                }
                guard let community = Community(dictionary: dictionary) else {
                    failure(error: nil)
                    return
                }
                
                strongSelf.community = community
                success(community: community)
                
                }, failure: { (error, response) in
                    failure(error: error)
            })
            task.resume()
            })
    }
}
