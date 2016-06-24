//
//  UserSerializer.swift
//  higi
//
//  Created by Remy Panicker on 5/9/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct UserSerializer: HigiAPIJSONSerializer {
    
    static func serialize(user: User) -> NSDictionary {
        
        let dataDictionary = NSMutableDictionary()
        dataDictionary["data"] = user.JSONDictionary()
        return dataDictionary as NSDictionary
    }
}
