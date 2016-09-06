//
//  ChallengeDetailController.swift
//  higi
//
//  Created by Remy Panicker on 8/18/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

/// Responsible for data interaction related to challenge details.
final class ChallengeDetailController {
    
    private let challengeRepository: UserDataRepository<Challenge>
    private let communityRepository: UserDataRepository<Community>
    private let challengeId: UniqueId
    private(set) var challenge: Challenge {
        get {
            return challengeRepository.object(forId: challengeId)!
        }
        set {
            challengeRepository.add(object: newValue)
        }
    }

    private lazy var session: NSURLSession = APIClient.sharedSession

    // MARK: Init
    
    required init(challenge: Challenge, challengeRepository: UserDataRepository<Challenge>, communityRepository: UserDataRepository<Community>) {
        self.challengeRepository = challengeRepository
        self.communityRepository = communityRepository
        challengeId = challenge.identifier
        self.challenge = challenge
    }
}

// MARK: - Joining a challenge
extension ChallengeDetailController {
    func join(challenge challenge: Challenge, user: User, success: () -> Void, failure: (error: ErrorType) -> Void) {
        ChallengesNetworkController.join(challenge: challenge, user: user, session: session, success: {
            [weak self] (challenge) in
            self?.challenge = challenge
            success()
        }, failure: failure)
    }
}

// MARK: - Joining a community before joining the challenge

extension ChallengeDetailController {
    
    func updateSubscriptionFor(community community: Community, subscribeAction: CommunitySubscribeRequest.SubscribeAction, user: User, success: (community: Community) -> Void, failure: (error: ErrorType) -> Void) {
        CommunitiesNetworkController.updateSubscriptionFor(community: community, subscribeAction: subscribeAction, user: user, session: session, success: {
            [weak self]
            community in
            self?.communityRepository.add(object: community)
            success(community: community)
        }, failure: failure)
    }
    
    func fetch(community: Community, success: (community: Community) -> Void, failure: (error: ErrorType) -> Void) {
        CommunitiesNetworkController.fetch(community: community, session: session, success: {
            [weak self]
            community in
            self?.communityRepository.add(object: community)
            success(community: community)
        }, failure: failure)
    }
}

// MARK: - Fetching a challenge
extension ChallengeDetailController {
    func refreshChallenge(success success: () -> Void, failure: (error: ErrorType) -> Void) {
        ChallengesNetworkController.fetch(challenge: challenge, session: session, success: {
            [weak self] (challenge) in
            self?.challenge = challenge
            success()
        }, failure: failure)
    }
}

// MARK: - Errors
extension ChallengeDetailController {
    enum Error: ErrorType {
        case unknown
        case noJoinUrl
        case authentication
        case parsing
        case challengeRetrieval
    }
}