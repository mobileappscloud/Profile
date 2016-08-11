//
//  APIRequest.swift
//  higi
//
//  Created by Remy Panicker on 3/29/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

enum APIRequestError: ErrorType {
    case URLConstructor
    case AuthorizationNotFound
    case TokenPayloadReadError
    case RefreshTokenRequestError
    
    func code() -> Int {
        let code: Int
        switch self {
        case .URLConstructor:
            code = 4000
        case .AuthorizationNotFound:
            code = 4001
        case .TokenPayloadReadError:
            code = 4002
        case .RefreshTokenRequestError:
            code = 4003
        }
        return code
    }
}

typealias APIRequestAuthenticatorCompletion = (request: NSURLRequest?, error: NSError?) -> Void

// MARK: - Protocols

protocol APIRequest: class, HigiAPI2 {}

extension APIRequest {
    
    // MARK: Convenience
    
    func request(relativePath: String, parameters: [String : String]?, method: String = HTTPMethod.GET, body: AnyObject?) -> NSURLRequest? {
        
        guard let endpointURL = APIClient.URL(relativePath, parameters: parameters) else { return nil }
        return request(endpointURL, parameters: parameters, method: method, body: body)
    }
    
    // MARK: Required
    
    func request(URL: NSURL, parameters: [String : String]?, method: String = HTTPMethod.GET, body: AnyObject?) -> NSURLRequest? {
        let mutableRequest = NSMutableURLRequest(URL: URL)
        mutableRequest.HTTPMethod = method
        
        if let body = body {
            let JSONBodyData = try? NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions())
            mutableRequest.HTTPBody = JSONBodyData
            mutableRequest.addValue(HTTPHeader.value.applicationJSON, forHTTPHeaderField: HTTPHeader.name.contentType)
        }
        
        return mutableRequest.copy() as? NSURLRequest
    }
}
