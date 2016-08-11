//
//  CommunityCollectionRequest.swift
//  higi
//
//  Created by Remy Panicker on 3/31/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class CommunityCollectionRequest: ProtectedAPIRequest {

    enum Filter {
        case Joined
        case Unjoined
    }
    
    let filter: Filter
    var pageNumber: Int
    var pageSize: Int
    
    required init(filter: Filter, pageNumber: Int = 1, pageSize: Int = 10) {
        self.filter = filter
        self.pageNumber = pageNumber
        self.pageSize = pageSize
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        
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
