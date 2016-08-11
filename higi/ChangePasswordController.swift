//
//  ChangePasswordController.swift
//  higi
//
//  Created by Remy Panicker on 6/21/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ChangePasswordController {
    
    private lazy var session = APIClient.sharedSession
    
    func update(currentPassword: String, newPassword: String, success: () -> Void, failure: () -> Void) {
        
        PasswordUpdateRequest(currentPassword: currentPassword, newPassword: newPassword).request({ [weak self] (request, error) in
            
            guard let strongSelf = self,
                let request = request else {
                    failure()
                    return
            }
            
            let task = NSURLSessionTask.JSONTask(strongSelf.session, request: request, success: { (_, _) in
                success()
            }, failure: { (_, _) in
                failure()
            })
            task.resume()
        })
    }
}
