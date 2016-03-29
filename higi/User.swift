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
    let dateOfBirth: NSDate
    let hasPhoto: Bool
    
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

    init(identifier: String, email: String, dateOfBirth: NSDate, hasPhoto: Bool) {
        self.identifier = identifier
        self.email = email
        self.dateOfBirth = dateOfBirth
        self.hasPhoto = hasPhoto
    }
}

extension User {
    
    init?(dictionary: NSDictionary) {
        guard let identifier = dictionary["id"] as? String,
            let email = dictionary["email"] as? String,
            let dateOfBirthString = dictionary["dateOfBirth"] as? String,
            let dateOfBirth = NSDateFormatter.MMddyyyyDateFormatter.dateFromString(dateOfBirthString),
            let hasPhoto = dictionary["hasPhoto"] as? Bool else { return nil }
        
        self.init(identifier: identifier, email: email, dateOfBirth: dateOfBirth, hasPhoto: hasPhoto)
        
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
        self.postalCode = dictionary["zipCode"] as? String
        self.ISOCountryCode = dictionary["countryCode"] as? String
        
        if let termsDateString = dictionary["termsAgreedDate"] as? String,
            let agreedDate = NSDateFormatter.ISO8601DateFormatter.dateFromString(termsDateString),
            let termsFileName = dictionary["termsFileName"] as? String {
            self.terms = AgreementInfo(agreedDate: agreedDate, fileName: termsFileName)
        }
        
        if let privacyDateString = dictionary["termsAgreedDate"] as? String,
            let agreedDate = NSDateFormatter.ISO8601DateFormatter.dateFromString(privacyDateString),
            let privacyFileName = dictionary["termsFileName"] as? String {
            self.privacy = AgreementInfo(agreedDate: agreedDate, fileName: privacyFileName)
        }
    }
}
