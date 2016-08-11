//
//  LikeNetworkController.swift
//  higi
//
//  Created by Remy Panicker on 8/3/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

/// Network controller which interfaces with likes/unlikes from the chatter service.
final class LikeNetworkController: NetworkRequestable {
    
    private(set) lazy var session: NSURLSession = APIClient.sharedSession
}

extension LikeNetworkController {
    
    /**
     Perform network request to like a content item.
     
     - parameter entityType: The type of content item being liked.
     - parameter entityId:   The identifier of the content item being liked.
     - parameter user:       The user object of the user liking a content item.
     - parameter success:    Completion block executed upon success.
     - parameter failure:    Completion block executed upon failure.
     */
    func like(entityType: ChatterRequest.EntityType, entityId: String, forUser user: User, success: (() -> Void)?, failure: ((error: NSError?) -> Void)?) {
        
        ChatterLikeRequest(userId: user.identifier, entityType: entityType, entityId: entityId).request({ [weak self] (request, error) in
            guard let strongSelf = self,
                let request = request where error == nil else {
                    failure?(error: error)
                return
            }
            
            let task = NSURLSessionTask.JSONTask(strongSelf.session, request: request, success: { [weak strongSelf] (JSON, response) in
                guard strongSelf != nil else { return }
                
                success?()
                }, failure: { [weak strongSelf] (error, response) in
                    guard strongSelf != nil else { return }
                    
                    if let response = response where response.statusCodeEnum == .Conflict {
                        success?()
                    } else {
                        failure?(error: error)
                    }
            })
            task.resume()
            
        })
    }
    
    /**
     Perform network request to unlike a content item.
     
     - parameter entityType: The type of content item being liked.
     - parameter entityId:   The identifier of the content item being liked.
     - parameter success:    Completion block executed upon success.
     - parameter failure:    Completion block executed upon failure.
     */
    func unlike(entityType: ChatterRequest.EntityType, entityId: String, success: (() -> Void)?, failure: ((error: NSError?) -> Void)?) {
        
        ChatterUnlikeRequest(entityType: entityType, entityId: entityId).request({ [weak self] (request, error) in
            guard let strongSelf = self,
                let request = request where error == nil else {
                    failure?(error: error)
                    return
            }
            
            let task = NSURLSessionTask.JSONTask(strongSelf.session, request: request, success: { [weak strongSelf] (JSON, response) in
                guard strongSelf != nil else { return }
                
                success?()
                }, failure: { [weak strongSelf] (error, response) in
                    guard strongSelf != nil else { return }
                    
                    failure?(error: error)
                })
            task.resume()
            
            })
    }
}
