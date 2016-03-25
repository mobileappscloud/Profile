//
//  JSONFileReader.swift
//  higi
//
//  Created by Remy Panicker on 3/25/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

/// Utility class to read JSON from file.
final class JSONFileReader {
    
    /**
     Utility method to read JSON from a text file.
     
     - parameter fileName: Name of the JSON file. **Note: The file extension must be json.*
     
     - returns: JSON object as read from file.
     */
    class func JSON(fileName: String) -> AnyObject? {
        let filePath = NSBundle(forClass: JSONFileReader.self).pathForResource(fileName, ofType: "json")!
        let data = NSData(contentsOfFile: filePath)!
        let JSON = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
        return JSON
    }
}
