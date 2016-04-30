//
//  CommunitySubscribeTask.swift
//  higi
//
//  Created by Remy Panicker on 3/29/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class CommunitySubscribe {}

extension CommunitySubscribe {
    
//    class func request(communityId: String, userId: String?, subscribe: Bool) -> NSURLRequest? {
//        
//        
//    }
    
//    class func request(communityId: String, userId: String?, subscribe: Bool) -> NSURLRequest? {
//        guard let authorization = HigiAPIClient.authorization else { return nil }
//        
//        
//        let organizationId = Utility.organizationId()
////        let userId = JSONWebToken.subject(authorization.accessToken)
//        let relativePath = "/organizations/\(organizationId)/communities/\(communityId)/users/\(userId)"
//        
//    }
    
//    
//    class func task(session: NSURLSession, organizationId: String, communityId: String, userId: String, subscribe: Bool, success: () -> Void, failure: (error: NSError?) -> Void) -> NSURLSessionDataTask {
//        
//        let relativePath = "/organizations/\(organizationId)/communities/\(communityId)/users/\(userId)"
//        let URL = HigiAPIClient.endpointURL(relativePath)
//        let request = NSMutableURLRequest(URL: URL)
//        request.HTTPMethod = subscribe ? HTTPMethod.PUT : HTTPMethod.DELETE
//        
//        let task = NetworkRequest.JSONTask(session, request: request, success: { (JSON, response) in
//                success()
//            }, failure: { (error, response) in
//                // Attempting to remove a user from a community they do not belong to results in a 404. Although this is a client error, we still end up with the desired end result, so treat this case as a success.
//                if !subscribe {
//                    if let response = response as? NSHTTPURLResponse where response.statusCodeEnum == .NotFound {
//                        success()
//                    }
//                }
//                failure(error: error)
//        })
//        return task
//    }
}



extension CommunitySubscribe: HigiAPIRequest {
    
    enum Filter {
        case Join
        case Leave
    }
    
    class func request(filter: Filter, completion: (request: NSURLRequest?, error: NSError?) -> Void) {
        
        // TODO: UNCOMMENT 
        //        let relativePath = "/communities"
        let relativePath = "/community/communities"
        
        var parameters: [String : String] = [:]
        
        authenticatedRequest(relativePath, parameters: parameters, completion: completion)
    }
}
