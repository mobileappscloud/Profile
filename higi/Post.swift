//
//  Post.swift
//  higi
//
//  Created by Remy Panicker on 6/21/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

/// Represents a feed content item.
final class Post: UniquelyIdentifiable, ContentInteractable {
    
    // MARK: Required
    
    /// Unique identifier.
    let identifier: String
    
    /// Author of the post.
    let user: User
    
    /// Type of the post.
    let type: Type
    
    /// Template of the post.
    let template: Template
    
    /// Header text to display in the post.
    let heading: String
    
    /// Date the post was published.
    let publishDate: NSDate
    
    /// Elements comprising the post.
    let elements: Elements
    
    /// The number of comments on a post.
    let commentCount: Int
    
    /// Number of users who have liked a post.
    let likeCount: Int
    
    /// Actions the current user has taken on the post.
    let actions: Content.Actions
    
    /// Permissions to actions the current user can take on the post.
    let permissions: Content.Permissions
    
    // MARK: Optional
    
    /// Optional text to display in a post subheader.
    let subheading: String?
    
    // MARK: Init
    
    required init(identifier: String, user: User, type: Type, template: Template, heading: String, publishDate: NSDate, elements: Elements, commentCount: Int, likeCount: Int, actions: Content.Actions, permissions: Content.Permissions, subheading: String? = nil) {
        
        self.identifier = identifier
        self.user = user
        self.type = type
        self.template = template
        self.heading = heading
        self.publishDate = publishDate
        self.elements = elements
        self.commentCount = commentCount
        self.likeCount = likeCount
        self.actions = actions
        self.permissions = permissions
        
        self.subheading = subheading
    }
}

// MARK: Entity

extension Post {
    
    /**
     Entities which a post can be targeted towards.
     
     - Community: Community which a post is targeting.
     - Tag:       Tag which a post is targeting.
     - User:      User which a post is targeting.
     */
    enum Entity: APIString {
        case Community
        case Tag
        case User
    }
}

// MARK: Type

extension Post {
 
    /**
     Type of post.
     
     - Default:      Default, non-specialized post.
     - Announcement: Specialized post for an announcement.
     - News:         Specialized post for news.
     - Notification: Specialized post for a notification.
     - Recipe:       Specialized post for a recipe.
     */
    enum Type: APIString {
        case Default
        case Announcement
        case News
        case Notification
        case Recipe
    }
}

// MARK: Template

extension Post {
    
    /**
     Type of template to use when rendering a post.
     
     - Custom:                Custom template.
     - Image:                 Post containing an image.
     - ImageAndText:          Post containing an image and text.
     - Text:                  Post containing text.
     - TextImageAndHyperlink: Post containing an image and text with hyperlink.
     - TextVideoAndHyperlink: Post containing a video and text with hyperlink.
     - TextWithHyperlink:     Post containing text with a hyperlink.
     - TextWithSurveyLink:    Post containing text with a survey link.
     - TextWithVideo:         Post containing a video and text.
     - Video:                 Post containing a video.
     */
    enum Template: APIString {
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
}

// MARK: Media Entity Type

extension Post {
    
    /**
     Type of media entity.
     
     - Image: Image media entity.
     - Text:  Text-based media entity.
     - Video: Video media entity.
     */
    enum MediaEntityType: APIString {
        case Image
        case Text
        case Video
    }
}

// MARK: JSON

extension Post: JSONInitializable {
    
