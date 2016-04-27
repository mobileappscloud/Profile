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
    
    enum TokenType {
        case Refresh
        case Legacy
    }
    
    class func request(token: String, tokenType: TokenType = .Refresh, user: User? = nil) -> NSURLRequest? {
        
        let relativePath = "/authentication/refresh"
        
        var parameters: [String : String] = [:]
        if tokenType == .Legacy, let user = user {
            parameters["user"] = user.identifier
        }
        
        guard let mutableRequest = authenticatedRequest(relativePath, parameters: parameters, method: HTTPMethod.POST)?.mutableCopy() as? NSMutableURLRequest else { return nil }
        
        let headerName = (tokenType == .Refresh) ? HigiAPIClient.HTTPHeaderName.refreshToken : HigiAPIClient.HTTPHeaderName.legacyToken
        mutableRequest.addValue(token, forHTTPHeaderField: headerName)
        
        return mutableRequest.copy() as? NSURLRequest
    }
}
