//
//  ChallengesNetworkController.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 9/2/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct ChallengesNetworkController { }


// MARK: - Joining a challenge
extension ChallengesNetworkController {
    static func join(challenge challenge: Challenge, user: User, session: NSURLSession = APIClient.sharedSession, success: (challenge: Challenge) -> Void, failure: (error: ErrorType) -> Void) {
        guard let joinURL = challenge.userRelation.joinURL else {
            return failure(error: Error.noJoinUrl)
        }
        ChallengeJoinRequest(joinURL: joinURL, user: user).request({(request, error) in
            guard let request = request else {
                return failure(error: error ?? Error.authentication)
            }
            let task = NSURLSessionTask.JSONTask(session, request: request, success: { (JSON, response) in
                fetch(challenge: challenge, session: session, success: success, failure: failure)
            }, failure: { (error, response) in
                failure(error: error ?? Error.unknown)
            })
            task.resume()
        })
    }
}

// MARK: - Fetch a challenge
extension ChallengesNetworkController {
    static func fetch(challenge challenge: Challenge, session: NSURLSession = APIClient.sharedSession, success: (challenge: Challenge) -> Void, failure: (error: ErrorType) -> Void) {
        let gravityBoard = 3
        let participants = 50
        let comments = 50
        let teamComments = 50
        
        ChallengeRequest(challenge: challenge, gravityBoard: gravityBoard, participants: participants, comments: comments, teamComments: teamComments).request({(request, error) in
            guard let request = request else {
                return failure(error: error ?? Error.authentication)
            }
            
            let task = NSURLSessionTask.JSONTask(session, request: request, success: {(JSON, response) in
                guard let updatedChallenge = ResourceDeserializer.parse(JSON, resource: Challenge.self) else {
                    return failure(error: Error.parsing)
                }
                success(challenge: updatedChallenge)
            }, failure: { (error, response) in
                failure(error: error ?? Error.challengeRetrieval)
            })
            task.resume()
        })
    }

}

// MARK: - Errors
extension ChallengesNetworkController {
    enum Error: ErrorType {
        case unknown
        case noJoinUrl
        case authentication
        case parsing
        case challengeRetrieval
    }
}