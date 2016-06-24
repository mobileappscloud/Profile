//
//  UserUpdateRequest.swift
//  higi
//
//  Created by Remy Panicker on 5/9/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct UserUpdateRequest {}

extension UserUpdateRequest: HigiAPIRequest {

    private static func request(user: User, parameters: NSDictionary, completion: HigiAPIRequestAuthenticatorCompletion) {
        guard let userDictionary = user.JSONDictionary().mutableCopy() as? NSMutableDictionary else {
            completion(request: nil, error: nil)
            return
        }
        
        for key in parameters.allKeys {
            guard let key = key as? String else { continue }
            userDictionary[key] = parameters[key]
        }
        let JSONBody = userDictionary.copy() as! NSDictionary
        
        let relativePath = "/user/users/\(user.identifier)"
        let method = HTTPMethod.PUT
        
        authenticatedRequest(relativePath, parameters: nil, method: method, completion: { (request, error) in
            
            if let request = request {
                if let mutableRequest = request.mutableCopy() as? NSMutableURLRequest {
                    
                    do {
                        mutableRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(JSONBody, options: [])
                        mutableRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                        
                        let fullRequest = mutableRequest.copy() as! NSURLRequest
                        completion(request: fullRequest, error: nil)
                    } catch {
                        completion(request: nil, error: nil)
                    }
                    
                } else {
                    completion(request: nil, error: nil)
                }
            } else {
                completion(request: nil, error: error)
            }
        })
    }
    
    static func request(user: User, termsFileName: String, privacyFileName: String, completion: HigiAPIRequestAuthenticatorCompletion) {
        
        let agreedDateTime = NSDate()
        let terms = AgreementInfo(fileName: termsFileName, dateTime: agreedDateTime)
        let privacy = AgreementInfo(fileName: privacyFileName, dateTime: agreedDateTime)
        
        let parameters = NSMutableDictionary()
        parameters["termsAgreed"] = terms.JSONDictionary()
        parameters["privacyAgreed"] = privacy.JSONDictionary()
        
        request(user, parameters: parameters, completion: completion)
    }
    
    static func request(user: User, firstName: String, lastName: String, completion: HigiAPIRequestAuthenticatorCompletion) {
        
        let parameters = NSMutableDictionary()
        parameters["firstName"] = firstName
        parameters["lastName"] = lastName
        
        request(user, parameters: parameters, completion: completion)
    }
    
    static func request(user: User, dateOfBirth: NSDate, completion: HigiAPIRequestAuthenticatorCompletion) {
        
        let parameters = NSMutableDictionary()
        parameters["dateOfBirth"] = NSDateFormatter.MMddyyyyDateFormatter.stringFromDate(dateOfBirth)
        
        request(user, parameters: parameters, completion: completion)
    }
}
