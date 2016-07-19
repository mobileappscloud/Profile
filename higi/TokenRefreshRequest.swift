//
//  TokenRefreshRequest.swift
//  higi
//
//  Created by Remy Panicker on 3/28/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

struct TokenRefreshRequest {}

extension TokenRefreshRequest: HigiAPIRequest {
    
    enum TokenType {
        case Refresh
        case Legacy
    }
    
    static func request(token: String, tokenType: TokenType = .Refresh, userId: String? = nil) -> NSURLRequest? {
        
        let relativePath = "/authentication/refresh"
        let method = HTTPMethod.POST
        
        var parameters: [String : String] = [:]
        if tokenType == .Legacy, let userId = userId where userId.characters.count > 0 {
            parameters["user"] = userId
        } else if tokenType == .Refresh {
            parameters["includeUser"] = String(true)
        }
        
        guard let mutableRequest = request(relativePath, parameters: parameters, method: method, body: nil)?.mutableCopy() as? NSMutableURLRequest else { return nil }
        
        mutableRequest.addValue(HTTPHeader.value.applicationJSON, forHTTPHeaderField: HTTPHeader.name.contentType)
        
        let headerName = (tokenType == .Refresh) ? HigiAPIClient.HTTPHeaderName.refreshToken : HigiAPIClient.HTTPHeaderName.legacyToken
        mutableRequest.addValue(token, forHTTPHeaderField: headerName)
        
        return mutableRequest.copy() as? NSURLRequest
    }
}
