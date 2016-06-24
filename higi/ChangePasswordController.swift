//
//  ChangePasswordController.swift
//  higi
//
//  Created by Remy Panicker on 6/21/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct ChangePasswordController {
    
    private let session = HigiAPIClient.session()
    
    func update(currentPassword: String, newPassword: String, success: () -> Void, failure: () -> Void) {
        
        PasswordUpdateRequest.request(currentPassword, newPassword: newPassword, completion: { (request, error) in
            
            guard let request = request else {
                failure()
                return
            }
            
            let task = NSURLSessionTask.JSONTask(self.session, request: request, success: { (_, _) in
                success()
            }, failure: { (_, _) in
                failure()
            })
            task.resume()
        })
    }
}
