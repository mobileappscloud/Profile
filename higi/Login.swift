//
//  LoginTask.swift
//  higi
//
//  Created by Remy Panicker on 3/28/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class Login {}

extension Login: HigiAPIRequest {
    
    class func request(email: String, password: String) -> NSURLRequest? {
        
        let relativePath = "/authentication/login"
        
        guard let mutableRequest = request(relativePath, parameters: nil, method: HTTPMethod.POST)?.mutableCopy() as? NSMutableURLRequest else { return nil }
                
        let encodedValueData = "\(email):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
        let encodedCredentials = encodedValueData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        mutableRequest.addValue("Basic \(encodedCredentials)", forHTTPHeaderField: HigiAPIClient.HTTPHeaderName.authorization)
        
        return mutableRequest.copy() as? NSURLRequest
    }
}
