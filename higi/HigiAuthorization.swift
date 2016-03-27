//
//  HigiAuthorization.swift
//  higi
//
//  Created by Remy Panicker on 3/23/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

/**
 This class contains `OAuth2` authorization info used to securely communicate with the higi API. For more information on OAuth2 visit [OAuth2](http://oauth.net/2/)
 
 The higi API makes use of JSON web tokens which are an open, industry standard `RFC 7519` method for representing claims securely between two parties.
 For more information on JSON web tokens visit [JWT](http://jwt.io)
 */
final class HigiAuthorization: NSObject {
    
    enum Type: String {
        case Bearer = "bearer"
    }
    
    let accessToken: String
    let type: Type
    let expirationDate: NSDate
    let refreshToken: String
    
    required init(accessToken: String, type: Type, expirationDate: NSDate, refreshToken: String) {
        self.accessToken = accessToken
        self.type = type
        self.expirationDate = expirationDate
        self.refreshToken = refreshToken
    }
}

extension HigiAuthorization: NSCoding {
    
    private struct NSCodingKey {
        static let accessToken = "AccessToken"
        static let type = "TokenType"
        static let expirationDate = "ExpirationDate"
        static let refreshToken = "RefreshToken"
    }
    
    convenience init?(coder aDecoder: NSCoder) {
        guard let accessToken = aDecoder.decodeObjectForKey(NSCodingKey.accessToken) as? String,
            let typeString = aDecoder.decodeObjectForKey(NSCodingKey.type) as? String,
            let type = Type(rawValue: typeString),
            let expirationDate = aDecoder.decodeObjectForKey (NSCodingKey.expirationDate) as? NSDate,
            let refreshToken = aDecoder.decodeObjectForKey(NSCodingKey.refreshToken) as? String else { return nil }
        
        self.init(accessToken: accessToken, type: type, expirationDate: expirationDate, refreshToken: refreshToken)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.accessToken, forKey: NSCodingKey.accessToken)
        aCoder.encodeObject(self.type.rawValue, forKey: NSCodingKey.type)
        aCoder.encodeObject(self.expirationDate, forKey: NSCodingKey.expirationDate)
        aCoder.encodeObject(self.refreshToken, forKey: NSCodingKey.refreshToken)
    }
}

extension HigiAuthorization {
    
    struct DictionaryKeys {
        static let AccessToken: NSString = "AccessToken"
        static let TokenType: NSString = "TokenType"
        static let RefreshToken: NSString = "RefreshToken"
    }
    
    convenience init?(dictionary: NSDictionary) {
        guard let accessToken = dictionary[DictionaryKeys.AccessToken] as? String,
            let expirationDate = JSONWebToken.expirationDate(accessToken),
            let typeString = dictionary[DictionaryKeys.TokenType] as? String,
            let type = Type(rawValue: typeString),
            let refreshToken = dictionary[DictionaryKeys.RefreshToken] as? String else { return nil }
        
        self.init(accessToken: accessToken, type: type, expirationDate: expirationDate, refreshToken: refreshToken)
    }
}

extension HigiAuthorization {
    
    /**
     Bearer token sent as an HTTP header for requests to protected resources in the higi API.
     
     - returns: HTTP header for `OAuth2` bearer access token.
     */
    func bearerToken() -> String {
        if type == .Bearer {
            return "Bearer \(accessToken)"
        }
        return ""
    }
}
