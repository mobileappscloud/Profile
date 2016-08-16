//
//  JSONInitializable.swift
//  higi
//
//  Created by Remy Panicker on 7/24/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

protocol JSONInitializable: HigiAPI2, JSONDeserializable {
    
    init?(dictionary: NSDictionary)
}

extension JSONInitializable {
    
    init?(fromJSONObject object: AnyObject?) {
        guard let object = object as? NSDictionary else { return nil }
        
        self.init(dictionary: object)
    }
}

extension RawRepresentable {
    
    init?(rawJSONValue: AnyObject?) {
        guard let rawJSONValue = rawJSONValue as? RawValue else { return nil }
        
        self.init(rawValue: rawJSONValue)
    }
}
