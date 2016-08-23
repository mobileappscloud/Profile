import Foundation

final class ChallengeTeam {
    
    var name, imageUrl, joinURL: NSString!;
    
    var memberCount: Int!;
    
    var units: Double!;
    
    var place: Int?;
    
    init(dictionary: NSDictionary) {
        name = dictionary["name"] as! NSString;
        memberCount = dictionary["membersCount"] as! Int;
        units = dictionary["units"] as! Double;
        let imageUrls = dictionary["imageUrl"] as! NSDictionary;
        imageUrl = imageUrls["default"] as! NSString;
        let userRelation = dictionary["userRelation"] as! NSDictionary;
        joinURL = userRelation["joinUrl"] as? NSString;
    }
    
}