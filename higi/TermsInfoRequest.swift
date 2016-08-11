//
//  TermsInfoRequest.swift
//  higi
//
//  Created by Remy Panicker on 5/4/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class TermsInfoRequest: UnprotectedAPIRequest {

    func request() -> NSURLRequest? {
        // TODO: yikes
        let webURL = NSBundle.mainBundle().objectForInfoDictionaryKey("WebUrl") as! String
        let URLString = "\(webURL)/termsinfo"
        
        guard let URL = NSURL(string: URLString) else { return nil }
        
        let request = NSURLRequest(URL: URL)
        return request
    }
}
