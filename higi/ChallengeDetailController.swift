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

// MARK: - Joining a challenge
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

// MARK: - Fetching a challenge
extension ChallengeDetailController {
    func refreshChallenge(success success: (challenge: Challenge) -> Void, failure: (error: ErrorType) -> Void) {
        
        let gravityBoard = 3
        let participants = 50
        let comments = 50
        let teamComments = 50
        
        ChallengeRequest(challenge: challenge, gravityBoard: gravityBoard, participants: participants, comments: comments, teamComments: teamComments).request({ [weak self] (request, error) in
            
            guard let strongSelf = self,
                let request = request else {
                    failure(error: error ?? Error.authenticationError)
                    return
            }
            
            let task = NSURLSessionTask.JSONTask(strongSelf.session, request: request, success: { [weak strongSelf] (JSON, response) in
                guard let strongSelf = strongSelf else { return }
                
                guard let challengeDictionary = JSON as? NSDictionary, let updatedChallenge = Challenge(dictionary: challengeDictionary) else {
                    return failure(error: Error.parsingError)
                }
                
                strongSelf.challenge = updatedChallenge
                success(challenge: updatedChallenge)
            }, failure: { (error, response) in
                failure(error: error ?? Error.challengeRetrievalError)
            })
            task.resume()
        })
    }
}

// MARK: - Errors
extension ChallengeDetailController {
    enum Error: ErrorType {
        case unknown
        case authenticationError
        case parsingError
        case challengeRetrievalError
    }
}