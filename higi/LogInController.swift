//
//  LogInController.swift
//  higi
//
//  Created by Remy Panicker on 5/10/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class LogInController {
    
    lazy private var session = APIClient.sharedSession
    
    func authenticate(email: String, password: String, success: (user: User) -> (), failure: (error: NSError?) -> ()) {
        
        guard let request = LogInRequest(email: email, password: password).request() else {
            failure(error: nil)
            return
        }
        
        let task = NSURLSessionTask.JSONTask(session, request: request, success: { (JSON, response) in
            
            AuthorizationDeserializer.parse(JSON, success: { (user, authorization) in
                success(user: user)
            }, failure: failure)
            
        }, failure: { (error, response) in
            failure(error: error)
        })
        task.resume()
    }
}
