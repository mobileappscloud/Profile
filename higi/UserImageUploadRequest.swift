//
//  UserImageUploadRequest.swift
//  higi
//
//  Created by Remy Panicker on 5/19/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class UserImageUploadRequest: ProtectedAPIRequest {

    let userId: String
    let imageData: NSData
    
    required init(userId: String, imageData: NSData) {
        self.userId = userId
        self.imageData = imageData
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        
        let relativePath = "/user/users/\(userId)/photo"
        let method = HTTPMethod.POST
        
        authenticatedRequest(relativePath, parameters: [:], method: method, completion: { [weak self] (request, error) in
            
            guard let strongSelf = self,
                mutableRequest = request?.mutableCopy() as? NSMutableURLRequest else {
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
            
            body.appendData(strongSelf.imageData)
            body.appendString("\r\n")
            
            body.appendString("--\(boundary)--\r\n")
            
            mutableRequest.HTTPBody = body
            
            let contentType = "multipart/form-data; boundary=\(boundary)"
            mutableRequest.addValue(contentType, forHTTPHeaderField: HTTPHeader.name.contentType)
            
            mutableRequest.setValue("\(body.length)", forHTTPHeaderField:"Content-Length")
            
            completion(request: mutableRequest, error: nil)
        })
    }
}
