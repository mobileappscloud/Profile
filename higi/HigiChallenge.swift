//
//  HigiChallenge.swift
//  higi
//
//  Created by Dan Harms on 11/4/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class HigiChallenge {
    
    var name, description, shortDescription, imageUrl, metric, status, userStatus, terms: NSString!;
    
    var startDate, endDate: NSDate!;
    
    var dailyLimit, participantsCount: Int!;
    
    var entryFee: Float!;
    
    var devices: [ActivityDevice]! = [];
    
    var winConditions: [ChallengeWinCondition]! = [];
    
    var participant: ChallengeParticipant!;
    
    var gravityBoard: [GravityParticipant]!;
    
    var teams: [ChallengeTeam]!;

    var highScore = 1000;
    
    init(dictionary: NSDictionary, userStatus: NSString, participant: ChallengeParticipant!, gravityBoard: [GravityParticipant]!) {
        self.userStatus = userStatus;
        self.participant = participant;
        self.gravityBoard = gravityBoard;
        name = (dictionary["name"] ?? "") as NSString;
        description = "";   // Deal with this later
        shortDescription = (dictionary["shortDescription"] ?? "") as NSString;
        var imageUrls =  dictionary["imageUrl"] as NSDictionary;
        imageUrl = imageUrls["default"] as? NSString;
        status = dictionary["status"] as NSString!;
        var formatter = NSDateFormatter();
        formatter.dateFormat = "yyyy-MM-dd";
        var startDateString = dictionary["startDate"] as NSString;
        startDate = formatter.dateFromString(startDateString);
        var endDateString = dictionary["endDate"] as NSString?;
        if (endDateString != nil) {
            endDate = formatter.dateFromString(endDateString!);
        }
        participantsCount = dictionary["participantsCount"] as Int;
        terms = (dictionary["terms"] ?? "") as? NSString;
        
        var conditions = dictionary["winConditions"] as NSArray?;
        if (conditions != nil) {
            for condition: AnyObject in conditions! {
                winConditions.append(ChallengeWinCondition(dictionary: condition as NSDictionary));
            }
        }
        
        var serverDevices = dictionary["devices"] as NSArray?;
        if (serverDevices != nil) {
            for device: AnyObject in serverDevices! {
                devices.append(ActivityDevice(dictionary: device as NSDictionary));
            }
        }
        
        var serverTeams = dictionary["teams"] as? NSArray;
        if (serverTeams != nil) {
            teams = [];
            for team: AnyObject in serverTeams! {
                teams.append(ChallengeTeam(dictionary: team as NSDictionary));
            }
        }

    }
    
}

struct GravityParticipant {
    var place: NSString!;
    var participant: ChallengeParticipant!;
}