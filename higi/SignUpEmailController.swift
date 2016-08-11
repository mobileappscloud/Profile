//
//  SignUpEmailController.swift
//  higi
//
//  Created by Remy Panicker on 5/3/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class SignUpEmailController {
    
    private lazy var session: NSURLSession = APIClient.sharedSession
}

extension SignUpEmailController {

    func createUser(email: String, password: String, success: () -> (), failure: (error: NSError?) -> ()) {
        
        guard let request = UserCreateRequest(email: email, password: password).request() else {
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
