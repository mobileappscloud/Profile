//
//  TextTransform.swift
//  higi
//
//  Created by Remy Panicker on 6/23/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

/**
 *  Represents a transform which can be applied to a substring.
 */
struct TextTransform {
    
    /// Type of transform to apply.
    let type: Type
    
    /// Range of the string which the transform applies to. [Summary of string range in Swift.](http://stackoverflow.com/a/35193481)
    let range: Range<String.Index>
    
    /// Optional URL for transforms which require a URI to perform an action.
    let URL: NSURL?
}

// MARK: Type

extension TextTransform {
    
    /**
     Type of text transform.
     
     - Hyperlink: Transform text to a clickable link.
     - Survey:    Transform text to handle a survey.
     - Bold:      Transform text with a bold font.
     - Italic:    Transform text with an italic font.
     */
    enum Type: APIString {
        case Hyperlink
        case Survey
        case Bold
        case Italic
    }
}

// MARK: - JSON

extension TextTransform: JSONDeserializable {
    
    init?(text: String, dictionary: NSDictionary) {
        guard let type = Type(rawJSONValue: dictionary["type"]),
            let beginIndex = dictionary["beginIndex"] as? Int,
            let endIndex = dictionary["endIndex"] as? Int
            else { return nil }
        
        self.type = type
        self.range = text.startIndex.advancedBy(beginIndex)...text.startIndex.advancedBy(endIndex)
        
        self.URL = NSURL(responseObject: dictionary["url"])
    }
}
