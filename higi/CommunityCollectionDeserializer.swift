//
//  CommunityCollectionDeserializer.swift
//  higi
//
//  Created by Remy Panicker on 3/31/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class CommunityCollectionDeserializer: HigiAPIJSONDeserializer {
    
    /**
     Parses a JSON dictionary with authentication information necessary for use with the higi API.
     
     - parameter JSON:    JSON dictionary with authorization information.
     - parameter success: Completion handler to be executed upon successfully parsing JSON.
     - parameter failure: Completion handler to be executed upon failure.
     */
    class func parse(JSON: AnyObject?, success: (communities: [Community], paging: Paging?) -> Void, failure: (error: NSError?) -> Void) {
        
        CollectionDeserializer.parse(JSON, success: { (collection, paging) in
            
            var communities: [Community] = []
            for dictionary in collection {
                if let dictionary = dictionary as? NSDictionary,
                    let community = Community(dictionary: dictionary) {
                    communities.append(community)
                }
            }
            
            success(communities: communities, paging: paging)
            
            }, failure: { (error) in
                failure(error: error)
        })
    }
}