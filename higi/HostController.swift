//
//  HostController.swift
//  higi
//
//  Created by Remy Panicker on 5/4/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class HostController {
    
    lazy private var session = APIClient.sharedSession
    
    var userController: UserController?
}

extension HostController {
    
    func appMeetsMinimumVersion(success: () -> Void, failure: () -> Void) {
        /** @internal: In order to preserve legacy logic, this method can only invoke the failure
            handler if the minimum version is retrieved and the app does not meet the minimum requirement. */
        
        guard let request = MinimumVersionRequest().request() else {
            success()
            return
        }
        
        let task = NSURLSessionTask.JSONTask(session, request: request, success: { (JSON, response) in
            
            guard let minVersion = JSON as? String else {
                success()
                return
            }
            
            let isUpToDate = Utility.appMeetsMinimumVersionRequirement(minVersion)
            if isUpToDate {
                success()
            } else {
                failure()
            }
            
        }, failure: { (error, response) in
            success()
        })
        task.resume()
    }
}

extension HostController {
    
    func migrateLegacyToken(success: () -> Void, failure: () -> Void) {
        guard let token = legacyToken(),
            let userId = legacyUserId(),
            let request = TokenRefreshRequest(token: token, tokenType: .Legacy, userId: userId).request() else {
                removeLegacySessionData()
                failure()
                return
        }
        
        let task = NSURLSessionTask.JSONTask(session, request: request, success: { (JSON, response) in
            AuthorizationDeserializer.parse(JSON, success: { (user, authorization) in
                success()
            }, failure: { (error) in
                failure()
            })
        }, failure: { (error, response) in
            failure()
        })
        task.resume()
        removeLegacySessionData()
    }
}

extension HostController {
    
    func fetchUser(success: () -> Void, failure: () -> Void) {
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
                guard let user = ResourceDeserializer.parse(JSON, resource: User.self) else {
                    failure()
                    return
                }
                
                strongSelf.userController = UserController(user: user)
                success()
                
                }, failure: { [weak strongSelf] (error, response) in
                    guard strongSelf != nil else { return }
                    
                    failure()
                })
            task.resume()
            })
    }
}

extension HostController {
    
    func revokeRefreshToken(completion: () -> Void) {
        TokenRevokeRequest().request({ [weak self] (request, error) in
            guard let strongSelf = self,
                let request = request else {
                    completion()
                    return
            }
            
            let task = NSURLSessionTask.JSONTask(strongSelf.session, request: request, success: { _,_ in
                completion()
                }, failure: { error, response in
                    completion()
            })
            task.resume()
        })
    }
}

extension HostController {
    
    func authorizationTokenIsCached() -> Bool {
        return (APIClient.authorization != nil) || (legacyToken() != nil && legacyToken()!.characters.count > 0)
    }
    
    func authorizationTokenIsLegacyToken() -> Bool {
        return (legacyToken() != nil && legacyToken()!.characters.count > 0) && (APIClient.authorization == nil)
    }
    
    func accessTokenIsExpired() -> Bool {
        guard let authorization = APIClient.authorization else { return false }
        return authorization.accessToken.isExpired(orExpiringWithinMinutes: 1.0)
    }
}

extension HostController {
    
    private func legacyToken() -> String? {
        return KeychainWrapper.stringForKey("token")
    }
    
    private func legacyUserId() -> String? {
        return (KeychainWrapper.objectForKey("userId") as? NSString) as? String
    }
    
    private func legacySessionDataSavePath() -> String {
        let documentsPath = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])
        let documentsURL = NSURL(fileURLWithPath: documentsPath)
        let writePath = documentsURL.URLByAppendingPathComponent("HigiSessionData.plist")
        return writePath.relativePath!
    }
    
    private func legacyTempSavePath() -> String {
        let tempPath = (NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0])
        let tempURL = NSURL(fileURLWithPath: tempPath)
        let writePath = tempURL.URLByAppendingPathComponent("TempSessionData.plist")
        return writePath.relativePath!
    }
    
    private func removeLegacySessionData() {
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.removeItemAtPath(legacySessionDataSavePath())
        } catch {
            
        }
        do {
            try fileManager.removeItemAtPath(legacyTempSavePath())
        } catch {
            
        }
        if let _ = legacyToken() {
            KeychainWrapper.removeObjectForKey("token")
        }
        if let _ = legacyUserId() {
            KeychainWrapper.removeObjectForKey("userId")
        }
    }
}
