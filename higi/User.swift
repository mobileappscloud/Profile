//
//  HigiUserNew.swift
//  higi
//
//  Created by Remy Panicker on 3/23/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation
import HealthKit

struct User {
    
    let identifier: String
    let email: String
    
    // This is a required attribute, but the API can return user objects where these properties are nil...
    var dateOfBirth: NSDate?
    
    var firstName: String?
    var lastName: String?
    
    var biologicalSex: HKBiologicalSex = .NotSet
    
    var height: HKQuantity?
    
    var street: String?
    var city: String?
    var state: String?
    var postalCode: String?
    var ISOCountryCode: String?
    
    var terms: AgreementInfo?
    var privacy: AgreementInfo?
    
    var photo: MediaAsset?
    
    // MARK: - Unused, but required
    
    var createDate: NSDate?
    // Optional attributes unused by client, but necessary to prevent overwriting existing values when updating a user
    
    
    // MARK: - Init

    init(identifier: String, email: String) {
        self.identifier = identifier
        self.email = email
    }
}

extension User: HigiAPIJSONDeserializer {
    
    init?(dictionary: NSDictionary) {
        guard let identifier = dictionary["id"] as? String,
            let email = dictionary["email"] as? String else {
                return nil
        }
        
        self.init(identifier: identifier, email: email)
        
        if let dateOfBirthString = dictionary["dateOfBirth"] as? String {
            self.dateOfBirth = NSDateFormatter.MMddyyyyDateFormatter.dateFromString(dateOfBirthString)
        }
        
        if let createDateString = dictionary["created"] as? String {
            self.createDate = NSDateFormatter.ISO8601DateFormatter.dateFromString(createDateString)
        }
        
        self.firstName = dictionary["firstName"] as? String
        self.lastName = dictionary["lastName"] as? String
        
        if let biologicalSexString = dictionary["gender"] as? String {
            if biologicalSexString == "m" {
                self.biologicalSex = .Male
            } else if biologicalSexString == "f" {
                self.biologicalSex = .Female
            }
        }
        
        if let height = dictionary["height"] as? Double {
            self.height = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: height)
        }
        
        self.street = dictionary["address"] as? String
        self.city = dictionary["city"] as? String
        self.state = dictionary["state"] as? String
        self.postalCode = dictionary["zip"] as? String
        self.ISOCountryCode = dictionary["countryCode"] as? String
        
        if let termsDictionary = dictionary["termsAgreed"] as? NSDictionary {
            self.terms = AgreementInfo(dictionary: termsDictionary)
        }
        
        if let privacyDictionary = dictionary["privacyAgreed"] as? NSDictionary {
            self.privacy = AgreementInfo(dictionary: privacyDictionary)
        }
        
        if let photoDictionary = dictionary["photo"] as? NSDictionary {
            self.photo = MediaAsset(dictionary: photoDictionary)
        }
    }
}

extension User: HigiAPIJSONSerializer {
    
    func JSONDictionary() -> NSDictionary {
        let mutableDictionary = NSMutableDictionary()
        
        mutableDictionary["id"] = identifier
        mutableDictionary["email"] = email
        mutableDictionary["dateOfBirth"] = (dateOfBirth != nil) ? NSDateFormatter.MMddyyyyDateFormatter.stringFromDate(dateOfBirth!) : NSNull()
        mutableDictionary["created"] = (createDate != nil) ? NSDateFormatter.MMddyyyyDateFormatter.stringFromDate(createDate!) : NSNull()
        
        mutableDictionary["firstName"] = firstName ?? NSNull()
        mutableDictionary["lastName"] = lastName  ?? NSNull()
        
        var sex: String?
        switch biologicalSex {
        case .Female:
            sex = "f"
        case .Male:
            sex = "m"
        case .NotSet:
            fallthrough
        case .Other:
            break
        }
        mutableDictionary["gender"] = sex  ?? NSNull()
        
        mutableDictionary["height"] = height?.doubleValueForUnit(HKUnit.meterUnit())  ?? NSNull()
        
        mutableDictionary["address"] = street ?? NSNull()
        mutableDictionary["city"] = city ?? NSNull()
        mutableDictionary["state"] = state ?? NSNull()
        mutableDictionary["zip"] = postalCode ?? NSNull()
        mutableDictionary["countryCode"] = ISOCountryCode ?? NSNull()
        
        mutableDictionary["termsAgreed"] = terms?.JSONDictionary() ?? NSNull()
        mutableDictionary["privacyAgreed"] = privacy?.JSONDictionary() ?? NSNull()
        
        // TODO: Add photo info?
        
        return mutableDictionary.copy() as! NSDictionary
    }
}
