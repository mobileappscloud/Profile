//
//  NSData+Utility.swift
//  higi
//
//  Created by Remy Panicker on 5/23/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension NSMutableData {
    
    /**
     Applies `UTF-8` encoding to a string and appends the string to the data object.
     
     - parameter string: String to append.
     */
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}
