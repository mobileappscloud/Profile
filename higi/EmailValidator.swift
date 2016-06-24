//
//  EmailValidator.swift
//  higi
//
//  Created by Remy Panicker on 5/3/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct EmailValidator {
    
    private static let errorMessageRequirements = NSLocalizedString("SIGN_UP_EMAIL_VIEW_EMAIL_TEXT_FIELD_PLACEHOLDER_REQUIREMENTS", comment: "Placeholder for email text field which indicates email requirements.")
    
    static func validate(email: String?) -> (success: Bool, message: String?) {
        
        guard let email = email else {
            return (false, errorMessageRequirements)
        }
        
        /// @internal: Permissive regular expression generated using **EmailAddressFinder** - [github](https://github.com/dhoerl/EmailAddressFinder)
        let regex = "^(?:(?:(?:[-A-Za-z0-9!#$%&'*+/=?^_`{|}~]+(?:\\.[-A-Za-z0-9!#$%&'*+/=?^_`{|}~]+)*)|(?:\"(?:(?:(?:(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+))\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:25[0-5])|(?:2[0-4][0-9])|(?:1[0-9][0-9])|(?:[1-9][0-9])|[0-9])\\.){3}(?:(?:25[0-5]))|(?:2[0-4][0-9])|(?:1[0-9][0-9])|(?:[1-9][0-9])|(?:[0-9]))|(?:(?:[!-Z^-~])*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))$"
        
        if (email.characters.count == 0 || email.rangeOfString(regex, options: NSStringCompareOptions.RegularExpressionSearch, range: nil, locale: nil) == nil) {
            return (false, errorMessageRequirements)
        } else {
            return (true, nil)
        }
    }
}
