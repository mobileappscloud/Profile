//
//  Challenge.Chatter.swift
//  higi
//
//  Created by Remy Panicker on 8/12/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension Challenge {
    
    /**
     *  Object representing a comment thread.
     */
    struct Chatter {
        
        /// Collection of comments.
        let comments: [Comment]
        
        /// Paging information for long comment threads.
        let paging: Challenge.Paging
    }
}

// MARK: JSON

extension Challenge.Chatter: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let commentDicts = dictionary["data"] as? [NSDictionary],
            let paging = Challenge.Paging(fromJSONObject: dictionary["paging"])
            else { return nil }
        
        let comments = CollectionDeserializer.parse(dictionaries: commentDicts, forResource: Challenge.Chatter.Comment.self)

        self.comments = comments
        self.paging = paging
    }
}

// MARK: - Comment

extension Challenge.Chatter {
    
    /**
     *  Details a challenge comment. Comments may be public to all participants or private to only team members.
     */
    struct Comment {
        
        /// The comment text.
        let text: String
        
        /// Display-ready string which described the time elapsed since the comment was published. `Ex: 3 days ago`
        let elapsedTime: String
        
        /// Challenge participant who authored the comment.
        let author: Challenge.Participant
        
        /// The team property only appears if this is a private team comment.
        let team: Challenge.Team?
    }
}

// MARK: JSON

extension Challenge.Chatter.Comment: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let text = dictionary["comment"] as? String,
            let elapsedTime = dictionary["timeSincePosted"] as? String,
            let author = Challenge.Participant(fromJSONObject: dictionary["participant"]) else { return nil }
        
        let team = Challenge.Team(fromJSONObject: dictionary["team"])
        
        self.text = text
        self.elapsedTime = elapsedTime
        self.author = author
        self.team = team
    }
}
