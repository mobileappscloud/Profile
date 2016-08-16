//
//  HigiUserNew.swift
//  higi
//
//  Created by Remy Panicker on 3/23/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import HealthKit

/**
 *  Represents a higi user.
 */
struct User: UniquelyIdentifiable {
    
    // MARK: Required
    
    /// Unique identifier.
    let identifier: String
    
    /// User's registered email address.
    let email: String
    
    // MARK: Optional
    
    // This is a required attribute, but the API can return user objects where these properties are nil...
    /// Date of birth.
    let dateOfBirth: NSDate?
    
    /// Given (first) name of the user.
    let firstName: String?
    
    /// Family (last) name of the user.
    let lastName: String?
    
    /// Biological sex of the user.
    let biologicalSex: HKBiologicalSex
    
    /// Height in meters.
    let height: HKQuantity?
    
    /// Street address
    let street: String?
    
    /// City
    let city: String?
    
    /// State/province
    let state: String?
    
    /// Postal code
    let postalCode: String?
    
    /// Country code represented in [ISO 3166](http://www.iso.org/iso/country_codes) format.
    let ISOCountryCode: String?
    
    /// Represents terms of service agreement info.
    let terms: AgreementInfo?
    
    /// Represents privacy policy agreement info.
    let privacy: AgreementInfo?
    
    /// Image media asset with a photo of the user.
    let photo: MediaAsset?
    
    // MARK: Init
    
    init(identifier: String, email: String, dateOfBirth: NSDate? = nil, firstName: String? = nil, lastName: String? = nil, biologicalSex: HKBiologicalSex = .NotSet, height: HKQuantity? = nil, street: String? = nil, city: String? = nil, state: String? = nil, postalCode: String? = nil, ISOCountryCode: String? = nil, terms: AgreementInfo? = nil, privacy: AgreementInfo? = nil, photo: MediaAsset? = nil) {
        self.identifier = identifier
        self.email = email
        
        self.dateOfBirth = dateOfBirth
        self.firstName = firstName
        self.lastName = lastName
        self.biologicalSex = biologicalSex
        self.height = height
        self.street = street
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.ISOCountryCode = ISOCountryCode
        self.terms = terms
        self.privacy = privacy
        self.photo = photo
    }
}

// MARK: - JSON

extension User: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let identifier = dictionary["id"] as? String,
            let email = dictionary["email"] as? String else {
                return nil
        }
        
        let dateOfBirth = NSDateFormatter.MMddyyyyDateFormatter.date(fromObject: dictionary["dateOfBirth"])
        let firstName = dictionary["firstName"] as? String
        let lastName = dictionary["lastName"] as? String
        
        var biologicalSex: HKBiologicalSex = .NotSet
        if let biologicalSexString = dictionary["gender"] as? String {
            if biologicalSexString == "m" {
                biologicalSex = .Male
            } else if biologicalSexString == "f" {
                biologicalSex = .Female
            }
        }
        
        let heightValue = dictionary["height"] as? Double ?? 0.0
        let height = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: heightValue)
        
        let street = dictionary["address"] as? String
        let city = dictionary["city"] as? String
        let state = dictionary["state"] as? String
        let postalCode = dictionary["zip"] as? String
        let ISOCountryCode = dictionary["countryCode"] as? String
        
        let terms = AgreementInfo(fromJSONObject: dictionary["termsAgreed"])
        let privacy = AgreementInfo(fromJSONObject: dictionary["privacyAgreed"])
        let photo = MediaAsset(fromJSONObject: dictionary["photo"])
        
        self.init(identifier: identifier, email: email, dateOfBirth: dateOfBirth, firstName: firstName, lastName: lastName, biologicalSex: biologicalSex, height: height, street: street, city: city, state: state, postalCode: postalCode, ISOCountryCode: ISOCountryCode, terms: terms, privacy: privacy, photo: photo)
    }
}

extension User: JSONSerializable {
    
    func JSONDictionary() -> NSDictionary {
        let mutableDictionary = NSMutableDictionary()
        
        mutableDictionary["id"] = identifier
        mutableDictionary["email"] = email
        mutableDictionary["dateOfBirth"] = (dateOfBirth != nil) ? NSDateFormatter.MMddyyyyDateFormatter.stringFromDate(dateOfBirth!) : NSNull()
        
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
