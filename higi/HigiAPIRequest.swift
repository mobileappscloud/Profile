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

protocol HigiAPIRequest: HigiAPI2 {}

// MARK: - Authenticated Requests

extension HigiAPIRequest {
    
    static func authenticatedRequest(relativePath: String, parameters: [String : String]?, method: String = HTTPMethod.GET, completion: (request: NSURLRequest?, error: NSError?) -> ()) {
        
        guard let endpointURL = HigiAPIClient.URL(relativePath, parameters: parameters) else {
            let error = NSError(sender: String(self), code: HigiAPIRequestErrorCode.URLConstructor.rawValue, message: "Error creating request.")
            completion(request: nil, error: error)
            return
        }
        
        authenticatedRequest(endpointURL, parameters: parameters, method: method, completion: completion)
    }
    
    static func authenticatedRequest(URL: NSURL, parameters: [String : String]?, method: String = HTTPMethod.GET, completion: (request: NSURLRequest?, error: NSError?) -> ()) {
        
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
        
        let secondsPerMinute = 60.0
        let minutes = 2.0
        let refreshThreshold = minutes * secondsPerMinute
        
        if expirationDate.timeIntervalSinceNow < refreshThreshold {
            guard let refreshRequest = RefreshToken.request(authorization.refreshToken) else {
                // TODO: Terminate authenticated session and kick user back to host controller
                
                let error = NSError(sender: String(self), code: HigiAPIRequestErrorCode.RefreshTokenRequestError.rawValue, message: "Unable to refresh access token.")
                completion(request: nil, error: error)
                return
            }
            
            let session = HigiAPIClient.session()
            
            let task = NSURLSessionTask.JSONTask(session, request: refreshRequest, success: { (JSON, response) in
                
                AuthenticationDeserializer.parse(JSON, success: { (user) in
                    let request = authenticatedRequest(URL, parameters: parameters, method: method)
                    completion(request: request, error: nil)
                    }, failure: { (error) in
                        completion(request: nil, error: error)
                })
                
                }, failure: { (error, response) in
                    if let response = response where response.statusCodeEnum.isClientError {
                        // TODO: Terminate authenticated session and kick user back to host controller
                    }
                    
                    completion(request: nil, error: error)
            })
            task.resume()
            
        } else {
            let request = authenticatedRequest(URL, parameters: parameters, method: method)
            completion(request: request, error: nil)
        }
    }
}

// MARK: - Request Constructors

extension HigiAPIRequest {
    
    static func request(relativePath: String, parameters: [String : String]?, method: String = HTTPMethod.GET) -> NSURLRequest? {
        
        guard let endpointURL = HigiAPIClient.URL(relativePath, parameters: parameters) else { return nil }
        return request(endpointURL, parameters: parameters, method: method)
    }
    
    static func request(URL: NSURL, parameters: [String : String]?, method: String = HTTPMethod.GET) -> NSURLRequest? {
        let mutableRequest = NSMutableURLRequest(URL: URL)
        mutableRequest.HTTPMethod = method
        
        mutableRequest.setValue(Utility.organizationId(), forHTTPHeaderField: HigiAPIClient.HTTPHeaderName.organizationId)
        
        return mutableRequest.copy() as? NSURLRequest
    }
    
    private static func authenticatedRequest(URL: NSURL, parameters: [String : String]?, method: String = HTTPMethod.GET) -> NSURLRequest? {
        
        guard let mutableRequest = request(URL, parameters: parameters, method: method)?.mutableCopy() as? NSMutableURLRequest else {
            return nil
        }
        
        // The `NSURLSession` documentation advises against modifying the `Authorization` header per session, so we will attach the header to individual requests.
        if let authorization = HigiAPIClient.authorization {
            mutableRequest.setValue(authorization.bearerToken(), forHTTPHeaderField: HigiAPIClient.HTTPHeaderName.authorization)
        }
        
        return mutableRequest.copy() as? NSURLRequest
    }
}
