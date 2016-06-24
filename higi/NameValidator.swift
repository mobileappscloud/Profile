//
//  NameValidator.swift
//  higi
//
//  Created by Remy Panicker on 5/9/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct NameValidator {

    enum NameType {
        case First
        case Last
        
        func errorMessageRequirements() -> String {
            switch self {
            case First:
                return NSLocalizedString("SIGN_UP_NAME_VIEW_FIRST_NAME_TEXT_FIELD_PLACEHOLDER_REQUIREMENT", comment: "Placeholder for first name text field indicating name requirement.")
            case Last:
                return NSLocalizedString("SIGN_UP_NAME_VIEW_LAST_NAME_TEXT_FIELD_PLACEHOLDER_REQUIREMENT", comment: "Placeholder for last name text field indicating name requirement.")
            }
        }
    }
    
    static func validate(name: String?, type: NameType) -> (success: Bool, message: String?) {
        guard let name = name else {
            return (false, type.errorMessageRequirements())
        }
            
        if name.characters.count == 0 {
            return (false, type.errorMessageRequirements())
        }
        if name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count == 0 {
            return (false, type.errorMessageRequirements())
        }
        
        return (true, nil)
    }
    
}