//
//  CommunitySubscribeRequest.swift
//  higi
//
//  Created by Remy Panicker on 3/29/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

struct CommunitySubscribeRequest {}

extension CommunitySubscribeRequest: APIRequest {
    
    enum Filter {
        case Join
        case Leave
    }
    
    static func request(filter: Filter, community: Community, user: User, completion: APIRequestAuthenticatorCompletion) {
        
        let relativePath = "/community/communities/\(community.identifier)/users/\(user.identifier)"
        
        let method = (filter == .Join) ? HTTPMethod.PUT : HTTPMethod.DELETE
        let parameters: [String : String] = [:]
        
        authenticatedRequest(relativePath, parameters: parameters, method: method, completion: completion)
    }
}
