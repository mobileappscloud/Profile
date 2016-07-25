//
//  APIClient.swift
//  higi
//
//  Created by Remy Panicker on 3/26/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

let APIClientTerminateAuthenticatedSessionNotification = "APIClientTerminateAuthenticatedSessionNotificationKey"

struct APIClient: HigiAPI2 {
    
    /// Client ID registered as a whitelisted application with `OAuth2` access to the higi API.
    static let clientId = "MobileiOS"
    
    /**
     *  Common HTTP header names for use with higi API.
     */
    struct HTTPHeaderName {
        static let clientId = "ClientId"
        static let authorization = "Authorization"
        static let refreshToken = "RefreshToken"
        static let legacyToken = "LegacyToken"
        static let organizationId = "OrganizationId"
    }
    
    /// Key used to store authorization info in `Keychain`.
    private static let authorizationKey = "HigiAuthorizationKey"
    
    /// Base URL for accessing the higi API.
    private static let baseURL: NSURL = {
        let URLString = NSBundle.mainBundle().objectForInfoDictionaryKey("HigiUrl") as! String
        return NSURL(string: URLString)!
    }()
}

// This extension can be refactored out if `NSURLCredential` is updated to better support access tokens.
extension APIClient {
    
    /**
     Authorization information required for accessing protected higi API resources.
     
     Please refer to `cacheAuthorization(:)` and `removeCachedAuthorization()` for public access to modifying the cached authorization object.
     */
    private(set) static var authorization: HigiAuthorization? {
        get {
            return KeychainWrapper.objectForKey(APIClient.authorizationKey) as? HigiAuthorization
        }
        
        set {
            if let newValue = newValue {
                KeychainWrapper.setObject(newValue, forKey: APIClient.authorizationKey)
            } else {
                if KeychainWrapper.objectForKey(APIClient.authorizationKey) != nil {
                    KeychainWrapper.removeObjectForKey(APIClient.authorizationKey)
                }
            }
        }
    }
    
    /**
     Securely caches a user's authentication info so that the API client can access protected resources.
     
     - parameter authorization: higi API authorization object.
     */
    static func cacheAuthorization(authorization: HigiAuthorization) {
        APIClient.authorization = authorization
    }
    
    /**
     Removes a user's authentication info from the cache.
     
     **Note:** This method should be called after revoking the user's refresh token. The API does not persist a user's access token, so their access token will remain valid until the expiration date has passed.
     */
    static func removeCachedAuthorization() {
        APIClient.authorization = nil
    }
    
    static func terminateAuthenticatedSession() {
        NSNotificationCenter.defaultCenter().postNotificationName(APIClientTerminateAuthenticatedSessionNotification, object: nil)
    }
}

extension APIClient {
    
    static let sharedSession: NSURLSession = {
        let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        configuration.timeoutIntervalForResource = 30
        configuration.HTTPShouldSetCookies = false
        configuration.HTTPCookieAcceptPolicy = .Never
        configuration.HTTPCookieStorage = nil
        
        APIClient.applyCommon(configuration)
        let session = NSURLSession(configuration: configuration)
        return session
    }()
    
    static func defaultSession() -> NSURLSession {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForResource = 30
        
        applyCommon(configuration)
        let session = NSURLSession(configuration: configuration)
        return session
    }
    
    private static func applyCommon(configuration: NSURLSessionConfiguration) {
        var headers: [String : String] = [:]
        headers[HTTPHeaderName.clientId] = APIClient.clientId
        headers[HTTPHeaderName.organizationId] = Utility.organizationId()
        // TODO: Remove this header override after API issue is resolved
        headers["Accept-Language"] = ""
        configuration.HTTPAdditionalHeaders = headers
    }
}

extension APIClient {
    
    /**
     Convenience method which produces a `NSURL` object resolved against the higi API base URL. This method will handle any necessary encoding applicable to the relative path and query parameters.
     
     - parameter relativePath: Relative path to resource. _Ex: /activity/user_
     - parameter parameters:   Query parameters for URL.
     
     - returns: An instance of `NSURL` if there were no issues, otherwise `nil`.
     */
    static func URL(relativePath: String, parameters: [String : String]?) -> NSURL? {
        
        guard let percentEncodedPath = relativePath.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet()),
            let endpointURL = NSURL(string: percentEncodedPath, relativeToURL: APIClient.baseURL) else { return nil }
        
        if let parameters = parameters {
            return NSURL.URLByAppendingQueryParameters(endpointURL, queryParameters: parameters)
        } else {
            return endpointURL
        }
    }
}
