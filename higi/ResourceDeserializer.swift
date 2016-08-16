//
//  ResourceDeserializer.swift
//  higi
//
//  Created by Remy Panicker on 8/2/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ResourceDeserializer: JSONDeserializable {

    /**
     Parses a JSON dictionary with data for a single resource.
     
     - parameter JSON:    JSON dictionary with resource data.
     - parameter resource: Type of resource to parse.
     
     - returns: A new model from the JSON passed in.
     */
    static func parse<T: JSONInitializable>(JSON: AnyObject?, resource: T.Type) -> T? {
        guard let responseDict = JSON as? NSDictionary,
            let dictionary = responseDict["data"] as? NSDictionary else {
                return nil
        }
        
        return T(dictionary: dictionary)
    }
}
