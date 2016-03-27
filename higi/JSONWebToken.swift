//
//  JSONWebToken.swift
//  higi
//
//  Created by Remy Panicker on 3/24/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class JSONWebToken {
    
}

extension JSONWebToken {
    
    /**
     Decodes a JSON web token and extracts the payload dictionary.
     
     - parameter JSONWebToken: Base-64 encoded string representing a JSON web token.
     
     - returns: Payload dictionary from a JSON web token.
     */
    class func payload(JSONWebToken: String) -> NSDictionary? {
        // The access token is a JSON web token. Parse the payload to read the timestamp for when the token was issued.
        let components = JSONWebToken.componentsSeparatedByString(".")
        let payload = components[1]
        guard let decodedPayload = payload.base64Decode() else { return nil }
        
        let dictionary = try? NSJSONSerialization.JSONObjectWithData(decodedPayload, options: NSJSONReadingOptions())
        return dictionary as? NSDictionary
    }
    
    /**
     Decodes JSON web token and extracts expiration date within the payload.
     
     - parameter JSONWebToken: Base-64 encoded string representing a JSON web token.
     
     - returns: Expiration date for the input JSON web token.
     */
    class func expirationDate(JSONWebToken: String) -> NSDate? {
        guard let payloadDictionary = payload(JSONWebToken) else { return nil }
        guard let expirationTimestamp = payloadDictionary["exp"] as? NSTimeInterval else { return nil }
        
        return NSDate(timeIntervalSince1970: expirationTimestamp)
    }
}