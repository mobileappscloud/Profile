//
//  JSONInitializable.swift
//  higi
//
//  Created by Remy Panicker on 7/24/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

protocol JSONInitializable: HigiAPI2 {
    
    init?(dictionary: NSDictionary)
}
