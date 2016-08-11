//
//  NetworkRequestable.swift
//  higi
//
//  Created by Remy Panicker on 8/3/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

protocol NetworkRequestable: HigiAPI2 {
    
    var session: NSURLSession { get }
}
