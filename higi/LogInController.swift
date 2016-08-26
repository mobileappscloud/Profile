//
//  LogInController.swift
//  higi
//
//  Created by Remy Panicker on 5/10/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class LogInController {
    
    private lazy var authenticationNetworkController = AuthenticationNetworkController()
}

extension LogInController {
    
    func authenticate(email: String, password: String, success: (user: User) -> (), failure: (error: NSError?) -> ()) {
        authenticationNetworkController.authenticate(email, password: password, success: success, failure: failure)
    }
}
