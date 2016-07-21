//
//  ChatterMessageCollectionDeserializer.swift
//  higi
//
//  Created by Remy Panicker on 7/20/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct ChatterMessageCollectionDeserializer {}

extension ChatterMessageCollectionDeserializer: HigiAPIJSONDeserializer {
    
    /**
     Parses a JSON dictionary with a collection of chatter messages.
     
     - parameter JSON:    JSON dictionary with a collection of chatter messages.
     - parameter success: Completion handler to be executed upon successfully parsing JSON.
     - parameter failure: Completion handler to be executed upon failure.
     */
    static func parse(JSON: AnyObject?, success: (messages: [ChatterMessage], paging: Paging?) -> Void, failure: (error: NSError?) -> Void) {
        
        CollectionDeserializer.parse(JSON, success: { (collection, paging) in
            
            var messages: [ChatterMessage] = []
            for dictionary in collection {
                if let dictionary = dictionary as? NSDictionary,
                    let message = ChatterMessage(dictionary: dictionary) {
                    messages.append(message)
                }
            }
            
            success(messages: messages, paging: paging)
            
            }, failure: { (error) in
                failure(error: error)
        })
    }
}

