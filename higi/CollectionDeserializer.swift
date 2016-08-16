//
//  CollectionDeserializer.swift
//  higi
//
//  Created by Remy Panicker on 4/1/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class CollectionDeserializer: JSONDeserializable {
    
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

extension CollectionDeserializer {
    
    /**
     Initialization of a collection of generic resources.
     
     - parameter resourceType:   Type of resource being initialized.
     - parameter dictionaries:   An array of dictionaries representing the specified resource type.
     
     - returns: A collection of serialized resources.
     */
    static func parse<T: JSONInitializable>(dictionaries: [NSDictionary], forResource resource: T.Type) -> [T] {
        var collection: [T] = []
        for dictionary in dictionaries {
            guard let resource = T(dictionary: dictionary) else { continue }
            
            collection.append(resource)
        }
        return collection
    }
    
    /**
     Failable initializer for of a collection of generic resources.
     
     - parameter JSONDictionaries: JSON representation of a collection of dictionaries.
     - parameter resource:         Type of resource being initialized.
     
     - returns: A collection of serialized resources.
     */
    static func parse<T: JSONInitializable>(JSONDictionaries: AnyObject?, forResource resource: T.Type) -> [T]? {
        guard let JSONDictionaries = JSONDictionaries as? [NSDictionary] else { return nil }

        return parse(JSONDictionaries, forResource: resource)
    }
}
