//
//  FeedCollectionDeserializer.swift
//  higi
//
//  Created by Remy Panicker on 6/23/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct FeedCollectionDeserializer {}

extension FeedCollectionDeserializer: HigiAPIJSONDeserializer {
    
    /**
     Parses a JSON dictionary with a collection of feed posts.
     
     - parameter JSON:    JSON dictionary with a collection of feed posts.
     - parameter success: Completion handler to be executed upon successfully parsing JSON.
     - parameter failure: Completion handler to be executed upon failure.
     */
    static func parse(JSON: AnyObject?, success: (posts: [Post], paging: Paging?) -> Void, failure: (error: NSError?) -> Void) {
        
        CollectionDeserializer.parse(JSON, success: { (collection, paging) in
            
            var posts: [Post] = []
            for dictionary in collection {
                if let dictionary = dictionary as? NSDictionary,
                    let community = Post(dictionary: dictionary) {
                    posts.append(community)
                }
            }
            
            success(posts: posts, paging: paging)
            
            }, failure: { (error) in
                failure(error: error)
        })
    }
}
