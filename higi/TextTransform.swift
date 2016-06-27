//
//  TextTransform.swift
//  higi
//
//  Created by Remy Panicker on 6/23/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct TextTransform {
    
    enum Type {
        case Hyperlink
        case Survey
        case Bold
        case Italic
    }
    
    let type: Type
    
    let range: Range<String.Index>
    
    let URL: NSURL
}
