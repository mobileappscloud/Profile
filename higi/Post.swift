//
//  Post.swift
//  higi
//
//  Created by Remy Panicker on 6/21/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct Post {
    
    enum Entity: String {
        case Community
        case Tag
        case User
    }
    
    enum Type: String {
        case Default
        case Announcement
        case News
        case Notification
        case Recipe
    }
    
    enum Template: String {
        case Custom
        case Image
        case ImageAndText
        case Text
        case TextImageAndHyperlink
        case TextVideoAndHyperlink
        case TextWithHyperlink
        case TextWithSurveyLink
        case TextWithVideo
        case Video
    }
    
    let identifier: String
    
    // entity identifier
//    let userId: String
//    let user: User
    
//    let communityId: String
//    let community: Community
    
    let type: Type
    
    let template: Template
    
    let heading: String
    
    let subheading: String
    
    let publishDate: NSDate
    
    let topText: TransformableString?
    
    let bottomText: TransformableString?
    
    
    
//    var mediaEntities: [PostMedia] = []
}

extension Post: HigiAPIJSONDeserializer {
    
    init?(dictionary: NSDictionary) {
        guard let identifier = dictionary["Id"] as? String,
            let typeString = dictionary["Type"] as? String,
            let type = Type(rawValue: typeString),
            let templateString = dictionary["TemplateType"] as? String,
            let template = Template(rawValue: templateString),
            let heading = dictionary["Heading"] as? String,
            let subheading = dictionary["Subheading"] as? String,
            let publishDateString = dictionary["PublishDate"] as? String,
            let publishDate = NSDateFormatter.ISO8601DateFormatter.dateFromString(publishDateString) else {
                return nil
        }
        
        self.identifier = identifier
        self.type = type
        self.template = template
        self.heading = heading
        self.subheading = subheading
        self.publishDate = publishDate
        
        if let topTextDict = dictionary["TopText"] as? NSDictionary {
            self.topText = nil
        } else {
            self.topText = nil
        }
        
        if let bottomTextDict = dictionary["BottomText"] as? NSDictionary {
            self.bottomText = nil
        } else {
            self.bottomText = nil
        }
    }
}
