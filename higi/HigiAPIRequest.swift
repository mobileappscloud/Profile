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
    
        let mutableRequest = NSMutableURLRequest(URL: endpointURL)
        mutableRequest.HTTPMethod = method
        
        return mutableRequest.copy() as? NSURLRequest
    }
}
