//
//  PostCellUtility.swift
//  higi
//
//  Created by Remy Panicker on 7/25/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class PostCellUtility {
    
    static func postCell(forTableView tableView: UITableView, atIndexPath indexPath: NSIndexPath, post: Post, userController: UserController, isCommentDetail: Bool = false, targetPresentationViewController: UIViewController? = nil, cellActionBarItemDelegate: TableCellActionBarItemDelegate?) -> PostCell {
        
        let postCell = tableView.dequeueReusableCell(withClass: PostCell.self, forIndexPath: indexPath)
        
        postCell.reset()
        
        postCell.headerView.avatarButton.setImage(withMediaAsset: post.user.avatar, forState: .Normal)
        
        let authorName = NSPersonNameComponentsFormatter.localizedMediumStyle(withFirstName: post.user.firstName, lastName: post.user.lastName)!
        let action = authorAction(forPostTemplate: post.template)
        postCell.headerView.primaryLabel.attributedText = attributedString(authorName, action: action)
        
        let elapsedTime = Utility.shortElapsedTimeAgo(post.publishDate)
        postCell.headerView.secondaryLabel.text = elapsedTime
        
        let arrangedSubviews = contentElements(forPost: post, tableView: tableView, targetPresentationViewController: targetPresentationViewController)
        for arrangedSubview in arrangedSubviews {
            postCell.contentStackView.addArrangedSubview(arrangedSubview)
        }
        
        let actions = ActionBarUtility.actions(forContent: post)
        postCell.actionBar.configure(actions)
        weak var cellActionBarItemDelegate = cellActionBarItemDelegate
        postCell.cellActionBarItemDelegate = cellActionBarItemDelegate
        
        postCell.contentTapGestureHandler = cellTapHandler(forPost: post, targetPresentationViewController: targetPresentationViewController)
        
        return postCell
    }
    
    private static func attributedString(authorName: String, action: String) -> NSAttributedString {
        let format = NSLocalizedString("POST_CELL_HEADER_LABEL_AUTHOR_ACTION_FORMAT", comment: "Format of text displayed in header label of post for an author and action.")
        let string = String(format: format, arguments: [authorName, action])
        
        let authorNameFont = UIFont.boldSystemFontOfSize(16.0)
        let actionFont = UIFont.systemFontOfSize(16.0)
        
        let attrString = NSMutableAttributedString(string: string)
        
        attrString.addAttributes([NSFontAttributeName : authorNameFont], range: (string as NSString).rangeOfString(authorName))
        attrString.addAttributes([
            NSFontAttributeName : actionFont,
            NSForegroundColorAttributeName : Theme.Color.Primary.pewter
            ],
                                 range: (string as NSString).rangeOfString(action))
        
        return attrString.copy() as! NSAttributedString
    }
    
    static func contentTapGestureHandler(forPost post: Post, cell: PostCell, isCommentDetail: Bool = false, targetPresentationViewController: UIViewController? = nil) {
    }
    
    private static func authorAction(forPostTemplate template: Post.Template) -> String {
        let authorAction: String
        switch template {
        case .Custom:
            authorAction = ""
        case .Image:
            authorAction = NSLocalizedString("POST_TABLE_VIEW_CELL_AUTHOR_ACTION_TEMPLATE_IMAGE", comment: "Text displayed in table view cell header explaining the author posted content with an image.")
        case .ImageAndText:
            authorAction = NSLocalizedString("POST_TABLE_VIEW_CELL_AUTHOR_ACTION_TEMPLATE_IMAGE_TEXT", comment: "Text displayed in table view cell header explaining the author posted content with an image and text.")
        case .Text:
            authorAction = NSLocalizedString("POST_TABLE_VIEW_CELL_AUTHOR_ACTION_TEMPLATE_TEXT", comment: "Text displayed in table view cell header explaining the author posted content with text.")
        case .TextImageAndHyperlink:
            authorAction = NSLocalizedString("POST_TABLE_VIEW_CELL_AUTHOR_ACTION_TEMPLATE_TEXT_IMAGE_LINK", comment: "Text displayed in table view cell header explaining the author posted content with text an image and a link.")
        case .TextVideoAndHyperlink:
            authorAction = NSLocalizedString("POST_TABLE_VIEW_CELL_AUTHOR_ACTION_TEMPLATE_TEXT_VIDEO_LINK", comment: "Text displayed in table view cell header explaining the author posted content with text, video, and a link.")
        case .TextWithHyperlink:
            authorAction = NSLocalizedString("POST_TABLE_VIEW_CELL_AUTHOR_ACTION_TEMPLATE_TEXT_LINK", comment: "Text displayed in table view cell header explaining the author posted content with text and a link.")
        case .TextWithSurveyLink: 
            authorAction = NSLocalizedString("POST_TABLE_VIEW_CELL_AUTHOR_ACTION_TEMPLATE_TEXT_SURVEY", comment: "Text displayed in table view cell header explaining the author posted content with text and a survey.")
        case .TextWithVideo: 
            authorAction = NSLocalizedString("POST_TABLE_VIEW_CELL_AUTHOR_ACTION_TEMPLATE_TEXT_VIDEO", comment: "Text displayed in table view cell header explaining the author posted content with text and a video.")
        case .Video: 
            authorAction = NSLocalizedString("POST_TABLE_VIEW_CELL_AUTHOR_ACTION_TEMPLATE_VIDEO", comment: "Text displayed in table view cell header explaining the author posted content with a video.")
        }
        return authorAction
    }
    
    private static func contentElements(forPost post: Post, tableView: UITableView, targetPresentationViewController: UIViewController? = nil) -> [UIView] {
        
        var arrangedSubviews: [UIView] = []
        
        switch post.template {
        case .Custom:
            break
            
        case .Image:
            if let image = post.elements.images.first {
                let width = tableView.bounds.width
                let imageView = postImageView(forImage: image, width: width)
                arrangedSubviews.append(imageView)
            }
            
        case .TextImageAndHyperlink:
            fallthrough
        case .ImageAndText:
            if let image = post.elements.images.first {
                let width = tableView.bounds.width
                let imageView = postImageView(forImage: image, width: width)
                imageView.contentMode = .ScaleAspectFill
                arrangedSubviews.append(imageView)
            }
            if let transformableString = post.elements.transformableStrings.first {
                let textView = textDescriptionView(nil, description: transformableString)
                arrangedSubviews.append(textView)
            }
            break
            
        case .TextWithHyperlink:
            fallthrough
        case .TextWithSurveyLink:
            fallthrough
        case .Text:
            if let transformableString = post.elements.transformableStrings.first {
                let textView = textDescriptionView(nil, description: transformableString)
                arrangedSubviews.append(textView)
            }
            break
            
        case .TextWithVideo:
            fallthrough
        case .TextVideoAndHyperlink:
            if let transformableString = post.elements.transformableStrings.first {
                let textView = textDescriptionView(nil, description: transformableString)
                arrangedSubviews.append(textView)
            }
            fallthrough
        case .Video:
            var duration: String?
            if let video = post.elements.videos.first {
                let videoContainer = PostVideoContainer(frame: CGRect.zero)
                videoContainer.imageView.setImage(withMediaAsset: video.previewImage)
                videoContainer.imageView.contentMode = .ScaleAspectFit
                videoContainer.playButtonHandler = { [weak targetPresentationViewController] in
                    VideoPlayer.play(video, viewControllerToPresent: targetPresentationViewController)
                }
                arrangedSubviews.append(videoContainer)
                
                duration = NSDateComponentsFormatter.videoDurationFormatter.stringFromTimeInterval(video.duration)
            }
            let textView = textDescriptionView(forPost: post)
            if let duration = duration {
                // TODO: this is dumb, refactor it
                textView.titleLabel.text?.appendContentsOf(" (\(duration))")
            }
            arrangedSubviews.append(textView)
            
            break
        }
        
        return arrangedSubviews
    }
    
    private static func textDescriptionView(forPost post: Post) -> PostTextDescriptionView {
        let textDescriptionView = PostTextDescriptionView.init(frame: CGRect.zero)
        textDescriptionView.titleLabel.text = post.heading
        textDescriptionView.descriptionLabel.text = post.subheading
        textDescriptionView.titleLabel.hidden = post.heading.isEmpty
        textDescriptionView.descriptionLabel.hidden = post.subheading == nil || post.subheading!.isEmpty
        return textDescriptionView
    }
    
    private static func textDescriptionView(title: TransformableString?, description: TransformableString?) -> PostTextDescriptionView {
        let textDescriptionView = PostTextDescriptionView.init(frame: CGRect.zero)
        set(title, onLabel: textDescriptionView.titleLabel)
        set(description, onLabel: textDescriptionView.descriptionLabel)
        return textDescriptionView
    }
    
    private static func set(transformableString: TransformableString?, onLabel label: TTTAttributedLabel) {
        
        if let transformableString = transformableString {
            let text = NSMutableAttributedString(string: transformableString.text)
            
            var link: TTTAttributedLabelLink?
            for transform in transformableString.transforms {
                
                let substring = transformableString.text.substringWithRange(transform.range)
                let range = (transformableString.text as NSString).rangeOfString(substring)
                
                switch transform.type {
                case .Bold:
                    text.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(label.font.pointSize), range: range)
                    break
                    
                case .Italic:
                    text.addAttribute(NSFontAttributeName, value: UIFont.italicSystemFontOfSize(label.font.pointSize), range: range)
                    break
                    
                case .Survey:
                    fallthrough
                case .Hyperlink:
                    if let url = transform.URL {
                        //                        let link = TTTAttributedLabelLink(attributes: [:], activeAttributes: [:], inactiveAttributes: [:], textCheckingResult: .None)
                        //                        link.linkTapBlock = { (label, link) in
                        //                            print("link tap block")
                        //                        }
                        //                        label.addLink(link)
                        link = label.addLinkToURL(url, withRange: range)
                        link!.linkTapBlock = { (label, link) in
                            print("link tap block")
                        }
                    }
                    break
                }
            }
            
            label.setText(text.copy() as! NSAttributedString)
            if let link = link {
                label.addLink(link)
            }
        } else {
            label.hidden = true
        }
    }
    
    private static func postImageView(forImage image: MediaAsset, width: CGFloat) -> UIImageView {
        let imageView = UIImageView(frame: CGRect.zero)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = imageView.widthAnchor.constraintEqualToConstant(width)
        let heightConstraint = imageView.heightAnchor.constraintEqualToConstant(width)
        imageView.addConstraints([heightConstraint, widthConstraint])
        
        imageView.setImage(withMediaAsset: image)
        
        return imageView
    }
}

// MARK: UI Action
    
extension PostCellUtility {
    
    private static func cellTapHandler(forPost post: Post, targetPresentationViewController: UIViewController?) -> PostCell.ContentTapHandler? {
        
        var handler: PostCell.ContentTapHandler?
        
        switch post.template {
        case .Custom:
            break
            
        case .Image:
            break
            
        case .ImageAndText:
            break
            
        case .Text:
            break
            
        case .TextImageAndHyperlink:
            break
            
        case .TextWithHyperlink:
            break
            
        case .TextWithSurveyLink:
            break
            
        case .TextVideoAndHyperlink:
            fallthrough
        case .TextWithVideo:
            fallthrough
        case .Video:
            handler = { (cell) in
                guard let video = post.elements.videos.first else { return }
                
                weak var targetPresentationViewController = targetPresentationViewController                
                VideoPlayer.play(video, viewControllerToPresent: targetPresentationViewController)
            }
            break
        }
        
        return handler
    }
}
