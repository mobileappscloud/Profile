//
//  AnyWrapper.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 8/23/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

/// Wraps any value or object into an object
final class AnyWrapper<AnyType> {
    let object: AnyType
    init(object: AnyType) {
        self.object = object
    }
}