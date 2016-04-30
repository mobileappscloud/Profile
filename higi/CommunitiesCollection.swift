//
//  CommunitiesRequest.swift
//  higi
//
//  Created by Remy Panicker on 3/31/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class CommunityCollection {}

extension CommunityCollection: HigiAPIRequest {
    
    enum Filter {
        case Joined
        case Unjoined
    }
    
    class func request(filter: Filter, completion: (request: NSURLRequest?, error: NSError?) -> ()) {
        
        // TODO: UNCOMMENT 
//        let relativePath = "/communities"
        let relativePath = "/community/communities"
        
        var parameters: [String : String] = [:]
        
        let filterJoined = filter == .Joined
        parameters["filter"] = "isMember eq \(filterJoined)"
        let sortParam = filterJoined ? "joinDate" : "createdOn"
        parameters["sort"] = "\(sortParam) desc"
        
        authenticatedRequest(relativePath, parameters: parameters, completion: completion)
    }
}
