//
//  Media.swift
//  higi
//
//  Created by Remy Panicker on 4/4/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

struct MediaAsset {
    
    let URI: NSURL
    
    /// Specifies the nature of the data in the body of an entity, by giving type and subtype identifiers
    let contentType: String
    
    init(URI: NSURL, contentType: String) {
        self.URI = URI
        self.contentType = contentType
    }
}

extension MediaAsset: HigiAPIJSONDeserializer {
    
    init?(dictionary: NSDictionary) {
        guard let URIString = dictionary["uri"] as? String,
            let URI = NSURL(string: URIString),
            let contentType = dictionary["contentType"] as? String else { return nil }
        
        self.URI = URI
        self.contentType = contentType
    }
    
    init?(postDictionary dictionary: NSDictionary) {
        guard let URIString = dictionary["Url"] as? String,
            let URI = NSURL(string: URIString),
            let fileExtension = dictionary["FileExtension"] as? String,
            let contentType = Utility.MIMEType(fileExtension) else { return nil }
        
        self.URI = URI
        self.contentType = contentType
    }
    
    static func postDictionary(uri: String, fileExtension: String) -> NSDictionary {
        return [
            "Url" : "\(uri)",
            "FileExtension" : "\(fileExtension)"
        ]
    }
}
