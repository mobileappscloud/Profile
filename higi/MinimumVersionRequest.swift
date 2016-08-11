//
//  MinimumVersionRequest.swift
//  higi
//
//  Created by Remy Panicker on 5/4/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class MinimumVersionRequest: UnprotectedAPIRequest {

    func request() -> NSURLRequest? {
        
        // TODO: Update after endpoint is migrated to new core API
        let relativePath = "app/mobile/minVersion?p=ios"
        
        return request(relativePath, parameters: nil, body: nil)
    }
}
