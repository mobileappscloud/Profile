//
//  RefreshTokenTask.swift
//  higi
//
//  Created by Remy Panicker on 3/28/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class RefreshTokenTask: HigiAPITask {
    
    class func task(session: NSURLSession, email: String, password: String, success: (user: User) -> Void, failure: (error: NSError?) -> Void) -> NSURLSessionDataTask? {
        guard let authorization = HigiAPIClient.authorization else {
            failure(error: nil)
            return nil
        }

        let relativePath = "/authentication/refresh"
        let request = NSMutableURLRequest(URL: HigiAPIClient.endpointURL(relativePath))
        request.HTTPMethod = HTTPMethod.POST
        
        request.addValue(HigiAPIClient.clientId, forHTTPHeaderField: HigiAPIClient.HTTPHeaderName.clientId)
        request.addValue(authorization.refreshToken, forHTTPHeaderField: HigiAPIClient.HTTPHeaderName.refreshToken)
        
        let task = NetworkRequest.JSONTask(session, request: request, success: { (JSON, response) in
            AuthenticationParser.parse(JSON, success: success, failure: failure)
            }, failure: { (error, response) in
                failure(error: error)
        })
        return task
    }
}
