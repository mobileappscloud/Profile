//
//  Post.swift
//  higi
//
//  Created by Remy Panicker on 6/21/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class Post {
    
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
    
    enum MediaEntityType: String {
        case Image
        case Text
        case Video
    }
    
    struct Video {
        let asset: MediaAsset
        let previewImage: MediaAsset
        let height: Int
        let width: Int
        let duration: NSTimeInterval
    }
    
    struct Elements {
        let transformableStrings: [TransformableString]
        let images: [MediaAsset]
        let videos: [Video]
    }
    
    struct User {
        let identifier: String
        let firstName: String
        let lastName: String
        let avatar: MediaAsset
    }
    
    // MARK: - Properties
    
    let identifier: String
    
    let user: User
    
    let type: Type
    
    let template: Template
    
    let heading: String
    
    let publishDate: NSDate
    
    let elements: Elements
    
    let commentCount: Int
    
    let likeCount: Int
    
    var subheading: String?
    
    required init(identifier: String, user: User, type: Type, template: Template, heading: String, publishDate: NSDate, elements: Elements, commentCount: Int, likeCount: Int) {
        
        self.identifier = identifier
        self.user = user
        self.type = type
        self.template = template
        self.heading = heading
        self.publishDate = publishDate
        self.elements = elements
        self.commentCount = commentCount
        self.likeCount = likeCount
    }
}

// MARK: - Initialization

extension Post.Video: JSONDeserializable, JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let videoURLString = dictionary["VideoUrl"] as? String,
            let videoExtension = dictionary["FileExtension"] as? String,
            let previewImageURLString = dictionary["PreviewImageUrl"] as? String,
            let previewImageExtension = dictionary["PreviewImageFileExtension"] as? String,
            let height = dictionary["Height"] as? Int,
            let width = dictionary["Width"] as? Int,
            let durationMs = dictionary["DurationMs"] as? Double
            else { return nil }
        
        let videoDict = MediaAsset.postDictionary(videoURLString, fileExtension: videoExtension)
        let previewImageDict = MediaAsset.postDictionary(previewImageURLString, fileExtension: previewImageExtension)
        
        guard let mediaAsset = MediaAsset(postDictionary: videoDict),
            let previewImage = MediaAsset(postDictionary: previewImageDict) else { return nil }
        
        self.asset = mediaAsset
        self.previewImage = previewImage
        self.height = height
        self.width = width
        self.duration = durationMs / 1000
    }
}

extension Post.User: JSONDeserializable, JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let identifier = dictionary["Id"] as? String,
            let firstName = dictionary["FirstName"] as? String,
            let lastName = dictionary["LastName"] as? String,
            let avatarDict = dictionary["Avatar"] as? NSDictionary,
            let avatar = MediaAsset(dictionary: avatarDict)
            else { return nil }
        
        self.identifier = identifier
        self.firstName = firstName
        self.lastName = lastName
        self.avatar = avatar
    }
}

extension Post: JSONDeserializable, JSONInitializable {
    
    convenience init?(dictionary: NSDictionary) {
        guard let identifier = dictionary["Id"] as? String,
            let userDict = dictionary["User"] as? NSDictionary,
            let user = User(dictionary: userDict),
            let typeString = dictionary["Type"] as? String,
            let type = Type(rawValue: typeString),
            let templateString = dictionary["TemplateType"] as? String,
            let template = Template(rawValue: templateString),
            let heading = dictionary["Heading"] as? String,
            let publishDateString = dictionary["PublishDate"] as? String,
            let publishDate = NSDateFormatter.ISO8601DateFormatter.dateFromString(publishDateString),
            let chatterDict = dictionary["Chatter"] as? NSDictionary,
            let commentCount = chatterDict["CommentCount"] as? Int,
            let likeCount = chatterDict["LikeCount"] as? Int
            else { return nil }
        
        // **NOTE** We are ignoring all custom templates for the time being.
        if template == .Custom { return nil }
        
        var transformableStrings: [TransformableString] = []
        var images: [MediaAsset] = []
        var videos: [Video] = []
        if let mediaEntities = dictionary["MediaEntities"] as? NSArray {
            for case let mediaEntity as NSDictionary in mediaEntities {
                guard let typeString = mediaEntity["Type"] as? String,
                    let type = MediaEntityType(rawValue: typeString) else { continue }
                
                switch type {
                case .Image:
                    if let imageDict = mediaEntity["Image"] as? NSDictionary,
                        let mediaAsset = MediaAsset(postDictionary: imageDict) {
                        images.append(mediaAsset)
                    }
                    break
                    
                case .Text:
                    if let transformableString = TransformableString(dictionary: mediaEntity) {
                        transformableStrings.append(transformableString)
                    }
                    break
                    
                case .Video:
                    if let videoDict = mediaEntity["Video"] as? NSDictionary,
                        let video = Video(dictionary: videoDict) {
                        videos.append(video)
                    }
                    break
                }
            }
        }
        let elements = Elements(transformableStrings: transformableStrings, images: images, videos: videos)
        
        self.init(identifier: identifier, user: user, type: type, template: template, heading: heading, publishDate: publishDate, elements: elements, commentCount: commentCount, likeCount: likeCount)
        
        // validate template
        if !isValid() {
            return nil
        }
    }
}

// MARK: - Template Validation

extension Post {
    
    private func isValid() -> Bool {
        var isValid = false
        switch self.template {
        case .Custom:
            break
            
        case .Image:
            isValid = validImagePost()
            
        case .ImageAndText:
            isValid = validImageAndTextPost()
            
        case .Text:
            isValid = validTextPost()
            
        case .TextImageAndHyperlink:
            isValid = validTextImageAndHyperlinkPost()
            
        case .TextVideoAndHyperlink:
            isValid = validTextVideoAndHyperlinkPost()
            
        case .TextWithHyperlink:
            isValid = validTextWithHyperlinkPost()
            
        case .TextWithSurveyLink:
            isValid = validTextWithSurveyLinkPost()
            
        case .TextWithVideo:
            isValid = validTextWithVideoPost()
            
        case .Video:
            isValid = validVideoPost()
        }
        return isValid
    }
    
    private func validImagePost() -> Bool {
        return elements.images.count == 1
    }
    
    private func validImageAndTextPost() -> Bool {
        return elements.images.count == 1 && elements.transformableStrings.count == 1
    }
    
    private func validTextPost() -> Bool {
        return elements.transformableStrings.count == 1
    }
    
    private func validTextImageAndHyperlinkPost() -> Bool {
        return elements.transformableStrings.count == 1 && elements.images.count == 1
    }
    
    private func validTextVideoAndHyperlinkPost() -> Bool {
        return elements.transformableStrings.count == 1 && elements.videos.count == 1
    }
    
    private func validTextWithHyperlinkPost() -> Bool {
        return elements.transformableStrings.count == 1
    }
    
    private func validTextWithSurveyLinkPost() -> Bool {
        return elements.transformableStrings.count == 1
    }
    
    private func validTextWithVideoPost() -> Bool {
        return elements.transformableStrings.count == 1
    }
    
    private func validVideoPost() -> Bool {
        return elements.videos.count == 1
    }
}
