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
    private var nextPagingTask: NSURLSessionDataTask?
    
    var pageSize = 0

    deinit {
        fetchTask?.cancel()
        nextPagingTask?.cancel()
    }
}

// MARK: - Enums
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
    
    func fetch(forEntityType entityType: ChallengeCollectionRequest.EntityType, entityId: String, challengesType: ChallengeType? = nil, success: () -> Void, failure: (error: ErrorType) -> Void) {
        let gravityBoard = 3
        let participants = 50
        let comments = 50
        let teamComments = 50
        
        ChallengeCollectionRequest(entityType: entityType, entityId: entityId, gravityBoard: gravityBoard, participants: participants, comments: comments, teamComments: teamComments, filters: challengesType?.asFilter, pageSize: pageSize).request({ [weak self] (request, error) in
            
            guard let strongSelf = self,
                let request = request else {
                    failure(error: error ?? Error.authenticationError)
                    return
            }
            
            let task = NSURLSessionTask.JSONTask(strongSelf.session, request: request, success: { [weak strongSelf] (JSON, response) in
                
                guard let strongSelf = strongSelf else { return }
                
                strongSelf.fetchTask = nil
                let results = CollectionDeserializer.parse(collectionJSONResponse: JSON, forResource: Challenge.self)
                strongSelf.challenges = ChallengesController.sortChallenges(results.collection)
                strongSelf.paging = results.paging
                success()
                
            }, failure: { [weak strongSelf] (error, response) in
                guard let strongSelf = strongSelf else { return }
                strongSelf.fetchTask = nil
                failure(error: error ?? Error.challengeCollectionRetrievalError)
            })
            task.resume()
            strongSelf.fetchTask = task
        })
    }
}

// MARK: - Fetch next pages
extension ChallengesController {
    func fetchNext(success: () -> Void, failure: (error: ErrorType) -> Void) {
        if nextPagingTask?.state == .Running { return }
        
        guard let URL = paging?.next else { return success() }
        
        PagingRequest(URL: URL).request({ [weak self] (request, error) in
            
            guard let request = request else {
                failure(error: error ?? Error.authenticationError)
                return
            }
            
            self?.performNextFetch(request, success: success, failure: failure)
        })
    }
    
    private func performNextFetch(request: NSURLRequest, success: () -> Void, failure: (error: ErrorType) -> Void) {
        
        nextPagingTask = NSURLSessionTask.JSONTask(session, request: request, success: { [weak self] (JSON, response) in
            
            guard let strongSelf = self else { return }
            
            let result = CollectionDeserializer.parse(collectionJSONResponse: JSON, forResource: Challenge.self)
            strongSelf.challenges = ChallengesController.sortChallenges(strongSelf.challenges + result.collection)
            strongSelf.paging = result.paging
            strongSelf.nextPagingTask = nil
            success()
            
        }, failure: { [weak self] (error, response) in
            guard let strongSelf = self else { return }
            
            strongSelf.nextPagingTask = nil
            failure(error: error ?? Error.challengeCollectionRetrievalError)
        })
        
        nextPagingTask?.resume()
    }
}

// MARK: - Errors
extension ChallengesController {
    enum Error: ErrorType {
        case unknown
        case authenticationError
        case challengeCollectionRetrievalError
        case parsingError
    }
}

// MARK: - Errors
extension ChallengesController {
    static func sortChallenges(challenges: [Challenge]) -> [Challenge] {
        func priority(challenge: Challenge) -> Int {
            switch challenge.userState {
                case .joinedAndUnderway: return 0
                case .unjoinedAndUnderway: return 1
                case .joinedAndNotUnderway: return 2
                case .unjoinedAndNotUnderway: return 3
                case .tabulatingResults: return 5
                case .challengeComplete: return 4
                case .cancelled: return 6
            }
        }
        func ordering(challenge1: Challenge, challenge2: Challenge) -> Bool {
            return priority(challenge1) < priority(challenge2)
        }
        return challenges.sort(ordering)
    }
}
