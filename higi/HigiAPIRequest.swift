//
//  HigiAPIRequest.swift
//  higi
//
//  Created by Remy Panicker on 3/29/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

protocol HigiAPIRequest: HigiAPI2 {}

extension HigiAPIRequest {

    static func authenticatedRequest(relativePath: String, parameters: [String : String]?, method: String = HTTPMethod.GET) -> NSURLRequest? {
        
        guard let endpointURL = HigiAPIClient.URL(relativePath, parameters: parameters) else { return nil }
    
        return authenticatedRequest(endpointURL, parameters: parameters, method: method)
    }
    
    static func authenticatedRequest(URL: NSURL, parameters: [String : String]?, method: String = HTTPMethod.GET) -> NSURLRequest? {
        
        let mutableRequest = NSMutableURLRequest(URL: URL)
        mutableRequest.HTTPMethod = method
        
        // The `NSURLSession` documentation advises against modifying the `Authorization` header per session, so we will attach the header to individual requests.
        if let authorization = HigiAPIClient.authorization {
            mutableRequest.setValue(authorization.bearerToken(), forHTTPHeaderField: HigiAPIClient.HTTPHeaderName.authorization)
        }
        mutableRequest.setValue(Utility.organizationId(), forHTTPHeaderField: HigiAPIClient.HTTPHeaderName.organizationId)
        
        return mutableRequest.copy() as? NSURLRequest
    }
}
