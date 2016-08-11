//
//  StationCollectionRequest.swift
//  higi
//
//  Created by Remy Panicker on 6/2/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class StationCollectionRequest: UnprotectedAPIRequest {

    func request() -> NSURLRequest? {
        
        let URLString = "\(HigiApi.higiApiUrl)/data/KioskList"
        let URL = NSURL(string: URLString)!
        
        return request(URL, parameters: nil, body: nil)!
    }
}
