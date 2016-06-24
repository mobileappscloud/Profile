//
//  CommunityRequest.swift
//  higi
//
//  Created by Remy Panicker on 6/9/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct CommunityRequest {}

extension CommunityRequest: HigiAPIRequest {
    
    static func request(community: Community, completion: HigiAPIRequestAuthenticatorCompletion) {
        
        let relativePath = "/community/communities/\(community.identifier)"
        
        authenticatedRequest(relativePath, parameters: nil, completion: completion)
    }
}
