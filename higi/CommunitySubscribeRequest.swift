//
//  CommunitySubscribeRequest.swift
//  higi
//
//  Created by Remy Panicker on 3/29/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class CommunitySubscribeRequest: ProtectedAPIRequest {

    enum SubscribeAction {
        case Join
        case Leave
    }
    
    let subscribeAction: SubscribeAction
    let communityId: String
    let userId: String
    
    required init(subscribeAction: SubscribeAction, communityId: String, userId: String) {
        self.subscribeAction = subscribeAction
        self.communityId = communityId
        self.userId = userId
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        
        let relativePath = "/community/communities/\(communityId)/users/\(userId)"
        
        let method = (subscribeAction == .Join) ? HTTPMethod.PUT : HTTPMethod.DELETE
        let parameters: [String : String] = [:]
        
        authenticatedRequest(relativePath, parameters: parameters, method: method, completion: completion)
    }
}
