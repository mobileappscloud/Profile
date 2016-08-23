//
//  Leaderboard.Member.swift
//  higi
//
//  Created by Remy Panicker on 8/15/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

// MARK: Member

extension Leaderboard {
    
    /**
     *  Represents a member of a leaderboard.
     */
    struct Member {
        
        /// Unique identifier for a leaderboard.
        let leaderboardIdentifier: String
        
        /// Date a member joined a leaderboard.
        let joinDate: NSDate
        
        /// Unique identifier for a leaderboard user.
        let userIdentifier: String
    }
}

// MARK: JSON

extension Leaderboard.Member: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let leaderboardIdentifier = dictionary["leaderboardId"] as? String,
            let joinDate = NSDateFormatter.ISO8601DateFormatter.date(fromObject: dictionary["joined"]),
            let userIdentifier = dictionary["userId"] as? String else { return nil }
        
        self.leaderboardIdentifier = leaderboardIdentifier
        self.joinDate = joinDate
        self.userIdentifier = userIdentifier
    }
}

// MARK: - Analysis

extension Leaderboard.Member {
    
    /**
     *
     */
    struct Analysis {
        
        /// Display-ready text containing an analysis of a member's position within the leaderboard.
        let text: String
        
        /// Supplementary image which illustrates the type of analysis.
        let image: MediaAsset
        
        /// Action for user to take.
        let action: Action
        
        //        let configId: String
    }
}

// MARK: - Container

extension Leaderboard.Member.Analysis {
    
    /**
     *
     */
    struct Container {}
}

extension Leaderboard.Member.Analysis.Container {
    
    /**
     Type of member analysis container.
     
     - aaa:             Attention, analysis, and action container.
     - communityWidget: Container intended for use as a widget on community detail views.
     - profileWidget:   Container intended for use as a widget on profile views.
     */
    enum Type: APIString {
        case aaa
        case communityWidget
        case profileWidget
    }
}

// MARK: - Render Info

extension Leaderboard.Member.Analysis {
    
    /**
     *  Supplemental information for rendering a leaderboard.
     */
    struct RenderInfo {
        
        /// Type of score (unit) leaderboard values represent.
        let scoreType: Leaderboard.ScoreType
        
        /// Start date for a leaderboard.
        let startDate: NSDate
        
        /// End date for a leaderboard. `nil` if there is no end date.
        let endDate: NSDate?
    }
}

// MARK: - Action

extension Leaderboard.Member.Analysis {
    
    /**
     *  Action for a user to take based on the leaderboard analysis.
     */
    struct Action {
        
        /// Type of action.
        let type: Type
        
        /// Display-ready string to entice the user to take action.
        let teaser: String
    }
}

extension Leaderboard.Member.Analysis.Action {
    
    /**
     The different actions that can be presented to a user to perform if the analysis container supports actions.
     
     - invite:                Invite friends to join higi via social sharing.
     - linkToChallenges:      Link user to challenges they can join.
     - linkToCommunitiesList: Link user to find a community they can join.
     - linkToDeviceSync:      Link user to sync a tracking device.
     - linktoStationFinder:   Link user to find a nearby higi station.
     - postToFeed:            Post anaysis to higi feed.
     - promoteGymCheckin:     Promote the idea of tracking gym checkins and link to sync tracking devices.
     - promoteStepTracker:    Promote the idea of a step tracker and link to sync tracking devices.
     - share:                 Share analysis with friends via social sharing.
     */
    enum Type {
        case invite
        case linkToChallenges
        case linkToCommunitiesList
        case linkToDeviceSync
        case linktoStationFinder
        case postToFeed
        case promoteGymCheckin
        case promoteStepTracker
        case share
    }
}
