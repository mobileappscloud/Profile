//
//  UserImagePositionUploadRequest.swift
//  higi
//
//  Created by Remy Panicker on 8/8/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class UserImagePositionUploadRequest: ProtectedAPIRequest {
    
    let userId: String
    let centerX: Int
    let centerY: Int
    let scale: CGFloat
    
    required init(userId: String, centerX: Int, centerY: Int, scale: CGFloat) {
        self.userId = userId
        self.centerX = centerX
        self.centerY = centerY
        self.scale = scale
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        
        let relativePath = "/user/users/\(userId)/photoPosition"
        let method = HTTPMethod.POST
        let body = [
            "centerX" : centerX,
            "centerY" : centerY,
            "scale" : scale
        ]
        
        authenticatedRequest(relativePath, parameters: [:], method: method, body: body, completion: completion)
    }
}
