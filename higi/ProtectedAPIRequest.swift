//
//  ProtectedAPIRequest.swift
//  higi
//
//  Created by Remy Panicker on 8/8/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

protocol ProtectedAPIRequest: APIRequest {
    
    func request(completion: APIRequestAuthenticatorCompletion)
}

private let defaultRefreshThreshold = 120.0 // 2 minutes

extension ProtectedAPIRequest {
    
    // MARK: Convenience
    
    func authenticatedRequest(relativePath: String, parameters: [String : String]?, method: String = HTTPMethod.GET, body: AnyObject? = nil, refreshThreshold: Double = defaultRefreshThreshold, completion: APIRequestAuthenticatorCompletion) {
        
        guard let endpointURL = APIClient.URL(relativePath, parameters: parameters) else {
            let error = NSError(sender: String(self), code: APIRequestError.URLConstructor.code(), message: "Error creating request.")
            completion(request: nil, error: error)
            return
        }
        
        authenticatedRequest(endpointURL, parameters: parameters, method: method, body: body, refreshThreshold: refreshThreshold, completion: completion)
    }
    
    func authenticatedRequest(URL: NSURL, parameters: [String : String]?, method: String = HTTPMethod.GET, body: AnyObject? = nil, refreshThreshold: Double = defaultRefreshThreshold, completion: APIRequestAuthenticatorCompletion) {
        
        guard let authorization = APIClient.authorization else {
            let error = NSError(sender: String(self), code: APIRequestError.AuthorizationNotFound.code(), message: "Authorization info not found.")
            completion(request: nil, error: error)
            return
        }
        
        guard let expirationDate = authorization.accessToken.expirationDate() else {
            let error = NSError(sender: String(self), code: APIRequestError.TokenPayloadReadError.code(), message: "Unable to read authorization info.")
            completion(request: nil, error: error)
            return
        }
        
        let enforcedThreshold = (refreshThreshold == defaultRefreshThreshold) ? defaultRefreshThreshold : refreshThreshold
        if expirationDate.timeIntervalSinceNow < enforcedThreshold {
            guard let refreshRequest = TokenRefreshRequest(token: authorization.refreshToken, tokenType: .Refresh, userId: nil).request() else {
                
                APIClient.terminateAuthenticatedSession()
                
                let error = NSError(sender: String(self), code: APIRequestError.RefreshTokenRequestError.code(), message: "Unable to refresh access token.")
                completion(request: nil, error: error)
                
                return
            }
            
            let session = APIClient.sharedSession
            
            let task = NSURLSessionTask.JSONTask(session, request: refreshRequest, success: { (JSON, response) in
                
                AuthorizationDeserializer.parse(JSON, success: { [weak self] (user) in
                    guard let strongSelf = self else { return }
                    let request = strongSelf.authenticatedRequest(URL, parameters: parameters, method: method, body: body)
                    completion(request: request, error: nil)
                    }, failure: { (error) in
                        completion(request: nil, error: error)
                })
                
                }, failure: { (error, response) in
                    if let response = response where response.statusCodeEnum.isClientError {
                        APIClient.terminateAuthenticatedSession()
                    }
                    
                    completion(request: nil, error: error)
            })
            task.resume()
            
        } else {
            let request = authenticatedRequest(URL, parameters: parameters, method: method, body: body)
            completion(request: request, error: nil)
        }
    }
    
    // MARK: Required
    
    private func authenticatedRequest(URL: NSURL, parameters: [String : String]?, method: String = HTTPMethod.GET, body: AnyObject?) -> NSURLRequest? {
        
        guard let mutableRequest = request(URL, parameters: parameters, method: method, body: body)?.mutableCopy() as? NSMutableURLRequest else {
            return nil
        }
        
        // The `NSURLSession` documentation advises against modifying the `Authorization` header per session, so we will attach the header to individual requests.
        if let authorization = APIClient.authorization {
            mutableRequest.setValue(authorization.bearerToken(), forHTTPHeaderField: APIClient.HTTPHeaderName.authorization)
        }
        
        return mutableRequest.copy() as? NSURLRequest
    }
}
