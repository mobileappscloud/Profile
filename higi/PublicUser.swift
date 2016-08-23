//
//  PublicUser.swift
//  higi
//
//  Created by Remy Panicker on 8/15/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

/**
 *  The publicly consumable version of a user.
 */
struct PublicUser: UniquelyIdentifiable {
    
    // MARK: Required
    
    /// Unique identifier.
    let identifier: String
    
    /// Given (first) name of the user.
    let firstName: String
    
    /// Family (last) name of the user.
    let lastName: String
    
    /// Whether or not the user has a photo.
    let hasPhoto: Bool
    
    // MARK: Optional with natural defaults
    
    /// Whether or not the user can be viewed by other users.
    let isViewable: Bool
    
    /// Whether or not a user is a follower of the current authenticated user.
    let isFollower: Bool
    
    /// Whether or not the current authenticated user is following a user.
    let isFollowing: Bool
    
    /// Whether or not a follow request has been sent to this user from the current authenticated user.
    let followRequestSent: Bool
    
    // MARK: Optional
    
    /// Epock timestamp of when user photo was uploaded.
    let photoTime: NSTimeInterval?
    
    // MARK: Init
    
    init(identifier: String, firstName: String, lastName: String, hasPhoto: Bool, isViewable: Bool = true, isFollower: Bool = false, isFollowing: Bool = false, followRequestSent: Bool = false, photoTime: NSTimeInterval?) {
        
        self.identifier = identifier
        self.firstName = firstName
        self.lastName = lastName
        self.hasPhoto = hasPhoto
        
        self.isViewable = isViewable
        self.isFollower = isFollower
        self.isFollowing = isFollowing
        self.followRequestSent = followRequestSent
        
        self.photoTime = photoTime
    }
}

// MARK: - JSON

extension PublicUser: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let identifier = dictionary["id"] as? String,
            let firstName = dictionary["firstName"] as? String,
            let lastName = dictionary["lastName"] as? String,
            let hasPhoto = dictionary["hasPhoto"] as? Bool else { return nil }
        
        let isViewable = (dictionary["isViewable"] as? Bool) ?? true
        let isFollower = (dictionary["isFollower"] as? Bool) ?? false
        let isFollowing = (dictionary["isFollowing"] as? Bool) ?? false
        let followRequestSent = (dictionary["followRequestSent"] as? Bool) ?? false
        
        let photoTime = dictionary["photoTime"] as? NSTimeInterval
        
        self.init(identifier: identifier, firstName: firstName, lastName: lastName, hasPhoto: hasPhoto, isViewable: isViewable, isFollower: isFollower, isFollowing: isFollowing, followRequestSent: followRequestSent, photoTime: photoTime)
    }
}
