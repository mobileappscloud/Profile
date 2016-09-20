//
//  UserTermsUpdateRequest.swift
//  higi
//
//  Created by Remy Panicker on 8/8/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class UserTermsUpdateRequest: ProtectedAPIRequest {
    
    let user: User
    let termsFileName: String
    let privacyFileName: String
    
    required init(user: User, termsFileName: String, privacyFileName: String) {
        self.user = user
        self.termsFileName = termsFileName
        self.privacyFileName = privacyFileName
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        
        let effectiveDatetime = NSDate()
        let terms = AgreementInfo(fileName: termsFileName, dateTime: effectiveDatetime)
        let privacy = AgreementInfo(fileName: privacyFileName, dateTime: effectiveDatetime)
        
        let parameters = NSMutableDictionary()
        parameters["termsAgreed"] = terms.JSONDictionary()
        parameters["privacyAgreed"] = privacy.JSONDictionary()
        
        UserUpdateRequest(user: user, parameters: parameters).request(completion)
    }
}
