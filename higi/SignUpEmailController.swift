//
//  SignUpEmailController.swift
//  higi
//
//  Created by Remy Panicker on 5/3/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class SignUpEmailController {
    
    let session = HigiAPIClient.session()
    
    deinit {
        session.invalidateAndCancel()
    }
}

extension SignUpEmailController {

    func createUser(email: String, password: String, success: () -> (), failure: (error: NSError?) -> ()) {
        
        guard let request = UserCreateRequest.request(email, password: password) else {
            failure(error: nil)
            return
        }
        
        let task = NSURLSessionTask.JSONTask(session, request: request, success: { (JSON, response) in
            success()
            }, failure: { (error, response) in
                if let response = response where response.statusCodeEnum == .Conflict {
                    let duplicateError = NSError(domain: HTTPErrorDomain, code: response.statusCode, userInfo: nil)
                    failure(error: duplicateError)
                } else {
                    failure(error: error)
                }
        })
        task.resume()
    }
}

extension SignUpEmailController {
    
    func logIn(email: String, password: String, success: (user: User) -> Void, failure: (error: NSError?) -> ()) {
        
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
