import Foundation

class HigiChallenge {
    
    var name, description, shortDescription, imageUrl, metric, status, userStatus, terms, abbrMetric, joinUrl, commentsUrl, url: NSString!;
    
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
    
    var chatter:Chatter!;
    
    init(dictionary: NSDictionary, userStatus: NSString, participant: ChallengeParticipant!, gravityBoard: [GravityParticipant]!, participants: [ChallengeParticipant]!, pagingData: PagingData?, chatter: Chatter) {
        self.userStatus = userStatus;
        self.participant = participant;
        self.gravityBoard = gravityBoard;
        self.participants = participants;
        self.pagingData = pagingData;
        self.chatter = chatter;
        url = (dictionary["url"] ?? "") as! NSString;
        name = (dictionary["name"] ?? "") as! NSString;
        description = dictionary["description"] as! NSString!;
        shortDescription = (dictionary["shortDescription"] ?? "") as! NSString;
        let imageUrls =  dictionary["imageUrl"] as! NSDictionary;
        imageUrl = imageUrls["default"] as? NSString;
        status = dictionary["status"] as! NSString!;
        metric = dictionary["metric"] as! NSString!;
        abbrMetric = metric.stringByReplacingOccurrencesOfString("points", withString: "pts");
        dailyLimit = dictionary["dailyLimit"] as! Int;
        let userRelation = dictionary["userRelation"] as! NSDictionary;
        joinUrl = userRelation["joinUrl"] as? NSString;
        commentsUrl = dictionary["commentsUrl"] as? NSString;
        entryFee = (dictionary["entryFee"] ?? 0) as! Float;
        let formatter = NSDateFormatter();
        formatter.dateFormat = "yyyy-MM-dd";
        let startDateString = dictionary["startDate"] as! String;
        startDate = formatter.dateFromString(startDateString);
        let endDateString = dictionary["endDate"] as! String?;
        if (endDateString != nil) {
            endDate = formatter.dateFromString(endDateString!);
        }
        participantsCount = dictionary["participantsCount"] as! Int;
        terms = (dictionary["terms"] ?? "") as? NSString;
        let conditions = dictionary["winConditions"] as? NSArray;
        if (conditions != nil) {
            for condition: AnyObject in conditions! {
                winConditions.append(ChallengeWinCondition(dictionary: condition as! NSDictionary));
            }
        }
        
        let serverDevices = dictionary["devices"] as? NSArray;
        if (serverDevices != nil) {
            for device: AnyObject in serverDevices! {
                devices.append(ActivityDevice(dictionary: device as! NSDictionary));
            }
        }
        
        let serverTeams = dictionary["teams"] as? NSArray;
        if (serverTeams != nil) {
            teams = [];
            for team: AnyObject in serverTeams! {
                teams.append(ChallengeTeam(dictionary: team as! NSDictionary));
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

struct Chatter {
    var comments:[Comments];
    var paging:PagingData;
}

struct Comments {
    var comment: NSString;
    var timeSincePosted: NSString;
    var participant: ChallengeParticipant!;
    var team:ChallengeTeam?;
}