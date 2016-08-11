//
//  TokenRefreshRequest.swift
//  higi
//
//  Created by Remy Panicker on 3/28/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class TokenRefreshRequest: UnprotectedAPIRequest {
    
    enum TokenType {
        case Refresh
        case Legacy
    }

    let token: String
    let tokenType: TokenType
    var userId: String?
    
    required init(token: String, tokenType: TokenType, userId: String? = nil) {
        self.token = token
        self.tokenType = tokenType
        self.userId = userId
    }
    
    func request() -> NSURLRequest? {
        
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
        
        let headerName = (tokenType == .Refresh) ? APIClient.HTTPHeaderName.refreshToken : APIClient.HTTPHeaderName.legacyToken
        mutableRequest.addValue(token, forHTTPHeaderField: headerName)
        
        return mutableRequest.copy() as? NSURLRequest
    }
}
