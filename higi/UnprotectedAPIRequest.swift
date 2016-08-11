//
//  UnprotectedAPIRequest.swift
//  higi
//
//  Created by Remy Panicker on 8/8/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

protocol UnprotectedAPIRequest: APIRequest {
    
    func request() -> NSURLRequest?
}
