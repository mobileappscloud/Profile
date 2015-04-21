//
//  PulseArticle.swift
//  higi
//
//  Created by Dan Harms on 6/17/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class PulseArticle {
    
    var articleId: Int;
    
    var title, excerpt, imageUrl, permalink: NSString;
 
    init(dictionary: NSDictionary) {
        articleId = dictionary["id"] as! Int;
        title = (dictionary["title"] as! NSString).stringByConvertingHTMLToPlainText();
        excerpt = (dictionary["excerpt"] as! NSString).stringByConvertingHTMLToPlainText();
        imageUrl = dictionary["biggerImageUrl"] as! NSString;
        permalink = dictionary["permalink"] as! NSString;
    }
    
}