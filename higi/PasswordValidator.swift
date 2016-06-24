//
//  PasswordValidator.swift
//  higi
//
//  Created by Remy Panicker on 5/3/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct PasswordValidator {
    
    static let errorMessageRequirements = NSLocalizedString("SIGN_UP_EMAIL_VIEW_PASSWORD_TEXT_FIELD_PLACEHOLDER_REQUIREMENTS", comment: "Placeholder for password text field if password does not meet minimum requirements.")
    
    static func validate(password: String?) -> (success: Bool, message: String?) {
        
        guard let password = password else {
            return (false, errorMessageRequirements)
        }
        
        if (password.characters.count < 6) {
            return (false, errorMessageRequirements)
        } else {
            return (true, nil)
        }
    }
}
