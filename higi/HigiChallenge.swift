import Foundation

final class HigiChallenge: JSONInitializable {
    
    var identifier: String!
    
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
    
    var goalDescription, prizeDescription, communityName: String
    
    var communityLogoImageUrl: NSURL
    
    convenience init?(dictionary: NSDictionary) {
        let challenge = dictionary
        let serverParticipant = (dictionary["userRelation"] as! NSDictionary)["participant"] as? NSDictionary;
        var participant: ChallengeParticipant!;
        if (serverParticipant != nil) {
            participant = ChallengeParticipant(dictionary: serverParticipant!);
        }
        let serverGravityBoard = (dictionary["userRelation"] as! NSDictionary)["gravityboard"] as? NSArray;
        var gravityBoard: [GravityParticipant] = [];
        if (serverGravityBoard != nil) {
            for boardParticipant: AnyObject in serverGravityBoard! {
                gravityBoard.append(GravityParticipant(place: (boardParticipant as! NSDictionary)["position"] as? NSString, participant: ChallengeParticipant(dictionary: (boardParticipant as! NSDictionary)["participant"] as! NSDictionary)));
            }
        }
        let serverParticipants = (dictionary["participants"] as! NSDictionary)["data"] as? NSArray;
        var participants:[ChallengeParticipant] = [];
        if (serverParticipants != nil) {
            for singleParticipant: AnyObject in serverParticipants! {
                if let participant = ChallengeParticipant(dictionary: singleParticipant as! NSDictionary) {
                    participants.append(participant)
                }
            }
        }
        let serverPagingData = ((dictionary["participants"] as! NSDictionary)["paging"] as! NSDictionary)["nextUrl"] as? NSString;
        let pagingData = PagingData(nextUrl: serverPagingData);
        
        let serverComments = (dictionary["comments"] as! NSDictionary)["data"] as? NSArray;
        var chatter:Chatter;
        var comments:[Comments] = [];
        var commentPagingData = PagingData(nextUrl: "");
        if (serverComments != nil) {
            commentPagingData = PagingData(nextUrl: ((dictionary["comments"] as! NSDictionary)["paging"] as! NSDictionary)["nextUrl"] as? NSString);
            for challengeComment in serverComments! {
                let comment = (challengeComment as! NSDictionary)["comment"] as! NSString;
                let timeSinceLastPost = (challengeComment as! NSDictionary)["timeSincePosted"] as! NSString;
                if let commentParticipant = ChallengeParticipant(dictionary: (challengeComment as! NSDictionary)["participant"] as! NSDictionary) {
                    let commentTeam = commentParticipant.team;
                    comments.append(Comments(comment: comment, timeSincePosted: timeSinceLastPost, participant: commentParticipant, team: commentTeam))
                }
            }
        }
        chatter = Chatter(comments: comments, paging: commentPagingData);
        
        let userRelationDict = challenge["userRelation"] as! NSDictionary
        let userStatus = userRelationDict["status"] as! NSString
        self.init(dictionary: challenge, userStatus: userStatus, participant: participant, gravityBoard: gravityBoard, participants: participants, pagingData: pagingData, chatter: chatter)
    }
    
    init(dictionary: NSDictionary, userStatus: NSString, participant: ChallengeParticipant!, gravityBoard: [GravityParticipant]!, participants: [ChallengeParticipant]!, pagingData: PagingData?, chatter: Chatter) {
        self.identifier = dictionary["id"] as! String
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
        goalDescription = dictionary["goalDescription"] as? String ?? ""
        prizeDescription = dictionary["prizeDescription"] as? String ?? ""
        communityName = (dictionary["community"] as? NSDictionary)?["name"] as? String ?? ""
        communityLogoImageUrl = NSURL(string: ((dictionary["community"] as? NSDictionary)?["logo"] as? NSDictionary)?["uri"] as? String ?? "") ?? NSURL()
        
        let conditions = dictionary["winConditions"] as? NSArray;
        if (conditions != nil) {
            for condition: AnyObject in conditions! {
                winConditions.append(ChallengeWinCondition(dictionary: condition as! NSDictionary));
            }
        }
        
        let serverDevices = dictionary["devices"] as? NSArray;
        if (serverDevices != nil) {
            for device: AnyObject in serverDevices! {
                devices.append(ActivityDevice(dictionary: device as! NSDictionary)!);
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
