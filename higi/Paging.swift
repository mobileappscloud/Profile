//
//  Paging.swift
//  higi
//
//  Created by Remy Panicker on 3/25/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

/// Model which represents pagination objects for fetching subsets of large collections while working with the higi API.
struct Paging {
    
    /// URL of current page in collection.
    let current: NSURL
    
    /// Page number the current result set represents with respect to all pages in collection.
    let pageNumber: Int
    
    /// Maximum number of results returned in each page.
    let pageSize: Int
    
    /// Number of results returned for current page.
    let total: Int
    
    
    /// URL of previous page in collection.
    var previous: NSURL?
    
    /// URL of next page in collection.
    var next: NSURL?
}

extension Paging {
    
    init?(dictionary: NSDictionary) {
        guard let currentURLString = dictionary["current"] as? String,
            let current = NSURL(string: currentURLString),
            let pageNumber = dictionary["pageNumber"] as? Int,
            let pageSize = dictionary["pageSize"] as? Int,
            let total = dictionary["total"] as? Int else { return nil }
        
        self.current = current
        self.pageNumber = pageNumber
        self.pageSize = pageSize
        self.total = total
        
        if let previousURLString = dictionary["previous"] as? String {
            self.previous = NSURL(string: previousURLString)
        }
        if let nextURLString = dictionary["next"] as? String {
            self.next = NSURL(string: nextURLString)
        }
    }
}
