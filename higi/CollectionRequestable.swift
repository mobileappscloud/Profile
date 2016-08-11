//
//  CollectionRequestable.swift
//  higi
//
//  Created by Remy Panicker on 8/3/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

protocol CollectionRequestable: NetworkRequestable {
    
    var paging: Paging? { get }
    
    var collectionFetchTask: NSURLSessionTask? { get }
    var previousCollectionFetchTask: NSURLSessionTask? { get }
    var nextCollectionFetchTask: NSURLSessionTask? { get }
}
