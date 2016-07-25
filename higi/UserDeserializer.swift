//
//  UserDeserializer.swift
//  higi
//
//  Created by Remy Panicker on 5/3/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct UserDeserializer {}

extension UserDeserializer: JSONDeserializable {
    
    /**
     Parses a JSON dictionary with authentication information necessary for use with the higi API.
     
     - parameter JSON:    JSON dictionary with authorization information.
     - parameter success: Completion handler to be executed upon successfully parsing JSON.
     - parameter failure: Completion handler to be executed upon failure.
     */
    static func parse(JSON: AnyObject?, success: (user: User) -> Void, failure: (error: NSError?) -> Void) {
        if let responseDict = JSON as? NSDictionary,
            let dictionary = responseDict["data"] as? NSDictionary,
            let user = User(dictionary: dictionary) {
            success(user: user)
        } else {
            let error = NSError(sender: String(self), code: 0, message: "Unable to parse response - unexpected JSON format.")
            failure(error: error)
        }
    }
}
