//
//  UserCreateRequest.swift
//  higi
//
//  Created by Remy Panicker on 5/3/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class UserCreateRequest: UnprotectedAPIRequest {

    let email: String
    
    let password: String
    
    let termsFileName: String
    
    let privacyFileName: String
    
    
    required init(email: String, password: String, termsFileName: String, privacyFileName: String) {
        self.email = email
        self.password = password
        self.termsFileName = termsFileName
        self.privacyFileName = privacyFileName
    }
    
    func request() -> NSURLRequest? {
        
        let relativePath = "/authentication/users"
        let method = HTTPMethod.POST
        
        let agreedDateTime = NSDate()
        let terms = AgreementInfo(fileName: termsFileName, dateTime: agreedDateTime)
        let privacy = AgreementInfo(fileName: privacyFileName, dateTime: agreedDateTime)
        
        let body = [
            "email" : email,
            "password" : password,
            "termsAgreed" : terms.JSONDictionary(),
            "privacyAgreed" : privacy.JSONDictionary()
        ]
        
        return request(relativePath, parameters: nil, method: method, body: body)
    }
}
