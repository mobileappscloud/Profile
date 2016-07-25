//
//  ChallengesController.swift
//  higi
//
//  Created by Remy Panicker on 5/16/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ChallengesController {
    
    private(set) var challenges: [HigiChallenge] = []
    
    var activeChallenges:[HigiChallenge] = []
    var upcomingChallenges:[HigiChallenge] = []
    var availableChallenges:[HigiChallenge] = []
    var invitedChallenges:[HigiChallenge] = []
    
    private lazy var session: NSURLSession = {
        return APIClient.sharedSession
    }()
    
    private(set) var paging: Paging?
    
    private(set) var fetchTask: NSURLSessionTask?
    
    deinit {
        fetchTask?.cancel()
    }
}

extension ChallengesController {
    
    func fetch(forUser user: User, success: () -> Void, failure: () -> Void) {
        let gravityBoard = 3
        let participants = 50
        let comments = 50
        let teamComments = 50
        
        ChallengeCollectionRequest.request(user, gravityBoard: gravityBoard, participants: participants, comments: comments, teamComments: teamComments, completion: { [weak self] (request, error) in
            
            guard let strongSelf = self,
                let request = request else {
                    failure()
                    return
            }
            
            let task = NSURLSessionTask.JSONTask(strongSelf.session, request: request, success: { [weak strongSelf] (JSON, response) in
                
                guard let strongSelf = strongSelf else { return }
                
                strongSelf.fetchTask = nil
                
                CollectionDeserializer.parse(JSON, resource: HigiChallenge.self, success: { [weak strongSelf] (challenges, paging) in
                    guard let strongSelf = strongSelf else { return }
                    
                    strongSelf.challenges = challenges
                    success()

                }, failure: { (error) in
                    failure()
                })
                
            }, failure: { [weak strongSelf] (error, response) in
                guard let strongSelf = strongSelf else { return }
                strongSelf.fetchTask = nil
                failure()
            })
            task.resume()
            strongSelf.fetchTask = task
        })
    }
}

extension ChallengesController {
    
    func fetch(challenge: HigiChallenge, user: User, success: (challenge: HigiChallenge) -> Void, failure: () -> Void) {
        
        let gravityBoard = 3
        let participants = 50
        let comments = 50
        let teamComments = 50
        
        ChallengeRequest.request(challenge, user: user, gravityBoard: gravityBoard, participants: participants, comments: comments, teamComments: teamComments, completion: { [weak self] (request, error) in
            
            guard let strongSelf = self,
                let request = request else {
                    failure()
                    return
            }
            
            let task = NSURLSessionTask.JSONTask(strongSelf.session, request: request, success: { [weak strongSelf] (JSON, response) in
                
                guard let strongSelf = strongSelf,
                    let challengeDictionary = JSON as? NSDictionary,
                    let updatedChallenge = HigiChallenge(dictionary: challengeDictionary) else {
                        failure()
                        return
                }
                
                var challenges = strongSelf.challenges
                if let index = challenges.indexOf({$0.identifier == challenge.identifier}) {
                    challenges.removeAtIndex(index)
                }
                challenges.append(updatedChallenge)
                success(challenge: updatedChallenge)
                
                }, failure: { (error, response) in
                    failure()
            })
            task.resume()
        })
    }
}

extension ChallengesController {
    
    func join(challenge: HigiChallenge, user: User, success: () -> Void, failure: () -> Void) {
        guard let URLString = challenge.joinUrl,
            let joinURL = NSURL(string: URLString as String) else {
                failure()
                return
        }
        
        ChallengeJoinRequest.request(joinURL: joinURL, user: user, completion: { [weak self] (request, error) in
            guard let strongSelf = self,
                let request = request else {
                    failure()
                    return
            }
            
            let task = NSURLSessionTask.JSONTask(strongSelf.session, request: request, success: { (JSON, response) in
                success()
            }, failure: { (error, response) in
                failure()
            })
            task.resume()
        })
    }
}
