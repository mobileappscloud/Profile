//
//  NSCharacterSet+Utility.swift
//  higi
//
//  Created by Remy Panicker on 4/7/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

// MARK: URL Percent Encoding Extensions -->

extension NSCharacterSet {

    /// Extracted from [Stack Overflow](http://stackoverflow.com/a/24888789)
    ///
    /// Returns the character set for characters allowed in the individual parameters within a query URL component.
    ///
    /// The query component of a URL is the component immediately following a question mark (?).
    /// For example, in the URL `http://www.example.com/index.php?key1=value1#jumpLink`, the query
    /// component is `key1=value1`. The individual parameters of that query would be the key `key1`
    /// and its associated value `value1`.
    ///
    /// According to RFC 3986, the set of unreserved characters includes
    ///
    /// `ALPHA / DIGIT / "-" / "." / "_" / "~"`
    ///
    /// In section 3.4 of the RFC, it further recommends adding `/` and `?` to the list of unescaped characters
    /// for the sake of compatibility with some erroneous implementations, so this routine also allows those
    /// to pass unescaped.
    class func URLQueryParameterAllowedCharacterSet() -> Self {
        return self.init(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~/?")
    }
    
}