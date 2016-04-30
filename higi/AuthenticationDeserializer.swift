//
//  AuthenticationDeserializer.swift
//  higi
//
//  Created by Remy Panicker on 3/28/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class AuthenticationDeserializer: HigiAPIJSONDeserializer {
 
    /**
     Parses a JSON dictionary with authentication information necessary for use with the higi API.
     
     - parameter JSON:    JSON dictionary with authorization information.
     - parameter success: Completion handler to be executed upon successfully parsing JSON.
     - parameter failure: Completion handler to be executed upon failure.
     */
    class func parse(JSON: AnyObject?, success: (user: User) -> Void, failure: (error: NSError?) -> Void) {
        if let JSON = JSON as? NSDictionary,
            let responseDict = JSON["data"] as? NSDictionary,
            let authorization = HigiAuthorization(dictionary: responseDict),
            let userDict = responseDict["User"] as? NSDictionary,
            let user = User(dictionary: userDict) {
            
            // TODO: Don't forget to move this to a controller and refactor once onboarding is refactored!
            HigiAPIClient.cacheAuthorization(authorization)
            
            success(user: user)
        } else {
            let error = NSError(sender: String(self), code: 0, message: "Unable to parse response - unexpected JSON format.")
            failure(error: error)
        }
    }
}