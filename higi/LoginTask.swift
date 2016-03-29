//
//  LoginTask.swift
//  higi
//
//  Created by Remy Panicker on 3/28/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class LoginTask: HigiAPITask {
    
    class func task(session: NSURLSession, email: String, password: String, success: (user: User) -> Void, failure: (error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let relativePath = "/authentication/login"
        let request = NSMutableURLRequest(URL: HigiAPIClient.endpointURL(relativePath))
        request.HTTPMethod = HTTPMethod.POST
        
        request.addValue(HigiAPIClient.clientId, forHTTPHeaderField: HigiAPIClient.HTTPHeaderName.clientId)
        
        let encodedValueData = "\(email):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
        let encodedCredentials = encodedValueData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        request.addValue("Basic \(encodedCredentials)", forHTTPHeaderField: HigiAPIClient.HTTPHeaderName.authorization)
        
        let task = NetworkRequest.JSONTask(session, request: request, success: { (JSON, response) in
                AuthenticationParser.parse(JSON, success: success, failure: failure)
            }, failure: { (error, response) in
                failure(error: error)
        })
        
        return task
    }
}
