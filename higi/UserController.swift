//
//  UserController.swift
//  higi
//
//  Created by Remy Panicker on 5/3/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class UserController {
    
    private(set) var user: User
    
    private(set) lazy var session: NSURLSession = {
       return HigiAPIClient.session()
    }()
    
    init(user: User) {
        self.user = user
    }
    
    deinit {
        session.invalidateAndCancel()
    }
}

extension UserController {
    
    func replace(user: User) {
        self.user = user
    }
}

extension UserController {
    
    func fetch(success: () -> Void, failure: () -> Void) {
        guard let authorization = HigiAPIClient.authorization,
            let userId = authorization.accessToken.subject() else {
                failure()
                return
        }
        
        UserRequest.request(userId, completion: { [weak self] (request, error) in
            guard let strongSelf = self,
                let request = request else {
                    failure()
                    return
            }
            
            let task = NSURLSessionTask.JSONTask(strongSelf.session, request: request, success: { [weak strongSelf] (JSON, response) in
                
                guard let strongSelf = strongSelf else {
                    failure()
                    return
                }
                
                UserDeserializer.parse(JSON, success: { [weak strongSelf] (user) in
                    if let strongSelf = strongSelf {
                        print("successfully fetched and parsed user. creating user controller")
                        strongSelf.user = user
                        success()
                    }
                    }, failure: { (error) in
                        failure()
                })
                }, failure: { (error, response) in
                    failure()
            })
            task.resume()
            })
    }
}

extension UserController {
    
    func update(firstName: String, lastName: String, success: () -> Void, failure: (error: NSError?) -> Void) {
        UserUpdateRequest.request(user, firstName: firstName, lastName: lastName, completion: { [weak self] (request, error) in
            guard let strongSelf = self,
                let request = request else {
                    failure(error: error)
                    return
            }
            
            strongSelf.performUpdateTask(request, success: success, failure: failure)
        })
    }
    
    func update(termsFileName: String, privacyFileName: String, success: () -> Void, failure: (error: NSError?) -> Void) {
        UserUpdateRequest.request(user, termsFileName: termsFileName, privacyFileName: privacyFileName, completion: { [weak self] (request, error) in
            guard let strongSelf = self,
                let request = request else {
                    failure(error: error)
                    return
            }
            
            strongSelf.performUpdateTask(request, success: success, failure: failure)
        })
    }
    
    func update(dateOfBirth: NSDate, success: () -> Void, failure: (error: NSError?) -> Void) {
        UserUpdateRequest.request(user, dateOfBirth: dateOfBirth, completion: { [weak self] (request, error) in
            guard let strongSelf = self,
                let request = request else {
                    failure(error: error)
                    return
            }
            
            strongSelf.performUpdateTask(request, success: success, failure: failure)
        })
    }
    
    private func performUpdateTask(request: NSURLRequest, success: () -> Void, failure: (error: NSError?) -> Void) {
        let task = NSURLSessionTask.JSONTask(session, request: request, success: { (JSON, response) in
            UserDeserializer.parse(JSON, success: { [weak self] (user) in
                if let strongSelf = self {
                    strongSelf.user = user
                    success()
                }
                }, failure: failure)
            }, failure: { (error, response) in
                failure(error: error)
        })
        task.resume()
    }
}

extension UserController {
    
    func originalPhotoURL() -> NSURL {
        let relativePath = "/user/users/\(user.identifier)/photoOriginal"
        return HigiAPIClient.URL(relativePath, parameters: nil)!
    }
}
