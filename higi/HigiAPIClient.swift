//
//  HigiAPIClient.swift
//  higi
//
//  Created by Remy Panicker on 3/26/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class HigiAPIClient {
    
    // MARK: Definitions
    
    static let clientId = "com.higi.main.ios"
    
    private static let authorizationKey = "HigiAuthorizationKey"
    private static let baseURL: NSURL = {
        //        let URLString = NSBundle.mainBundle().objectForInfoDictionaryKey("HigiUrl") as! String
        let URLString = "https://api-dev.superbuddytime.com"
        return NSURL(string: URLString)!
    }()
    
    struct HTTPHeaderName {
        static let clientId = "ClientId"
        static let authorization = "Authorization"
        static let refreshToken = "RefreshToken"
    }
}

extension HigiAPIClient {
    
    private(set) static var authorization: HigiAuthorization? {
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
    
    class func cacheAuthorization(authorization: HigiAuthorization) {
        HigiAPIClient.authorization = authorization
    }
    
    class func removeCachedAuthorization() {
        HigiAPIClient.authorization = nil
    }
}

extension HigiAPIClient {
    
    class func unauthenticatedSession() -> NSURLSession {
        return NSURLSession.sharedSession()
    }
    
    class func authenticatedSession() -> NSURLSession {
        let authenticatedSessionConfig = NSURLSessionConfiguration()
        var headers: [String : String] = [:]
        if let authorization = authorization {
            headers[HTTPHeaderName.authorization] = authorization.accessToken
        }
        headers[HTTPHeaderName.clientId] = HigiAPIClient.clientId
        authenticatedSessionConfig.HTTPAdditionalHeaders = headers
        let session = NSURLSession(configuration: authenticatedSessionConfig)
        return session
    }
    
    class func backgroundSession() -> NSURLSession {
        let backgroundConfig = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.higi.main.NSURLSession.background")
        let session = NSURLSession(configuration: backgroundConfig)
        return session
    }
}

extension HigiAPIClient {

    class func endpointURL(relativePath: String) -> NSURL {
        return HigiAPIClient.baseURL.URLByAppendingPathComponent(relativePath)
    }
}

protocol HigiAPITask {}

protocol HigiAPIResponseParser {}
