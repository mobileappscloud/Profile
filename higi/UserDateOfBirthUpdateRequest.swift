//
//  UserDateOfBirthUpdateRequest.swift
//  higi
//
//  Created by Remy Panicker on 8/8/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class UserDateOfBirthUpdateRequest: ProtectedAPIRequest {
    
    let user: User
    let dateOfBirth: NSDate
    
    required init(user: User, dateOfBirth: NSDate) {
        self.user = user
        self.dateOfBirth = dateOfBirth
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        
        let parameters = NSMutableDictionary()
        parameters["dateOfBirth"] = NSDateFormatter.YYYYMMddDateFormatter.stringFromDate(dateOfBirth)
        
        UserUpdateRequest(user: user, parameters: parameters).request(completion)
    }
}
