//
//  NSURL+Utility.swift
//  higi
//
//  Created by Remy Panicker on 4/5/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension NSURL {
    
    /**
     Creates a new query parameters string from the given NSDictionary. For example, if the input is
     
     ["day" : "Tuesday", "month" : "January"]
     
     the output string will be
     
     "day=Tuesday&month=January"
     
     - parameter queryParameters: The input dictionary.
     
     - returns: The created parameters string.
     */
    class func stringFromQueryParameters(queryParameters : [String : String]) -> String {
        var parts: [String] = []
        for (name, value) in queryParameters {
            let queryParameterCharacterSet = NSCharacterSet.URLQueryParameterAllowedCharacterSet()
            guard let encodedName = name.stringByAddingPercentEncodingWithAllowedCharacters(queryParameterCharacterSet),
                let encodedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(queryParameterCharacterSet) else {
                    continue
            }
            
            let part = "\(encodedName)=\(encodedValue)"
            parts.append(part)
        }
        return parts.joinWithSeparator("&")
    }
    
    /**
     Creates a new URL by adding the given query parameters.
     
     - parameter URL: The input URL.
     - parameter queryParameters: The query parameter dictionary to add.
     
     - returns: A new NSURL.
     */
    class func URLByAppendingQueryParameters(URL : NSURL, queryParameters : [String : String]) -> NSURL {
        if queryParameters.isEmpty { return URL }
        
        let URLString = "\(URL.absoluteString)?\(stringFromQueryParameters(queryParameters))"
        return NSURL(string: URLString)!
    }
}
