//
//  JSONDeserializable.swift
//  higi
//
//  Created by Remy Panicker on 3/29/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

protocol JSONDeserializable: HigiAPI2 {}

extension JSONDeserializable {
    
    static func deserialize(data: NSData?, success: (JSON: AnyObject?) -> Void, failure: (error: NSError?) -> Void) {
        guard let data = data else {
            failure(error: nil)
            return
        }
        
        if data.length > 0 {
            do {
                let JSON = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
                success(JSON: JSON)
            } catch {
                let error = NSError(sender: String(self), code: 0, message: "Error serializing response.")
                failure(error: error)
            }
        } else {
            failure(error: nil)
        }
    }
}

extension JSONDeserializable where Self: JSONInitializable {
    
    func parse(JSON: AnyObject?) -> Self? {
        guard let JSON = JSON as? NSDictionary else { return nil }
        
        return Self.init(dictionary: JSON)
    }
}

extension JSONDeserializable where Self: JSONInitializable {
    
    func parse(dictionaries: [NSDictionary]) -> [Self] {
        var collection: [Self] = []
        for dictionary in dictionaries {
            guard let resource = Self.init(dictionary: dictionary) else { continue }
            
            collection.append(resource)
        }
        return collection
    }
}

extension NSDateFormatter: JSONDeserializable {
    
    func date(fromObject object: AnyObject?) -> NSDate? {
        guard let object = object as? String else { return nil }
        
        return dateFromString(object)
    }
}

extension NSURL: JSONDeserializable {

    convenience init?(responseObject: AnyObject?) {
        guard let responseObject = responseObject as? String else { return nil }
        
        self.init(string: responseObject)
    }
}
