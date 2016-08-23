//
//  ChallengesController.swift
//  higi
//
//  Created by Remy Panicker on 5/16/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ChallengesController {
    
    private(set) var challenges: [Challenge] = []
    
    private lazy var session: NSURLSession = APIClient.sharedSession
    
    private(set) var paging: Paging?
    
    private(set) var fetchTask: NSURLSessionTask?
    
    deinit {
        fetchTask?.cancel()
    }
}

//MARK: - Enums
extension ChallengesController {
    enum ChallengeType {
        case Current
        case Finished
        
        var asFilter: [ChallengeCollectionRequest.Filter] {
            switch self {
                case .Current: return [.current, .upcoming]
                case .Finished: return [.finished]
            }
        }
    }
}

extension ChallengesController {
    
    func fetch(forEntityType entityType: ChallengeCollectionRequest.EntityType, entityId: String, challengesType: ChallengeType? = nil, success: () -> Void, failure: () -> Void) {
        let gravityBoard = 3
        let participants = 50
        let comments = 50
        let teamComments = 50
        
        ChallengeCollectionRequest(entityType: entityType, entityId: entityId, gravityBoard: gravityBoard, participants: participants, comments: comments, teamComments: teamComments, filters: challengesType?.asFilter).request({ [weak self] (request, error) in
            
            guard let strongSelf = self,
                let request = request else {
                    failure()
                    return
            }
            
            let task = NSURLSessionTask.JSONTask(strongSelf.session, request: request, success: { [weak strongSelf] (JSON, response) in
                
                guard let strongSelf = strongSelf else { return }
                
                strongSelf.fetchTask = nil
                let results = CollectionDeserializer.parse(collectionJSONResponse: JSON, forResource: Challenge.self)
                strongSelf.challenges = results.collection
                success()
                
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
    
    func fetch(challenge: Challenge, user: User, success: (challenge: Challenge) -> Void, failure: () -> Void) {
        
        let gravityBoard = 3
        let participants = 50
        let comments = 50
        let teamComments = 50
        
        ChallengeRequest(challenge: challenge, userId: user.identifier, gravityBoard: gravityBoard, participants: participants, comments: comments, teamComments: teamComments).request({ [weak self] (request, error) in
            
            guard let strongSelf = self,
                let request = request else {
                    failure()
                    return
            }
            
            let task = NSURLSessionTask.JSONTask(strongSelf.session, request: request, success: { [weak strongSelf] (JSON, response) in
                
                guard let strongSelf = strongSelf,
                    let challengeDictionary = JSON as? NSDictionary,
                    let updatedChallenge = Challenge(dictionary: challengeDictionary) else {
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