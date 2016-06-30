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
    
    static func request(filter: Filter, completion: HigiAPIRequestAuthenticatorCompletion) {
        
        let relativePath = "/community/communities"
        
        var parameters: [String : String] = [:]
        
        let filterJoined = filter == .Joined
        
        var filterParams: [String] = []
        filterParams.append("isMember eq \(filterJoined)")
        if !filterJoined {
            filterParams.append("isVisibleToVisitors eq true")
        }
        let filterParam = filterParams.joinWithSeparator(",")
        parameters["filter"] = filterParam
        
        let sortParam = filterJoined ? "joinDate" : "createdOn"
        parameters["sort"] = "\(sortParam) desc"
        
        authenticatedRequest(relativePath, parameters: parameters, completion: completion)
    }
}
