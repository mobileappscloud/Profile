//
//  HigiAuthorization.swift
//  higi
//
//  Created by Remy Panicker on 3/23/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

/**
 This class contains [`OAuth2`](http://oauth.net/2/) authorization info used to securely communicate with the higi API.
 */
final class HigiAuthorization: NSObject, HigiAPI2 {
    
    enum Type: APIString {
        case Bearer = "bearer"
    }
    
    /// JSON web token with access information
    let accessToken: JSONWebToken
    
    /// Type of `OAuth2` token.
    let type: Type
    
    /// `OAuth2` refresh token which can be used to generate a new accessToken.
    let refreshToken: String
    
    // MARK: Init
    
    required init(accessToken: JSONWebToken, type: Type, refreshToken: String) {
        self.accessToken = accessToken
        self.type = type
        self.refreshToken = refreshToken
    }
}

// MARK: - NSCoding

extension HigiAuthorization: NSCoding {
    
    private struct NSCodingKey {
        static let accessToken = "accessToken"
        static let type = "tokenType"
        static let refreshToken = "refreshToken"
    }
    
    convenience init?(coder aDecoder: NSCoder) {
        guard let accessToken = JSONWebToken(coder: aDecoder),
            let typeString = aDecoder.decodeObjectForKey(NSCodingKey.type) as? String,
            let type = Type(rawValue: typeString),
            let refreshToken = aDecoder.decodeObjectForKey(NSCodingKey.refreshToken) as? String else { return nil }
        
        self.init(accessToken: accessToken, type: type, refreshToken: refreshToken)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        self.accessToken.encodeWithCoder(aCoder)
        aCoder.encodeObject(self.type.rawValue, forKey: NSCodingKey.type)
        aCoder.encodeObject(self.refreshToken, forKey: NSCodingKey.refreshToken)
    }
}

// MARK: - JSON

extension HigiAuthorization: JSONInitializable {
    
    struct DictionaryKeys {
        static let AccessToken: NSString = "accessToken"
        static let TokenType: NSString = "tokenType"
        static let RefreshToken: NSString = "refreshToken"
    }
    
    convenience init?(dictionary: NSDictionary) {
        guard let accessToken = dictionary[DictionaryKeys.AccessToken] as? String,
            let type = Type(rawJSONValue: dictionary[DictionaryKeys.TokenType]),
            let refreshToken = dictionary[DictionaryKeys.RefreshToken] as? String else { return nil }
        
        let token = JSONWebToken(token: accessToken)
        self.init(accessToken: token, type: type, refreshToken: refreshToken)
    }
}

// MARK: - Convenience

extension HigiAuthorization {
    
    /**
     Bearer token sent as an HTTP header for requests to protected resources in the higi API.
     
     - returns: HTTP header for `OAuth2` bearer access token.
     */
    func bearerToken() -> String {
        if type == .Bearer {
            return "Bearer \(accessToken.token)"
        }
        return ""
    }
}
