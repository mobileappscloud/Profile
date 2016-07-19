//
//  HigiAPIRequest.swift
//  higi
//
//  Created by Remy Panicker on 3/29/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

enum HigiAPIRequestErrorCode: Int {
    case URLConstructor
    case AuthorizationNotFound
    case TokenPayloadReadError
    case RefreshTokenRequestError
}

private let defaultRefreshThreshold = 120.0 // 2 minutes

typealias HigiAPIRequestAuthenticatorCompletion = (request: NSURLRequest?, error: NSError?) -> Void

protocol HigiAPIRequest: HigiAPI2 {}

// MARK: - Authenticated Requests

extension HigiAPIRequest {
    
    static func authenticatedRequest(relativePath: String, parameters: [String : String]?, method: String = HTTPMethod.GET, body: AnyObject? = nil, refreshThreshold: Double = defaultRefreshThreshold, completion: HigiAPIRequestAuthenticatorCompletion) {
        
        guard let endpointURL = HigiAPIClient.URL(relativePath, parameters: parameters) else {
            let error = NSError(sender: String(self), code: HigiAPIRequestErrorCode.URLConstructor.rawValue, message: "Error creating request.")
            completion(request: nil, error: error)
            return
        }
        
        authenticatedRequest(endpointURL, parameters: parameters, method: method, body: body, refreshThreshold: refreshThreshold, completion: completion)
    }
    
    static func authenticatedRequest(URL: NSURL, parameters: [String : String]?, method: String = HTTPMethod.GET, body: AnyObject? = nil, refreshThreshold: Double = defaultRefreshThreshold, completion: HigiAPIRequestAuthenticatorCompletion) {
        
        guard let authorization = HigiAPIClient.authorization else {
            let error = NSError(sender: String(self), code: HigiAPIRequestErrorCode.AuthorizationNotFound.rawValue, message: "Authorization info not found.")
            completion(request: nil, error: error)
            return
        }
        
        guard let expirationDate = authorization.accessToken.expirationDate() else {
            let error = NSError(sender: String(self), code: HigiAPIRequestErrorCode.TokenPayloadReadError.rawValue, message: "Unable to read authorization info.")
            completion(request: nil, error: error)
            return
        }
        
        let enforcedThreshold = (refreshThreshold == defaultRefreshThreshold) ? defaultRefreshThreshold : refreshThreshold
        if expirationDate.timeIntervalSinceNow < enforcedThreshold {
            guard let refreshRequest = TokenRefreshRequest.request(authorization.refreshToken) else {
                
                HigiAPIClient.terminateAuthenticatedSession()
                
                let error = NSError(sender: String(self), code: HigiAPIRequestErrorCode.RefreshTokenRequestError.rawValue, message: "Unable to refresh access token.")
                completion(request: nil, error: error)
                
                return
            }
            
            let session = HigiAPIClient.session()
            
            let task = NSURLSessionTask.JSONTask(session, request: refreshRequest, success: { (JSON, response) in
                
                AuthorizationDeserializer.parse(JSON, success: { (user) in
                    let request = authenticatedRequest(URL, parameters: parameters, method: method, body: body)
                    completion(request: request, error: nil)
                }, failure: { (error) in
                    completion(request: nil, error: error)
                })
                
            }, failure: { (error, response) in
                if let response = response where response.statusCodeEnum.isClientError {
                    HigiAPIClient.terminateAuthenticatedSession()
                }
                    
                completion(request: nil, error: error)
            })
            task.resume()
            
        } else {
            let request = authenticatedRequest(URL, parameters: parameters, method: method, body: body)
            completion(request: request, error: nil)
        }
    }
}

// MARK: - Request Constructors

extension HigiAPIRequest {
    
    // MARK: Convenience
    
    static func request(relativePath: String, parameters: [String : String]?, method: String = HTTPMethod.GET, body: AnyObject?) -> NSURLRequest? {
        
        guard let endpointURL = HigiAPIClient.URL(relativePath, parameters: parameters) else { return nil }
        return request(endpointURL, parameters: parameters, method: method, body: body)
    }
    
    private static func authenticatedRequest(URL: NSURL, parameters: [String : String]?, method: String = HTTPMethod.GET, body: AnyObject?) -> NSURLRequest? {
        
        guard let mutableRequest = request(URL, parameters: parameters, method: method, body: body)?.mutableCopy() as? NSMutableURLRequest else {
            return nil
        }
        
        // The `NSURLSession` documentation advises against modifying the `Authorization` header per session, so we will attach the header to individual requests.
        if let authorization = HigiAPIClient.authorization {
            mutableRequest.setValue(authorization.bearerToken(), forHTTPHeaderField: HigiAPIClient.HTTPHeaderName.authorization)
        }
        
        return mutableRequest.copy() as? NSURLRequest
    }
    
    // MARK: Required
    
    static func request(URL: NSURL, parameters: [String : String]?, method: String = HTTPMethod.GET, body: AnyObject?) -> NSURLRequest? {
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
