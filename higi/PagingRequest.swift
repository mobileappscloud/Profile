//
//  PagingRequest.swift
//  higi
//
//  Created by Remy Panicker on 4/11/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

struct PagingRequest {}

extension PagingRequest: APIRequest {
    
    static func request(URL: NSURL, completion: APIRequestAuthenticatorCompletion) {
        authenticatedRequest(URL, parameters: nil, completion: completion)
    }
}