    convenience init?(dictionary: NSDictionary) {
        guard let identifier = dictionary["id"] as? String,
            let user = User(fromJSONObject: dictionary["user"]),
            let type = Type(rawJSONValue: dictionary["type"]),
            let template = Template(rawJSONValue: dictionary["templateType"])
            where template != .Custom, // **NOTE** We are ignoring all custom templates for the time being.
            let heading = dictionary["heading"] as? String,
            let publishDate = NSDateFormatter.ISO8601DateFormatter.date(fromObject: dictionary["publishDate"]),
            let chatterDict = dictionary["chatter"] as? NSDictionary,
            let commentCount = chatterDict["commentCount"] as? Int,
            let likeCount = chatterDict["likeCount"] as? Int,
            let actions = Content.Actions(fromJSONObject: dictionary["actions"]),
            let permissions = Content.Permissions(fromJSONObject: dictionary["permissions"])
            else { return nil }
        
        var transformableStrings: [TransformableString] = []
        var images: [MediaAsset] = []
        var videos: [Video] = []
        if let mediaEntityDicts = dictionary["mediaEntities"] as? [NSDictionary] {
            for mediaEntityDict in mediaEntityDicts {
                guard let type = MediaEntityType(rawJSONValue: mediaEntityDict["type"]) else { continue }
                
                switch type {
                case .Image:
                    if let mediaAsset = MediaAsset(fromJSONObject: mediaEntityDict["image"]) {
                        images.append(mediaAsset)
                    }
                    break
                    
                case .Text:
                    if let transformableString = TransformableString(dictionary: mediaEntityDict) {
                        transformableStrings.append(transformableString)
                    }
                    break
                    
                case .Video:
                    if let video = Video(fromJSONObject: mediaEntityDict["video"]) {
                        videos.append(video)
                    }
                    break
                }
            }
        }
        let elements = Elements(transformableStrings: transformableStrings, images: images, videos: videos)
        
        let subheading = dictionary["subheading"] as? String
        
        self.init(identifier: identifier, user: user, type: type, template: template, heading: heading, publishDate: publishDate, elements: elements, commentCount: commentCount, likeCount: likeCount, actions: actions, permissions: permissions, subheading: subheading)
        
        // validate template
        if !isValid() {
            return nil
        }
    }
}

// MARK: Template Validation

extension Post {
    
    /**
     Evaluates the validity of a post template.
     
     - returns: `true` if a post is valid, otherwise `false`.
     */
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

// MARK: Copying

extension Post {
    
    /**
     Creates a modified copy of a post.
     
     - parameter likeCount: Number of 'likers' on a post.
     - parameter actions:   Actions which a user has taken on a post.
     
     - returns: A new copy of a comment, modified with the specified parameters.
     */
    func copy(likeCount likeCount: Int, actions: Content.Actions) -> Post {
        return Post(identifier: self.identifier, user: self.user, type: self.type, template: self.template, heading: self.heading, publishDate: self.publishDate, elements: self.elements, commentCount: self.commentCount, likeCount: likeCount, actions: actions, permissions: self.permissions)
    }
}

extension Post {
    
    /**
     Creates a modified copy of a post.
     
     - parameter commentCount: The number of comments on a post.
     
     - returns: A new copy of a comment, modified with the specified parameters.
     */
    func copy(commentCount commentCount: Int) -> Post {
        return Post(identifier: self.identifier, user: self.user, type: self.type, template: self.template, heading: self.heading, publishDate: self.publishDate, elements: self.elements, commentCount: commentCount, likeCount: self.likeCount, actions: self.actions, permissions: self.permissions)
    }
}

// MARK: - Video

extension Post {
    
    /**
     *  Represents a video element in a post.
     */
    struct Video {
        
        /// Video media asset.
        let asset: MediaAsset
        
        /// Image media
        let previewImage: MediaAsset
        
        /// Height of video in pixels.
        let height: Int
        
        /// Width of video in pixels.
        let width: Int
        
        /// Duration of video in seconds.
        let duration: NSTimeInterval
    }
}

extension Post.Video: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let videoURLString = dictionary["videoUrl"] as? String,
            let videoExtension = dictionary["fileExtension"] as? String,
            let previewImageURLString = dictionary["previewImageUrl"] as? String,
            let previewImageExtension = dictionary["previewImageFileExtension"] as? String,
            let height = dictionary["height"] as? Int,
            let width = dictionary["width"] as? Int,
            let durationMs = dictionary["durationMs"] as? Double
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

// MARK: - Elements

extension Post {
    
    /**
     *  Elements which comprise of a post.
     */
    struct Elements {
        
        /// A collection of text entities which may contain transforms such as bold/italic text or hyperlinks.
        let transformableStrings: [TransformableString]
        
        /// A collection of image assets.
        let images: [MediaAsset]
        
        /// A collection of video elements.
        let videos: [Video]
    }
}

// MARK: - User

extension Post {
    
    /**
     *  Represents a user of the content service.
     */
    struct User: UniquelyIdentifiable {
        
        /// Unique identifier.
        let identifier: String
        
        /// The user's given (first) name.
        let firstName: String
        
        /// The user's family (last) name.
        let lastName: String
        
        /// An asset with the user's avatar.
        let avatar: MediaAsset
    }
}

// MARK: JSON

extension Post.User: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let identifier = dictionary["id"] as? String,
            let firstName = dictionary["firstName"] as? String,
            let lastName = dictionary["lastName"] as? String,
            let avatar = MediaAsset(fromJSONObject: dictionary["avatar"])
            else { return nil }
        
        self.identifier = identifier
        self.firstName = firstName
        self.lastName = lastName
        self.avatar = avatar
    }
}
