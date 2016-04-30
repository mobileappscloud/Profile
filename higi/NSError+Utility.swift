//
//  NSError+Utility.swift
//  higi
//
//  Created by Remy Panicker on 4/29/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension NSError {
    
    convenience init(sender: String, code: Int, message: String?) {
        
        let className = String(sender)
        var domain = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleIdentifier") as! String
        domain.appendContentsOf(className)
        
        var userInfo: [String : String] = [:]
        if let message = message {
            userInfo["message"] = message
        }

        self.init(domain: "", code: code, userInfo: userInfo)
    }
}
