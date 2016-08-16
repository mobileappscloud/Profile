//
//  Paging.swift
//  higi
//
//  Created by Remy Panicker on 3/25/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

/// Object which describes how to fetch subsets of large collections while working with the higi API.
struct Paging {
    
    // MARK: Required
    
    /// URL of current page in collection.
    let current: NSURL
    
    /// Page number the current result set represents with respect to all pages in collection.
    let pageNumber: Int
    
    /// Maximum number of results returned in each page. This property can be used to limit the number of results returned. Setting this property to 0 indicates no size limit and a request for the entire dataset.
    let pageSize: Int
    
    /// Number of results returned for current page.
    let total: Int
    
    // MARK: Optional
    
    /// URL of previous page in collection.
    let previous: NSURL?
    
    /// URL of next page in collection.
    let next: NSURL?
}

// MARK: - JSON

extension Paging: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let current = NSURL(responseObject: dictionary["current"]),
            let pageNumber = dictionary["pageNumber"] as? Int,
            let pageSize = dictionary["pageSize"] as? Int,
            let total = dictionary["total"] as? Int else { return nil }
        
        self.current = current
        self.pageNumber = pageNumber
        self.pageSize = pageSize
        self.total = total
        
        self.previous = NSURL(responseObject: dictionary["previous"])
        self.next = NSURL(responseObject: dictionary["next"])
    }
}
