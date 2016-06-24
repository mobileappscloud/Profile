//
//  Media.swift
//  higi
//
//  Created by Remy Panicker on 4/4/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

struct Media {
    
    let URI: NSURL
    let contentType: String
}

extension Media: HigiAPIJSONDeserializer {
    
    init?(dictionary: NSDictionary) {
        guard let URIString = dictionary["uri"] as? String,
            let URI = NSURL(string: URIString),
            let contentType = dictionary["contentType"] as? String else { return nil }
        
        self.URI = URI
        self.contentType = contentType
    }
}
