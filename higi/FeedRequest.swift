//
//  FeedRequest.swift
//  higi
//
//  Created by Remy Panicker on 7/18/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct FeedRequest {}

extension FeedRequest: APIRequest {
    
    static func request(postId: String, completion: APIRequestAuthenticatorCompletion) {
        
        let relativePath = "/feed/posts/\(postId)"
        
        authenticatedRequest(relativePath, parameters: nil, completion: completion)
    }
}
