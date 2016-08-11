//
//  TransformableString.swift
//  higi
//
//  Created by Remy Panicker on 6/23/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct TransformableString {
    
    let text: String
    
    let transforms: [TextTransform]
}

extension TransformableString: JSONDeserializable, JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let text = dictionary["text"] as? String else { return nil }
        
        var transforms: [TextTransform] = []
        if let transformsDicts = dictionary["transforms"] as? NSArray {
            for case let transformDict as NSDictionary in transformsDicts {
                if let transform = TextTransform(text: text, dictionary: transformDict) {
                    transforms.append(transform)
                }
            }
        }
        
        self.text = text
        self.transforms = transforms
    }
}
