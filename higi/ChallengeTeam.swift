import Foundation

class ChallengeTeam {
    
    var name, imageUrl, joinUrl: NSString!;
    
    var memberCount: Int!;
    
    var units: Double!;
    
    var place: Int?;
    
    init(dictionary: NSDictionary) {
        name = dictionary["name"] as! NSString;
        memberCount = dictionary["membersCount"] as! Int;
        units = dictionary["units"] as! Double;
        var imageUrls = dictionary["imageUrl"] as! NSDictionary;
        imageUrl = imageUrls["default"] as! NSString;
        joinUrl = dictionary["joinUrl"] as? NSString;
    }
    
}