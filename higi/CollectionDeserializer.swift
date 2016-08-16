//
//  CollectionDeserializer.swift
//  higi
//
//  Created by Remy Panicker on 4/1/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class CollectionDeserializer: JSONDeserializable {
    
    /**
     Generic parsing of a JSON response from a collection API endpoint.
     
     - parameter JSON:     JSON response object.
     - parameter resource: Type of resource being initialized.
     
     - returns: Returns a collection of resources and a paging object if applicable.
     */
    static func parse<T: JSONInitializable>(collectionJSONResponse JSON: AnyObject?, forResource resource: T.Type) -> (collection: [T], paging: Paging?) {
        
        guard let JSON = JSON as? NSDictionary else { return ([], nil) }
        
        let resourceDicts = JSON["data"] as? [NSDictionary]
        let collection = parse(JSONDictionaries: resourceDicts, forResource: T.self) ?? []
        
        var paging: Paging?
        if let pagingDict = JSON["paging"] as? NSDictionary {
            paging = Paging(dictionary: pagingDict)
        }
        
        return (collection, paging)
    }
}

extension CollectionDeserializer {
    
    /**
     Initialization of a collection of generic resources.
     
     - parameter dictionaries: An array of dictionaries representing the specified resource type.
     - parameter resource:     Type of resource being initialized.
     
     - returns: A collection of serialized resources.
     */
    static func parse<T: JSONInitializable>(dictionaries dictionaries: [NSDictionary], forResource resource: T.Type) -> [T] {
        var collection: [T] = []
        for dictionary in dictionaries {
            guard let resource = T(dictionary: dictionary) else { continue }
            
            collection.append(resource)
        }
        return collection
    }
    
    /**
     Failable initializer for a collection of generic resources.
     
     - parameter JSONDictionaries: JSON representation of a collection of dictionaries.
     - parameter resource:         Type of resource being initialized.
     
     - returns: A collection of serialized resources.
     */
    static func parse<T: JSONInitializable>(JSONDictionaries JSONDictionaries: AnyObject?, forResource resource: T.Type) -> [T]? {
        guard let JSONDictionaries = JSONDictionaries as? [NSDictionary] else { return nil }

        return parse(dictionaries: JSONDictionaries, forResource: resource)
    }
}
