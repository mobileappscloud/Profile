//
//  PagingRequest.swift
//  higi
//
//  Created by Remy Panicker on 4/11/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class PagingRequest: ProtectedAPIRequest {
    
    let URL: NSURL

    required init(URL: NSURL) {
        self.URL = URL
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        authenticatedRequest(URL, parameters: nil, completion: completion)
    }
}
