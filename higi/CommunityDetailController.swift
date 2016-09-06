//
//  CommunityDetailController.swift
//  higi
//
//  Created by Remy Panicker on 6/9/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class CommunityDetailController {
    
    private let communityRepository: UserDataRepository<Community>
    private let communityId: UniqueId
    private(set) var community: Community {
        get {
            return communityRepository.object(forId: communityId)!
        }
        set {
            communityRepository.add(object: newValue)
        }
    }
    private lazy var session: NSURLSession = APIClient.sharedSession
    
    init(community: Community, communityRepository: UserDataRepository<Community>) {
        self.communityRepository = communityRepository
        communityId = community.identifier
        self.community = community
    }
}

extension CommunityDetailController {
    
    func updateSubscription(community: Community, subscribeAction: CommunitySubscribeRequest.SubscribeAction, user: User, success: (community: Community) -> Void, failure: (error: ErrorType) -> Void) {
        CommunitiesNetworkController.updateSubscriptionFor(community: community, subscribeAction: subscribeAction, user: user, session: session, success: {
            [weak self] community in
            self?.community = community
            success(community: community)
        }, failure: failure)
    }
    
    func fetch(community: Community, success: (community: Community) -> Void, failure: (error: ErrorType) -> Void) {
        CommunitiesNetworkController.fetch(community: community, session: session, success: {
            [weak self] community in
            self?.community = community
            success(community: community)
        }, failure: failure)
    }
}
