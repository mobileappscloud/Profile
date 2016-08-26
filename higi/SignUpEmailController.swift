//
//  SignUpEmailController.swift
//  higi
//
//  Created by Remy Panicker on 5/3/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class SignUpEmailController {
    
    private lazy var session: NSURLSession = APIClient.sharedSession
    
    private lazy var authenticationNetworkController = AuthenticationNetworkController()
    
    private lazy var termsAndPrivacyNetworkController = TermsAndPrivacyNetworkController()
}

extension SignUpEmailController {

    func createUser(email: String, password: String, termsFileName: String, privacyFileName: String, success: (user: User) -> (), failure: (error: NSError?) -> ()) {
        authenticationNetworkController.createUser(email, password: password, termsFileName: termsFileName, privacyFileName: privacyFileName, success: success, failure: failure)
    }
}

extension SignUpEmailController {
    
    func fetchTermsAndPrivacyInfo(success: (termsFileName: String, privacyFileName: String) -> Void, failure: (error: NSError?) -> Void) {
        termsAndPrivacyNetworkController.fetchTermsAndPrivacyInfo(success, failure: failure)
    }
}
