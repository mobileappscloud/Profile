//
//  AgreementInfo.swift
//  higi
//
//  Created by Remy Panicker on 3/23/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

struct AgreementInfo {
    
    let fileName: String
    let dateTime: NSDate
}

extension AgreementInfo: HigiAPIJSONDeserializer {
    
    init?(dictionary: NSDictionary) {
        guard let fileName = dictionary["fileName"] as? String,
            let dateTimeString = dictionary["agreedDatetime"] as? String,
            let dateTime = NSDateFormatter.ISO8601DateFormatter.dateFromString(dateTimeString) else {
                return nil
        }
        
        self.fileName = fileName
        self.dateTime = dateTime
    }
}

extension AgreementInfo: HigiAPIJSONSerializer {
    
    func JSONDictionary() -> NSDictionary {
        let mutableDictionary = NSMutableDictionary()
        
        mutableDictionary["fileName"] = fileName
        mutableDictionary["agreedDatetime"] = NSDateFormatter.ISO8601DateFormatter.stringFromDate(dateTime)
        
        return mutableDictionary.copy() as! NSDictionary
    }
}
