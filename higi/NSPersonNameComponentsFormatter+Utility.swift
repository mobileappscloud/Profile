//
//  NSPersonNameComponentsFormatter+Utility.swift
//  higi
//
//  Created by Remy Panicker on 6/30/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension NSPersonNameComponentsFormatter {
    
    @nonobjc static func localizedMediumStyle(withFirstName firstName: String?, lastName: String?) -> String? {
        let components = NSPersonNameComponents()
        components.givenName = firstName ?? ""
        components.familyName = lastName ?? ""
        
        return NSPersonNameComponentsFormatter.localizedStringFromPersonNameComponents(components, style: .Medium, options: NSPersonNameComponentsFormatterOptions())
    }
}
