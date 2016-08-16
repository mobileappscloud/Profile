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

extension MediaAsset: JSONDeserializable, JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let URIString = dictionary["uri"] as? String,
            let URI = NSURL(string: URIString),
            let contentType = dictionary["contentType"] as? String else { return nil }
        
        self.URI = URI
        self.contentType = contentType
    }
    
    init?(postDictionary dictionary: NSDictionary) {
        guard let URIString = dictionary["url"] as? String,
            let URI = NSURL(string: URIString),
            let fileExtension = dictionary["fileExtension"] as? String else { return nil }
        
        self.URI = URI
        let contentType = Utility.MIMEType(fileExtension)
        self.contentType = contentType ?? fileExtension
    }
    
    static func postDictionary(uri: String, fileExtension: String) -> NSDictionary {
        return [
            "url" : "\(uri)",
            "fileExtension" : "\(fileExtension)"
        ]
    }
    
    // MARK: Legacy Convenience
    
    init?(fromLegacyJSONObject JSON: AnyObject?, imageKey: String = "imageUrl") {
        guard let JSON = JSON as? NSDictionary,
            let imageDict = JSON[imageKey] as? NSDictionary,
            let imageURLString = imageDict["default"] as? String,
            let URI = NSURL(string: imageURLString) else { return nil }
        
        let fileExtension = imageURLString.componentsSeparatedByString(".").last ?? "png"
        let contentType = "image/\(fileExtension)"
        
        self.URI = URI
        self.contentType = contentType
    }
}

// MARK: - Convenience

extension MediaAsset {
    
    func sizedURI(width: Int, height: Int) -> NSURL {
        let scale = UIScreen.mainScreen().scale
        let scaledWidth = width * Int(scale)
        let scaledHeight = height * Int(scale)
        let urlString = URI.absoluteString + "?w=\(String(scaledWidth))&h=\(String(scaledHeight))"
        
        guard let assetURL = NSURL(string: urlString) else { fatalError() }
        
        return assetURL
    }
}
