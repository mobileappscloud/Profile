//
//  LogInController.swift
//  higi
//
//  Created by Remy Panicker on 5/10/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class LogInController {
    
    let session = APIClient.sharedSession
    
    func authenticate(email: String, password: String, success: (user: User) -> (), failure: (error: NSError?) -> ()) {
        
        guard let request = LogInRequest.request(email, password: password) else {
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
