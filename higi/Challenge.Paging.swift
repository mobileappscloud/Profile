//
//  Challenge.Paging.swift
//  higi
//
//  Created by Remy Panicker on 8/12/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension Challenge {
    
    /**
     *  Legacy paging object used for traversing through large collections.
     */
    struct Paging {
        
        /// Current 'page' represented by the data set.
        let page: Int
        
        /// Total number of object in the collection.
        let totalCount: Int
        
        /// Number of objects each 'page' is limited to returning.
        let limit: Int
    }
}

// MARK: - JSON

extension Challenge.Paging: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let page = dictionary["page"] as? Int,
            let totalCount = dictionary["totalCount"] as? Int,
            let limit = dictionary["limit"] as? Int else { return nil }
        
        self.page = page
        self.totalCount = totalCount
        self.limit = limit
    }
}
