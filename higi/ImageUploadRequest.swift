//
//  ImageUploadRequest.swift
//  higi
//
//  Created by Remy Panicker on 5/19/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct ImageUploadRequest {}

extension ImageUploadRequest: APIRequest {
    
    static func request(user: User, imageData: NSData, completion: APIRequestAuthenticatorCompletion) {
        
        let relativePath = "/user/users/\(user.identifier)/photo"
        let method = HTTPMethod.POST
        
        authenticatedRequest(relativePath, parameters: [:], method: method, completion: { (request, error) in
            
            guard let mutableRequest = request?.mutableCopy() as? NSMutableURLRequest else {
                completion(request: nil, error: error)
                return
            }
            
            let boundary = "com.higi.main.\(NSUUID().UUIDString)"
            
            // change these params so that they're not hardcoded
            let name = "image"
            let fileExtension = "jpeg"
            let filename = "\(name).\(fileExtension)"
            let mimetype = "image/\(fileExtension)"
            
            let body = NSMutableData()
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n")
            
            body.appendString("Content-Type: \(mimetype)\r\n\r\n")
            
            body.appendData(imageData)
            body.appendString("\r\n")
            
            body.appendString("--\(boundary)--\r\n")
            
            mutableRequest.HTTPBody = body
            
            let contentType = "multipart/form-data; boundary=\(boundary)"
            mutableRequest.addValue(contentType, forHTTPHeaderField: HTTPHeader.name.contentType)
            
            mutableRequest.setValue("\(body.length)", forHTTPHeaderField:"Content-Length")
            
            completion(request: mutableRequest, error: nil)
        })
    }
    
    static func request(user: User, centerX: Int, centerY: Int, scale: CGFloat, completion: APIRequestAuthenticatorCompletion) {
        
        let relativePath = "/user/users/\(user.identifier)/photoPosition"
        let method = HTTPMethod.POST
        let body = [
            "centerX" : centerX,
            "centerY" : centerY,
            "scale" : scale
        ]
        
        authenticatedRequest(relativePath, parameters: [:], method: method, body: body, completion: completion)
    }
}
