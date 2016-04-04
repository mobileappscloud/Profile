//
//  CommunitiesRequest.swift
//  higi
//
//  Created by Remy Panicker on 3/31/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class CommunityCollectionRequest {}

extension CommunityCollectionRequest: HigiAPIRequest {
    
    enum Filter {
        case Joined
        case Unjoined
    }
    
    class func request(filter: Filter) -> NSURLRequest? {
        
        let organizationId = Utility.organizationId()
//        let relativePath = "/organizations/\(organizationId)/communities"
        let relativePath = "/community/organizations/\(organizationId)/communities"
        
        var parameters: [String : String] = [:]
        
        let filterJoined = filter == .Joined
        parameters["filter"] = "isMember eq \(filterJoined)"
        let sortParam = filterJoined ? "joinDate" : "createdOn"
        parameters["sort"] = "\(sortParam) desc"
        
        return authenticatedRequest(relativePath, parameters: parameters)
    }
}
