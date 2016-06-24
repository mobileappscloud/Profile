//
//  JSONWebToken.swift
//  higi
//
//  Created by Remy Panicker on 3/24/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

/**
 [JSON web tokens](http://jwt.io) are an open, industry standard [`RFC 7519`](https://tools.ietf.org/html/rfc7519) method for representing claims securely between two parties.
 
 **Warning:** This class is a partial implementation for a JSON web token and simply provides helper methods to read select claims from the token's payload.
 */
final class JSONWebToken: NSObject {
    
    let token: String
    
    required init(token: String) {
        self.token = token
    }
}

extension JSONWebToken: NSCoding {
    
    private struct NSCodingKey {
        static let token = "TokenCodingKey"
    }
    
    convenience init?(coder aDecoder: NSCoder) {
        guard let token = aDecoder.decodeObjectForKey(NSCodingKey.token) as? String else { return nil }
        
        self.init(token: token)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.token, forKey: NSCodingKey.token)
    }
}

extension JSONWebToken {
    
    /**
     Decodes a JSON web token and extracts the payload dictionary.
     
     - returns: Payload dictionary from a JSON web token.
     */
    func payload() -> NSDictionary? {
        // The access token is a JSON web token. Parse the payload to read the timestamp for when the token was issued.
        let components = token.componentsSeparatedByString(".")
        let payload = components[1]
        guard let decodedPayload = payload.base64Decode() else { return nil }
        
        let dictionary = try? NSJSONSerialization.JSONObjectWithData(decodedPayload, options: NSJSONReadingOptions())
        return dictionary as? NSDictionary
    }
    
    // MARK: Reserved Claims
    
    /**
     Decodes JSON web token and extracts expiration date claim within the payload.
     
     - returns: Expiration date claim for JSON web token.
     */
    func expirationDate() -> NSDate? {
        guard let payloadDictionary = payload() else { return nil }
        guard let expirationTimestamp = payloadDictionary["exp"] as? NSTimeInterval else { return nil }
        
        return NSDate(timeIntervalSince1970: expirationTimestamp)
    }
    
    /**
     Decodes JSON web token and extracts subject claim within the payload.
     
     - returns: Subject claim for JSON web token.
     */
    func subject() -> String? {
        guard let payloadDictionary = payload() else { return nil }
        
        return payloadDictionary["sub"] as? String
    }
}

extension JSONWebToken {
    
    func isExpired(orExpiringWithinMinutes minutes: Double = 0.0) -> Bool {
        let secondsPerMinute = 60.0
        let refreshThreshold = minutes * secondsPerMinute
        
        return (expirationDate()!.timeIntervalSinceNow < refreshThreshold) ? false : true
    }
}
