//
//  PagingRequest.swift
//  higi
//
//  Created by Remy Panicker on 4/11/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class PagingRequest {}

extension PagingRequest: HigiAPIRequest {
    
    class func request(URL: NSURL) -> NSURLRequest? {
        return authenticatedRequest(URL, parameters: nil)
    }
}
