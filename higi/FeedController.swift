//
//  FeedController.swift
//  higi
//
//  Created by Remy Panicker on 6/21/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class FeedController {
    
//    private(set) var posts: [] = []
    
    private(set) var paging: Paging? = nil
    
    lazy var session: NSURLSession = {
        return HigiAPIClient.session()
    }()
    
    var fetchTask: NSURLSessionDataTask?
    var nextPagingTask: NSURLSessionDataTask?
    
    deinit {
        session.invalidateAndCancel()
    }
}
