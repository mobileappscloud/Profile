//
//  UserController.swift
//  higi
//
//  Created by Remy Panicker on 5/3/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class UserController {
    
    private(set) var user: User {
        didSet {
            guard oldValue.identifier == user.identifier else { return }
            challengeRepository = UserDataRepository<Challenge>()
            communityRepository = UserDataRepository<Community>()
        }
    }
    
    private lazy var session: NSURLSession = APIClient.sharedSession
    
    /// Dictionary of string identifiers to their associated objects.
    /// The objects can be anything from the server: Communities, Challenges, etc.
    private(set) var challengeRepository = UserDataRepository<Challenge>()
    private(set) var communityRepository = UserDataRepository<Community>()
    
    init(user: User) {
        self.user = user
    }
}

extension UserController {
    
    func replace(user: User) {
        self.user = user
    }
}

extension UserController {
    
    func fetch(success: () -> Void, failure: () -> Void) {
        guard let authorization = APIClient.authorization,
            let userId = authorization.accessToken.subject() else {
                failure()
                return
        }
        
        UserRequest(userId: userId).request({ [weak self] (request, error) in
            guard let strongSelf = self,
                let request = request else {
                    failure()
                    return
            }
            
            let task = NSURLSessionTask.JSONTask(strongSelf.session, request: request, success: { [weak strongSelf] (JSON, response) in
                
                guard let strongSelf = strongSelf else { return }
                
                if let user = ResourceDeserializer.parse(JSON, resource: User.self) {
                    strongSelf.user = user
                    success()
                } else {
                    failure()
                }
                
                }, failure: { [weak strongSelf] (error, response) in
                    guard strongSelf != nil else { return }
                    
                    failure()
                })
            task.resume()
            })
    }
}

extension UserController {
    
    func update(firstName: String, lastName: String, success: () -> Void, failure: (error: NSError?) -> Void) {
        UserNameUpdateRequest(user: user, firstName: firstName, lastName: lastName).request({ [weak self] (request, error) in
            guard let strongSelf = self,
                let request = request else {
                    failure(error: error)
                    return
            }
            
            strongSelf.performUpdateTask(request, success: success, failure: failure)
        })
    }
    
    func update(termsFileName: String, privacyFileName: String, success: () -> Void, failure: (error: NSError?) -> Void) {
        UserTermsUpdateRequest(user: user, termsFileName: termsFileName, privacyFileName: privacyFileName).request({ [weak self] (request, error) in
            guard let strongSelf = self,
                let request = request else {
                    failure(error: error)
                    return
            }
            
            strongSelf.performUpdateTask(request, success: success, failure: failure)
        })
    }
    
    func update(dateOfBirth: NSDate, success: () -> Void, failure: (error: NSError?) -> Void) {
        UserDateOfBirthUpdateRequest(user: user, dateOfBirth: dateOfBirth).request({ [weak self] (request, error) in
            guard let strongSelf = self,
                let request = request else {
                    failure(error: error)
                    return
            }
            
            strongSelf.performUpdateTask(request, success: success, failure: failure)
        })
    }
    
    private func performUpdateTask(request: NSURLRequest, success: () -> Void, failure: (error: NSError?) -> Void) {
        let task = NSURLSessionTask.JSONTask(session, request: request, success: { [weak self] (JSON, response) in
            guard let strongSelf = self else { return }
            
            if let user = ResourceDeserializer.parse(JSON, resource: User.self) {
                strongSelf.user = user
                success()
            } else {
                failure(error: nil)
            }
            
            }, failure: { [weak self] (error, response) in
                guard self != nil else { return }
                
                failure(error: error)
            })
        task.resume()
    }
}

extension UserController {
    
    func originalPhotoURL() -> NSURL {
        let relativePath = "/user/users/\(user.identifier)/photoOriginal"
        return APIClient.URL(relativePath, parameters: nil)!
    }
}
