//
//  AgreementInfo.swift
//  higi
//
//  Created by Remy Panicker on 3/23/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

/**
 *  Represents an agreement such as acceptance of terms of service or privacy policy.
 */
struct AgreementInfo {
    
    /// Name of the file of the agreement.
    let fileName: String
    
    /// Date the agreement was agreed to.
    let dateTime: NSDate
}

// MARK: - JSON

extension AgreementInfo: JSONInitializable {
    
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

extension AgreementInfo: JSONSerializable {
    
    func JSONDictionary() -> NSDictionary {
        let mutableDictionary = NSMutableDictionary()
        
        mutableDictionary["fileName"] = fileName
        mutableDictionary["agreedDatetime"] = NSDateFormatter.ISO8601DateFormatter.stringFromDate(dateTime)
        
        return mutableDictionary.copy() as! NSDictionary
    }
}
