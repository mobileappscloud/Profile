//
//  ActivityCollectionRequest.swift
//  higi
//
//  Created by Remy Panicker on 9/8/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ActivityCollectionRequest: ProtectedAPIRequest {
    
    let userId: String
    
    let metrics: [Activity.Metric.Identifier]
    
    let startDate: NSDate
    
    let endDate: NSDate
    
    let includeWatts: Bool
    
    let sortDescending: Bool
    
    let pageSize: Int
    
    // MARK: Init
    
    required init(userId: String, metrics: [Activity.Metric.Identifier], startDate: NSDate, endDate: NSDate, includeWatts: Bool, sortDescending: Bool, pageSize: Int) {
        self.userId = userId
        self.metrics = metrics
        self.startDate = startDate
        self.endDate = endDate
        self.includeWatts = includeWatts
        self.sortDescending = sortDescending
        self.pageSize = pageSize
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        
        let relativePath = "/activity/users/\(userId)/activities"
        
        let parameters = [
            "metrics" : metrics.map({$0.rawValue}).joinWithSeparator(","),
            "startDate" : NSDateFormatter.ISO8601DateFormatter.stringFromDate(startDate),
            "endDate" : NSDateFormatter.ISO8601DateFormatter.stringFromDate(endDate),
            "includeWatts" : String(includeWatts),
            "sort" : sortDescending ? "timestampDesc" : "timestampAsc",
            "pageSize" : "\(pageSize)"
        ]
        
        authenticatedRequest(relativePath, parameters: parameters, completion: completion)
    }
}
