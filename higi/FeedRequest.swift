//
//  FeedRequest.swift
//  higi
//
//  Created by Remy Panicker on 7/18/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class FeedRequest: ProtectedAPIRequest {

    let postId: String
    
    required init(postId: String) {
        self.postId = postId
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        
        let relativePath = "/feed/posts/\(postId)"
        
        authenticatedRequest(relativePath, parameters: nil, completion: completion)
    }
}
