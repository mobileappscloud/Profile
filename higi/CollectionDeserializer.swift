//
//  CollectionDeserializer.swift
//  higi
//
//  Created by Remy Panicker on 4/1/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct CollectionDeserializer: JSONDeserializable {
    
    static func parse<Resource: JSONInitializable>(JSON: AnyObject?, resource: Resource.Type, success: (collection: [Resource], paging: Paging?) -> Void, failure: (error: NSError?) -> Void) {
        
        if let JSON = JSON as? NSDictionary {
            
            let resourceDicts: NSArray = (JSON["data"] as? NSArray) ?? []
            var collection: [Resource] = []
            for dictionary in resourceDicts {
                guard let dictionary = dictionary as? NSDictionary,
                    let resource = Resource(dictionary: dictionary) else { continue }
                
                collection.append(resource)
            }
            
            var paging: Paging?
            if let pagingDict = JSON["paging"] as? NSDictionary {
                paging = Paging(dictionary: pagingDict)
            }
            
            success(collection: collection, paging: paging)
        } else {
            let error = NSError(sender: String(self), code: 0, message: "Unable to parse response - unexpected JSON format.")
            failure(error: error)
        }
    }
}
