//
//  ChallengesController.swift
//  higi
//
//  Created by Remy Panicker on 5/16/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ChallengesController {
    
    private var challengeIds: [UniqueId] = []
    private let challengeRepository: UserDataRepository<Challenge>
    private(set) var challenges: [Challenge] {
        get {
            return challengeRepository.objects(forIds: challengeIds)
        }
        set {
            challengeRepository.add(objects: newValue)
            challengeIds = newValue.map({$0.identifier})
        }
    }
    
    private lazy var session: NSURLSession = APIClient.sharedSession
    
    private(set) var paging: Paging?
    
    private(set) var fetchTask: NSURLSessionTask?
    private var nextPagingTask: NSURLSessionDataTask?
    
    var pageSize = 0
    
    init(challengeRepository: UserDataRepository<Challenge>) {
        self.challengeRepository = challengeRepository
    }

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

//MARK: - Communities requests
extension ChallengesController {
    func updateSubscription(community: Community, subscribeAction: CommunitySubscribeRequest.SubscribeAction, user: User, success: (community: Community) -> Void, failure: (error: ErrorType) -> Void) {
        CommunitiesNetworkController.updateSubscriptionFor(community: community, subscribeAction: subscribeAction, user: user, session: session, success: success, failure: failure)
    }
    
    func fetch(community: Community, success: (community: Community) -> Void, failure: (error: ErrorType) -> Void) {
        CommunitiesNetworkController.fetch(community: community, session: session, success: success, failure: failure)
    }
}

//MARK: - Refresh

extension ChallengesController {
    func refreshChallenge(challenge: Challenge, success: () -> Void, failure: (error: ErrorType) -> Void) {
        ChallengesNetworkController.fetch(challenge: challenge, session: session, success: { (challenge) in
            //TODO: Peter Ryszkiewicz: add the updated challenge to the data repository
            success()
        }, failure: failure)
    }
}

// MARK: - Errors
extension ChallengesController {
    enum Error: ErrorType {
        case unknown
        case authenticationError
        case challengeCollectionRetrievalError
        case parsingError
        case challengeRetrievalError
    }
}

// MARK: - Ordering
extension ChallengesController {
    static func sortChallenges(challenges: [Challenge]) -> [Challenge] {
        // Priorities talked about with Andrew Campbell
        func priority(challenge: Challenge) -> Int {
            switch challenge.userState {
                case .tabulatingResults: return 0
                case .challengeComplete: return 1
                case .cancelled: return 2
                case .joinedAndUnderway: return 3
                case .unjoinedAndUnderway: return 4
                case .joinedAndNotUnderway: return 5
                case .unjoinedAndNotUnderway: return 6
            }
        }
        func ordering(challenge1: Challenge, challenge2: Challenge) -> Bool {
            return priority(challenge1) < priority(challenge2)
        }
        return challenges.sort(ordering)
    }
}
