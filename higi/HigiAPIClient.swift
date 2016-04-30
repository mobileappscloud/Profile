//
//  HigiAPIClient.swift
//  higi
//
//  Created by Remy Panicker on 3/26/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class HigiAPIClient: HigiAPI2 {
    
    /// Client ID registered as a whitelisted application with `OAuth2` access to the higi API.
    static let clientId = "com.higi.main.ios"
    
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
        // TODO: WARNING UNCOMMENT
        //        let URLString = NSBundle.mainBundle().objectForInfoDictionaryKey("HigiUrl") as! String
        let URLString = "https://api-dev.superbuddytime.com"
        return NSURL(string: URLString)!
    }()
    
    
}

// This extension can be refactored out if `NSURLCredential` is updated to better support access tokens.
extension HigiAPIClient {
    
    /**
     Authorization information required for accessing protected higi API resources.
     
     Please refer to `cacheAuthorization(:)` and `removeCachedAuthorization()` for public access to modifying the cached authorization object.
     */
    private(set) class var authorization: HigiAuthorization? {
        get {
            return KeychainWrapper.objectForKey(HigiAPIClient.authorizationKey) as? HigiAuthorization
        }
        
        set {
            if let newValue = newValue {
                KeychainWrapper.setObject(newValue, forKey: HigiAPIClient.authorizationKey)
            } else {
                if KeychainWrapper.objectForKey(HigiAPIClient.authorizationKey) != nil {
                    KeychainWrapper.removeObjectForKey(HigiAPIClient.authorizationKey)
                }
            }
        }
    }
    
    /**
     Securely caches a user's authentication info so that the API client can access protected resources.
     
     - parameter authorization: higi API authorization object.
     */
    class func cacheAuthorization(authorization: HigiAuthorization) {
        HigiAPIClient.authorization = authorization
    }
    
    /**
     Removes a user's authentication info from the cache.
     
     **Note:** This method should be called after revoking the user's refresh token. The API does not persist a user's access token, so their access token will remain valid until the expiration date has passed.
     */
    class func removeCachedAuthorization() {
        HigiAPIClient.authorization = nil
    }
}

extension HigiAPIClient {
    
    class func session() -> NSURLSession {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var headers: [String : String] = [:]
        headers[HTTPHeaderName.clientId] = HigiAPIClient.clientId
        configuration.HTTPAdditionalHeaders = headers
        let session = NSURLSession(configuration: configuration)
        return session
    }
}

extension HigiAPIClient {
    
    /**
     Convenience method which produces a `NSURL` object resolved against the higi API base URL. This method will handle any necessary encoding applicable to the relative path and query parameters.
     
     - parameter relativePath: Relative path to resource. _Ex: /activity/user_
     - parameter parameters:   Query parameters for URL.
     
     - returns: An instance of `NSURL` if there were no issues, otherwise `nil`.
     */
    class func URL(relativePath: String, parameters: [String : String]?) -> NSURL? {
        
        guard let percentEncodedPath = relativePath.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet()),
            let endpointURL = NSURL(string: percentEncodedPath, relativeToURL: HigiAPIClient.baseURL) else { return nil }
        
        if let parameters = parameters {
            return NSURL.URLByAppendingQueryParameters(endpointURL, queryParameters: parameters)
        } else {
            return endpointURL
        }
    }
}
