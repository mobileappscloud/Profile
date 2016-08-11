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
     - parameter success: Completion handler to be executed upon successfully parsing JSON.
     - parameter failure: Completion handler to be executed upon failure.
     */
    static func parse<Resource: JSONInitializable>(JSON: AnyObject?, resource: Resource.Type, success: (resource: Resource) -> Void, failure: (error: NSError?) -> Void) {
        
        guard let responseDict = JSON as? NSDictionary,
            let dictionary = responseDict["data"] as? NSDictionary,
            let resource = Resource(dictionary: dictionary) else {
                let error = NSError(sender: String(self), code: 0, message: "Unable to parse response - unexpected JSON format.")
                failure(error: error)
                return
        }
        
        success(resource: resource)
    }
}
