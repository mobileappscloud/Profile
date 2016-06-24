//
//  ChallengeCollectionDeserializer.swift
//  higi
//
//  Created by Remy Panicker on 5/16/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct ChallengeCollectionDeserializer: HigiAPIJSONDeserializer {
    
    /**
     Parses a JSON dictionary with challenge collection information necessary for use with the higi API.
     
     - parameter JSON:    JSON dictionary with challenge collection information.
     - parameter success: Completion handler to be executed upon successfully parsing JSON.
     - parameter failure: Completion handler to be executed upon failure.
     */
    static func parse(JSON: AnyObject?, success: (challenges: [HigiChallenge], paging: Paging?) -> Void, failure: (error: NSError?) -> Void) {
     
        CollectionDeserializer.parse(JSON, success: { (collection, paging) in
            
            var challenges: [HigiChallenge] = []
            for dictionary in collection {
                guard let dictionary = dictionary as? NSDictionary,
                    let challenge = HigiChallenge(dictionary: dictionary) else { continue }
                
                challenges.append(challenge)
            }
            
            success(challenges: challenges, paging: paging)
            
        }, failure: failure)
    }
}
