//
//  ActivityNetworkController.swift
//  higi
//
//  Created by Remy Panicker on 9/8/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct ActivityNetworkController { }

// MARK: - Metric Overview

extension ActivityNetworkController {
    
    static func fetch(activitiesForUser user: User, withMetrics metrics: [Activity.Metric.Identifier], startDate: NSDate, endDate: NSDate, includeWatts: Bool, sortDescending: Bool, pageSize: Int, success: (activities: [Activity], paging: Paging?) -> Void, failure: (error: ErrorType) -> Void) {
        
        ActivityCollectionRequest(userId: user.identifier, metrics: metrics, startDate: startDate, endDate: endDate, includeWatts: includeWatts, sortDescending: sortDescending, pageSize: pageSize)
            .request({ (request, error) in
                guard let request = request else { return failure(error: error ?? Error.unknown) }
                
                let session = APIClient.sharedSession
                let task = NSURLSessionTask.JSONTask(session, request: request, success: { (JSON, response) in
                    
                    let result = CollectionDeserializer.parse(collectionJSONResponse: JSON, forResource: Activity.self)
                    success(activities: result.collection, paging: result.paging)
                    
                    }, failure: { (error, response) in
                        failure(error: error ?? Error.unknown)
                })
                task.resume()
            })
    }
}

// MARK: - Errors

extension ActivityNetworkController {
    
    enum Error: ErrorType {
        case unknown
        case authentication
        case parsing
    }
}
