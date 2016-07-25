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

private let defaultRefreshThreshold = 120.0 // 2 minutes

typealias APIRequestAuthenticatorCompletion = (request: NSURLRequest?, error: NSError?) -> Void

protocol APIRequest: HigiAPI2 {}

// MARK: - Authenticated Requests

extension APIRequest {
    
    static func authenticatedRequest(relativePath: String, parameters: [String : String]?, method: String = HTTPMethod.GET, body: AnyObject? = nil, refreshThreshold: Double = defaultRefreshThreshold, completion: APIRequestAuthenticatorCompletion) {
        
        guard let endpointURL = APIClient.URL(relativePath, parameters: parameters) else {
            let error = NSError(sender: String(self), code: APIRequestError.URLConstructor.code(), message: "Error creating request.")
            completion(request: nil, error: error)
            return
        }
        
        authenticatedRequest(endpointURL, parameters: parameters, method: method, body: body, refreshThreshold: refreshThreshold, completion: completion)
    }
    
    static func authenticatedRequest(URL: NSURL, parameters: [String : String]?, method: String = HTTPMethod.GET, body: AnyObject? = nil, refreshThreshold: Double = defaultRefreshThreshold, completion: APIRequestAuthenticatorCompletion) {
        
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
            guard let refreshRequest = TokenRefreshRequest.request(authorization.refreshToken) else {
                
                APIClient.terminateAuthenticatedSession()
                
                let error = NSError(sender: String(self), code: APIRequestError.RefreshTokenRequestError.code(), message: "Unable to refresh access token.")
                completion(request: nil, error: error)
                
                return
            }
            
            let session = APIClient.session()
            
            let task = NSURLSessionTask.JSONTask(session, request: refreshRequest, success: { (JSON, response) in
                
                AuthorizationDeserializer.parse(JSON, success: { (user) in
                    let request = authenticatedRequest(URL, parameters: parameters, method: method, body: body)
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
}

// MARK: - Request Constructors

extension APIRequest {
    
    // MARK: Convenience
    
    static func request(relativePath: String, parameters: [String : String]?, method: String = HTTPMethod.GET, body: AnyObject?) -> NSURLRequest? {
        
        guard let endpointURL = APIClient.URL(relativePath, parameters: parameters) else { return nil }
        return request(endpointURL, parameters: parameters, method: method, body: body)
    }
    
    private static func authenticatedRequest(URL: NSURL, parameters: [String : String]?, method: String = HTTPMethod.GET, body: AnyObject?) -> NSURLRequest? {
        
        guard let mutableRequest = request(URL, parameters: parameters, method: method, body: body)?.mutableCopy() as? NSMutableURLRequest else {
            return nil
        }
        
        // The `NSURLSession` documentation advises against modifying the `Authorization` header per session, so we will attach the header to individual requests.
        if let authorization = APIClient.authorization {
            mutableRequest.setValue(authorization.bearerToken(), forHTTPHeaderField: APIClient.HTTPHeaderName.authorization)
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
