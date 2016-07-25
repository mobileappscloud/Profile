//
//  UserUpdateRequest.swift
//  higi
//
//  Created by Remy Panicker on 5/9/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct UserUpdateRequest {}

extension UserUpdateRequest: APIRequest {

    private static func request(user: User, parameters: NSDictionary, completion: APIRequestAuthenticatorCompletion) {
        guard let userDictionary = user.JSONDictionary().mutableCopy() as? NSMutableDictionary else {
            completion(request: nil, error: nil)
            return
        }
        
        for key in parameters.allKeys {
            guard let key = key as? String else { continue }
            userDictionary[key] = parameters[key]
        }
        guard let body = userDictionary.copy() as? NSDictionary else {
            completion(request: nil, error: nil)
            return
        }
        
        let relativePath = "/user/users/\(user.identifier)"
        let method = HTTPMethod.PUT
        
        authenticatedRequest(relativePath, parameters: nil, method: method, body: body, completion: completion)
    }
    
    static func request(user: User, termsFileName: String, privacyFileName: String, completion: APIRequestAuthenticatorCompletion) {
        
        let agreedDateTime = NSDate()
        let terms = AgreementInfo(fileName: termsFileName, dateTime: agreedDateTime)
        let privacy = AgreementInfo(fileName: privacyFileName, dateTime: agreedDateTime)
        
        let parameters = NSMutableDictionary()
        parameters["termsAgreed"] = terms.JSONDictionary()
        parameters["privacyAgreed"] = privacy.JSONDictionary()
        
        request(user, parameters: parameters, completion: completion)
    }
    
    static func request(user: User, firstName: String, lastName: String, completion: APIRequestAuthenticatorCompletion) {
        
        let parameters = NSMutableDictionary()
        parameters["firstName"] = firstName
        parameters["lastName"] = lastName
        
        request(user, parameters: parameters, completion: completion)
    }
    
    static func request(user: User, dateOfBirth: NSDate, completion: APIRequestAuthenticatorCompletion) {
        
        let parameters = NSMutableDictionary()
        parameters["dateOfBirth"] = NSDateFormatter.MMddyyyyDateFormatter.stringFromDate(dateOfBirth)
        
        request(user, parameters: parameters, completion: completion)
    }
}
