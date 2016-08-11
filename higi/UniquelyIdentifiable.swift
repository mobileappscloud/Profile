//
//  UniquelyIdentifiable.swift
//  higi
//
//  Created by Remy Panicker on 8/5/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

/**
 *  Instances conforming to this protocol have a property which serves as a unique identifier for that resource.
 */
protocol UniquelyIdentifiable {
    
    var identifier: String { get }
}
