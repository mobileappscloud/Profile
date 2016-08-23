//
//  ChallengeDetailController.swift
//  higi
//
//  Created by Remy Panicker on 8/18/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

/// Responsible for data interaction related to challenge details.
final class ChallengeDetailController {
    
    /// Challenge to view details for.
    private(set) var challenge: Challenge
    
    private lazy var session: NSURLSession = APIClient.sharedSession

    // MARK: Init
    
    required init(challenge: Challenge) {
        self.challenge = challenge
    }
}

//MARK: - Joining a challenge
extension ChallengeDetailController {
    func join(challenge: Challenge, user: User, success: () -> Void, failure: () -> Void) {
        guard let joinURL = challenge.userRelation.joinURL else {
            failure()
            return
        }
        
        ChallengeJoinRequest(joinURL: joinURL, user: user).request({ [weak self] (request, error) in
            guard let strongSelf = self,
                let request = request else {
                    failure()
                    return
            }
            
            let task = NSURLSessionTask.JSONTask(strongSelf.session, request: request, success: { (JSON, response) in
                    success()
                }, failure: { (error, response) in
                    failure()
                }
            )
            task.resume()
        })
    }
}
