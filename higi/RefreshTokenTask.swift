//
//  RefreshTokenTask.swift
//  higi
//
//  Created by Remy Panicker on 3/28/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class RefreshTokenTask {}

extension RefreshTokenTask: HigiAPIRequest {
    
    class func request(email: String, password: String) -> NSURLRequest? {
        
        let relativePath = "/authentication/refresh"
        
        guard let authorization = HigiAPIClient.authorization,
            let mutableRequest = authenticatedRequest(relativePath, parameters: nil, method: HTTPMethod.POST)?.mutableCopy() as? NSMutableURLRequest else { return nil }
        
        mutableRequest.addValue(authorization.refreshToken, forHTTPHeaderField: HigiAPIClient.HTTPHeaderName.refreshToken)
        
        return mutableRequest.copy() as? NSURLRequest
    }
}
