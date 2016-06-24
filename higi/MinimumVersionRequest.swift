//
//  MinimumVersionRequest.swift
//  higi
//
//  Created by Remy Panicker on 5/4/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct MinimumVersionRequest {}

extension MinimumVersionRequest: HigiAPIRequest {
    
    static func request() -> NSURLRequest? {
        
        let relativePath = "app/mobile/minVersion?p=ios"
        
        let aRequest = request(relativePath, parameters: nil)
        return aRequest
    }
}
