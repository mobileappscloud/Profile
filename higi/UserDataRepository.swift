//
//  UserDataRepository.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 8/31/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

/// Repository for all data associated with the user. Has the ability to retrieve
/// user data by id.
class UserDataRepository<T: UniquelyIdentifiable> {
    private var data = [UniqueId: T]()
    
    func object(forId id: UniqueId) -> T? {
        return data[id]
    }
    
    func add(object object: T) {
        data[object.identifier] = object
    }
    
    func objects(forIds ids: [UniqueId]) -> [T] {
        var output = [T]()
        ids.forEach { (id) in
            if let object: T = object(forId: id) {
                output.append(object)
            }
        }
        return output
    }
    
    func add(objects objects: [T]) {
        objects.forEach(add)
    }
}
