//
//  String+Utility.swift
//  higi
//
//  Created by Remy Panicker on 3/24/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension String {
    
    /**
     URI-safe Base-64 decoding method. Sanitizes a string before returning the result from the `Foundation` implementation for decoding a Base-64 encoded string.
     
     - returns: A data object built by Base-64 decoding the provided string.
     
     _Inspired by code from [JSONWebToken Swift Library](https://github.com/kylef/JSONWebToken.swift.git)_
     */
    func base64Decode() -> NSData? {
        let rem = self.characters.count % 4
        
        var ending = ""
        if rem > 0 {
            let amount = 4 - rem
            ending = String(count: amount, repeatedValue: Character("="))
        }
        
        let base64 = self.stringByReplacingOccurrencesOfString("-", withString: "+", options: NSStringCompareOptions(rawValue: 0), range: nil)
            .stringByReplacingOccurrencesOfString("_", withString: "/", options: NSStringCompareOptions(rawValue: 0), range: nil) + ending
        
        return NSData(base64EncodedString: base64, options: NSDataBase64DecodingOptions(rawValue: 0))
    }
}

extension String {
    
    /// Extracted from [Stack Overflow](http://stackoverflow.com/a/24888789)
    ///
    /// Returns a new string made from the `String` by replacing all characters not in the unreserved
    /// character set (As defined by RFC3986) with percent encoded characters.
    func stringByAddingPercentEncodingForURLQueryParameter() -> String? {
        let allowedCharacters = NSCharacterSet.URLQueryParameterAllowedCharacterSet()
        return stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters)
    }
    
}