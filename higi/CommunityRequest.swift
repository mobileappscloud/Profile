//
//  CommunityRequest.swift
//  higi
//
//  Created by Remy Panicker on 6/9/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class CommunityRequest: ProtectedAPIRequest {

    let communityId: String
    
    required init(communityId: String) {
        self.communityId = communityId
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        
        let relativePath = "/community/communities/\(communityId)"
        
        authenticatedRequest(relativePath, parameters: nil, completion: completion)
    }
}
