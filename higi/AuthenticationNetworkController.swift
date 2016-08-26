//
//  AuthenticationNetworkController.swift
//  higi
//
//  Created by Remy Panicker on 8/25/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

/// Network controller which interfaces with the authentication service.
final class AuthenticationNetworkController: NetworkRequestable {
    
    private(set) lazy var session: NSURLSession = APIClient.sharedSession
}

// MARK: - Log in

extension AuthenticationNetworkController {
    
    /**
     Authenticate a user session.
     
     - parameter email:    Email for the user.
     - parameter password: Password for the user.
     - parameter success:  Block which is executed upon success.
     - parameter failure:  Block which is executed upon failure.
     */
    func authenticate(email: String, password: String, success: (user: User) -> (), failure: (error: NSError?) -> ()) {
        
        guard let request = LogInRequest(email: email, password: password).request() else {
            failure(error: nil)
            return
        }
        
        let task = NSURLSessionTask.JSONTask(session, request: request, success: { [weak self] (JSON, response) in
            guard self != nil else { return }
            
            AuthorizationDeserializer.parse(JSON, success: { [weak self] (user, authorization) in
                guard self != nil else { return }
                success(user: user)
                }, failure: failure)
            
            }, failure: { [weak self] (error, response) in
                guard self != nil else { return }
                failure(error: error)
        })
        task.resume()
    }
}

// MARK: - Create User

extension AuthenticationNetworkController {
    
    /**
     Creates a new user account.
     
     - parameter email:           Email for the user.
     - parameter password:        Password for the user.
     - parameter termsFileName:   File name of terms of service the user has agreed to.
     - parameter privacyFileName: File name of privacy policy the user has agreed to.
     - parameter success:         Block which is executed upon success.
     - parameter failure:         Block which is executed upon failure.
     */
    func createUser(email: String, password: String, termsFileName: String, privacyFileName: String, success: (user: User) -> (), failure: (error: NSError?) -> ()) {
        
        guard let request = UserCreateRequest(email: email, password: password, termsFileName: termsFileName, privacyFileName: privacyFileName).request() else {
            failure(error: nil)
            return
        }
        
        let task = NSURLSessionTask.JSONTask(session, request: request, success: { [weak self] (JSON, response) in
            guard self != nil else { return }
            
            AuthorizationDeserializer.parse(JSON, success: { [weak self] (user, authorization) in
                guard self != nil else { return }
                success(user: user)
                }, failure: failure)
            
            }, failure: { [weak self] (error, response) in
                guard self != nil else { return }
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
