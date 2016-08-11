//
//  LogInRequest.swift
//  higi
//
//  Created by Remy Panicker on 3/28/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class LogInRequest: UnprotectedAPIRequest {
    
    let email: String
    let password: String
    
    required init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    func request() -> NSURLRequest? {
        let relativePath = "/authentication/login"
        let method = HTTPMethod.POST
        
        guard let mutableRequest = request(relativePath, parameters: nil, method: method, body: nil)?.mutableCopy() as? NSMutableURLRequest else { return nil }
        
        mutableRequest.addValue(HTTPHeader.value.applicationJSON, forHTTPHeaderField: HTTPHeader.name.contentType)
        
        let encodedValueData = "\(email):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
        let encodedCredentials = encodedValueData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        mutableRequest.addValue("Basic \(encodedCredentials)", forHTTPHeaderField: APIClient.HTTPHeaderName.authorization)
        
        return mutableRequest.copy() as? NSURLRequest
    }
}
