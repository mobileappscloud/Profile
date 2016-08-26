//
//  TermsAndPrivacyNetworkController.swift
//  higi
//
//  Created by Remy Panicker on 8/25/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

/// Network controller which interfaces with the API to retreive terms and privacy related data.
final class TermsAndPrivacyNetworkController: NetworkRequestable {
    
    private(set) var session: NSURLSession = APIClient.sharedSession
}

extension TermsAndPrivacyNetworkController {
    
    /**
     Fetch the names of the latest terms of service and privacy policy files.
     
     - parameter success: Block to execute upon success.
     - parameter failure: Block to execute upon failure.
     */
    func fetchTermsAndPrivacyInfo(success: (termsFileName: String, privacyFileName: String) -> Void, failure: (error: NSError?) -> Void) {
        
        guard let request = TermsInfoRequest().request() else { return }
        
        let task = NSURLSessionTask.JSONTask(session, request: request, success: { [weak self] (JSON, response) in
            guard self != nil else { return }
            guard let dictionary = JSON as? NSDictionary,
                let termsFileName = dictionary["termsFilename"] as? String,
                let privacyFileName = dictionary["privacyFilename"] as? String else {
                    failure(error: nil)
                    return
            }
            success(termsFileName: termsFileName, privacyFileName: privacyFileName)
            
            }, failure: { [weak self] (error, response) in
                guard self != nil else { return }
                failure(error: error)
        })
        task.resume()
    }
}
