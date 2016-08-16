//
//  TransformableString.swift
//  higi
//
//  Created by Remy Panicker on 6/23/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

/**
 *  Represents a string which can have text transformations applied to it.
 */
struct TransformableString {
    
    /// Text value of the string.
    let text: String
    
    /// Collection of transforms to apply to the string.
    let transforms: [TextTransform]
}

// MARK: - JSON

extension TransformableString: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let text = dictionary["text"] as? String else { return nil }
        
        var transforms: [TextTransform] = []
        if let transformsDicts = dictionary["transforms"] as? [NSDictionary] {
            for transformDict in transformsDicts {
                if let transform = TextTransform(text: text, dictionary: transformDict) {
                    transforms.append(transform)
                }
            }
        }
        
        self.text = text
        self.transforms = transforms
    }
}
