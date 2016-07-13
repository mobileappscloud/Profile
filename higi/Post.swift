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
    
    enum MediaEntityType: String {
        case Image
        case Text
        case Video
    }
    
    struct Image {
        let asset: MediaAsset
        
        func squareImage(length: Int) -> NSURL {
            return sizedImage(length, height: length)
        }
        
        func sizedImage(width: Int, height: Int) -> NSURL {
            let urlString = asset.URI.absoluteString + "?width=\(String(width))&height=\(String(height))"
            return NSURL(string: urlString)!
        }
    }
    
    struct Video {
        let asset: MediaAsset
        let previewImage: Image
        let height: Int
        let width: Int
        let duration: NSTimeInterval
    }
    
    struct Elements {
        let transformableStrings: [TransformableString]
        let images: [Image]
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
    
    let subheading: String?
    
    let publishDate: NSDate
    
    let elements: Elements
}

// MARK: - Initialization

extension Post.Video: HigiAPIJSONDeserializer {
    
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
        self.previewImage = Post.Image(asset: previewImage)
        self.height = height
        self.width = width
        self.duration = durationMs / 1000
    }
}

extension Post.User: HigiAPIJSONDeserializer {
    
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

extension Post: HigiAPIJSONDeserializer {
    
    init?(dictionary: NSDictionary) {
        guard let identifier = dictionary["Id"] as? String,
            let userDict = dictionary["User"] as? NSDictionary,
            let user = User(dictionary: userDict),
            let typeString = dictionary["Type"] as? String,
            let type = Type(rawValue: typeString),
            let templateString = dictionary["TemplateType"] as? String,
            let template = Template(rawValue: templateString),
            let heading = dictionary["Heading"] as? String,
            let publishDateString = dictionary["PublishDate"] as? String
            // TODO: UNCOMMENT!
//            let publishDate = NSDateFormatter.ISO8601DateFormatter.dateFromString(publishDateString)
            else { return nil }
        
        // **NOTE** We are ignoring all custom templates for the time being.
        if template == .Custom { return nil }
        
        self.identifier = identifier
        self.user = user
        self.type = type
        self.template = template
        self.heading = heading
        // TODO: FIX!
//        self.publishDate = publishDate
        self.publishDate = NSDate().dateByAddingTimeInterval(-92349)

        self.subheading = (dictionary["Subheading"] as? String) ?? nil
        
        var transformableStrings: [TransformableString] = []
        var images: [Image] = []
        var videos: [Video] = []
        if let mediaEntities = dictionary["MediaEntities"] as? NSArray {
            for case let mediaEntity as NSDictionary in mediaEntities {
                guard let typeString = mediaEntity["Type"] as? String,
                    let type = MediaEntityType(rawValue: typeString) else { continue }
                
                switch type {
                case .Image:
                    if let imageDict = mediaEntity["Image"] as? NSDictionary,
                        let mediaAsset = MediaAsset(postDictionary: imageDict) {
                        let image = Image(asset: mediaAsset)
                        images.append(image)
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
        self.elements = Elements(transformableStrings: transformableStrings, images: images, videos: videos)
        
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
