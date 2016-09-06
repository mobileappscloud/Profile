//
//  CommunitiesNetworkController.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 9/2/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct CommunitiesNetworkController { }

// MARK: - Subscriptions
extension CommunitiesNetworkController {
    static func updateSubscriptionFor(community community: Community, subscribeAction: CommunitySubscribeRequest.SubscribeAction, user: User, session: NSURLSession = APIClient.sharedSession, success: (community: Community) -> Void, failure: (error: ErrorType) -> Void) {
        CommunitySubscribeRequest(subscribeAction: subscribeAction, communityId: community.identifier, userId: user.identifier).request({(request, error) in
            guard let request = request else {
                return failure(error: error ?? Error.authentication)
            }
            let task = NSURLSessionTask.JSONTask(session, request: request, success: {(JSON, response) in
                fetch(community: community, success: success, failure: failure)
            }, failure: { (error, response) in
                failure(error: error ?? Error.unknown)
            })
            task.resume()
        })
    }
    
    static func fetch(community community: Community, session: NSURLSession = APIClient.sharedSession, success: (community: Community) -> Void, failure: (error: ErrorType) -> Void) {
        CommunityRequest(communityId: community.identifier).request({(request, error) in
            guard let request = request else {
                return failure(error: error ?? Error.unknown)
            }
            let task = NSURLSessionTask.JSONTask(session, request: request, success: {(JSON, response) in
                guard let community = ResourceDeserializer.parse(JSON, resource: Community.self) else {
                    return failure(error: Error.parsing)
                }
                success(community: community)
            }, failure: {(error, response) in
                failure(error: error ?? Error.unknown)
            })
            task.resume()
        })
    }
}

// MARK: - Errors
extension CommunitiesNetworkController {
    enum Error: ErrorType {
        case unknown
        case authentication
        case parsing
    }
}