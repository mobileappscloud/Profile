//
//  CustomFormatter.swift
//  higi
//
//  Created by Dan Harms on 6/25/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class CustomFormatter : NSFormatter {
    
    var dateFormatter: NSDateFormatter;
    
    init(dateFormatter: NSDateFormatter) {
        self.dateFormatter = dateFormatter;
        super.init();
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func stringForObjectValue(obj: AnyObject) -> String? {
        var date = NSDate(timeIntervalSince1970: obj as! Double);
        return dateFormatter.stringFromDate(date);
    }
    
}