import Foundation

class HigiChallenge {
    
    var name, description, shortDescription, imageUrl, metric, status, userStatus, terms, abbrMetric: NSString!;
    
    var startDate, endDate: NSDate!;
    
    var dailyLimit, participantsCount: Int!;
    
    var entryFee: Float!;
    
    var devices: [ActivityDevice]! = [];
    
    var winConditions: [ChallengeWinCondition]! = [];
    
    var participant: ChallengeParticipant!;
    
    var participants: [ChallengeParticipant]! = [];
    
    var gravityBoard: [GravityParticipant]!;
    
    var pagingData: PagingData?;
    
    var teams: [ChallengeTeam]!;

    var teamHighScore: Double! = 0;
    
    var individualHighScore: Double! = 0;
    
    init(dictionary: NSDictionary, userStatus: NSString, participant: ChallengeParticipant!, gravityBoard: [GravityParticipant]!, participants: [ChallengeParticipant]!, pagingData: PagingData?) {
        self.userStatus = userStatus;
        self.participant = participant;
        self.gravityBoard = gravityBoard;
        self.participants = participants;
        self.pagingData = pagingData;
        name = (dictionary["name"] ?? "") as NSString;
        description = dictionary["description"] as NSString!;
        shortDescription = (dictionary["shortDescription"] ?? "") as NSString;
        var imageUrls =  dictionary["imageUrl"] as NSDictionary;
        imageUrl = imageUrls["default"] as? NSString;
        status = dictionary["status"] as NSString!;
        metric = dictionary["metric"] as NSString!;
        dailyLimit = dictionary["dailyLimit"] as Int;
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
        
        var conditions = dictionary["winConditions"] as? NSArray;
        if (conditions != nil) {
            for condition: AnyObject in conditions! {
                winConditions.append(ChallengeWinCondition(dictionary: condition as NSDictionary));
            }
        }
        
        var serverDevices = dictionary["devices"] as? NSArray;
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
            if (teams.count > 0) {
                teamHighScore = teams[0].units;
            }
        }
        
        if (participants.count > 0) {
            individualHighScore = participants[0].units;
        }

        
    }
    
}

struct PagingData {
    var nextUrl: NSString?;
}

struct GravityParticipant {
    var place: NSString?;
    var participant: ChallengeParticipant!;
}

struct Comments {
    var comment: NSString?;
    var timeSincePosted: NSString?;
    
    var participant: ChallengeParticipant!;
    
    var team:ChallengeTeam;
    
    struct Chatter {
        var chatter:[Comments];
        var paging:PagingData;
    }

}