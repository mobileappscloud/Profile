//
//  CommunityCollectionRequest.swift
//  higi
//
//  Created by Remy Panicker on 3/31/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

struct CommunityCollectionRequest {}

extension CommunityCollectionRequest: HigiAPIRequest {
    
    enum Filter {
        case Joined
        case Unjoined
    }
    
    static func request(filter: Filter, pageNumber: Int = 1, pageSize: Int = 10, completion: HigiAPIRequestAuthenticatorCompletion) {
        
        let relativePath = "/community/communities"
        
        var parameters: [String : String] = [:]
        
        let filterJoined = filter == .Joined
        
        parameters["filter"] = "isMember eq \(filterJoined)"
        
        let sortParam = filterJoined ? "joinDate" : "createdOn"
        parameters["sort"] = "\(sortParam) desc"
        
        parameters["pageNumber"] = String(pageNumber)
        parameters["pageSize"] = String(pageSize)
        
        authenticatedRequest(relativePath, parameters: parameters, completion: completion)
    }
}
