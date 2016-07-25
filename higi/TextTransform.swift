//
//  TextTransform.swift
//  higi
//
//  Created by Remy Panicker on 6/23/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct TextTransform {
    
    enum Type: String {
        case Hyperlink
        case Survey
        case Bold
        case Italic
    }
    
    let type: Type
    
    /// [Summary of string range in Swift.](http://stackoverflow.com/a/35193481)
    let range: Range<String.Index>
    
    let URL: NSURL?
}

extension TextTransform: JSONDeserializable {
    
    init?(text: String, dictionary: NSDictionary) {
        guard let typeString = dictionary["Type"] as? String,
            let type = Type(rawValue: typeString),
            let beginIndex = dictionary["BeginIndex"] as? Int,
            let endIndex = dictionary["EndIndex"] as? Int
            else { return nil }
        
        self.type = type
        self.range = text.startIndex.advancedBy(beginIndex)...text.startIndex.advancedBy(endIndex)
        
        if let urlString = dictionary["Url"] as? String, let url = NSURL(string: urlString) {
            self.URL = url
        } else {
            self.URL = nil
        }
    }
}
