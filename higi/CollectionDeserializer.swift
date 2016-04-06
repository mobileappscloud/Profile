//
//  CollectionDeserializer.swift
//  higi
//
//  Created by Remy Panicker on 4/1/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class CollectionDeserializer: HigiAPIJSONDeserializer {
    
    class func parse(JSON: AnyObject?, success: (collection: NSArray, paging: Paging?) -> Void, failure: (error: NSError?) -> Void) {

        if let JSON = JSON as? NSDictionary {
            
            let collection: NSArray = (JSON["data"] as? NSArray) ?? []
            
            var paging: Paging?
            if let pagingDict = JSON["paging"] as? NSDictionary {
                paging = Paging(dictionary: pagingDict)
            }
            
            success(collection: collection, paging: paging)
        } else {
            failure(error: nil)
        }
    }
}
