//
//  HigiAPIJSONDeserializer.swift
//  higi
//
//  Created by Remy Panicker on 3/29/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

protocol HigiAPIJSONDeserializer: HigiAPI2 {}

extension HigiAPIJSONDeserializer {
    
    static func deserialize(data: NSData?, success: (JSON: AnyObject?) -> Void, failure: (error: NSError?) -> Void) {
        guard let data = data else {
            failure(error: nil)
            return
        }
        
        if data.length > 0 {
            do {
                let JSON = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
                success(JSON: JSON)
            } catch {
                let error = NSError(sender: String(self), code: 0, message: "Error serializing response.")
                failure(error: error)
            }
        } else {
            failure(error: nil)
        }
    }
}
