//
//  FeedViewController.swift
//  higi
//
//  Created by Remy Panicker on 6/21/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

final class FeedViewController: UIViewController {

    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.addSubview(self.refreshControl)
            
            tableView.separatorStyle = .None
            
            tableView.estimatedRowHeight = 211.0
            tableView.sectionHeaderHeight = 0.0
            tableView.sectionFooterHeight = 0.0
            
            tableView.register(nibWithCellClass: PostCell.self)
            tableView.register(cellClass: UITableViewCell.self)
            tableView.register(nibWithCellClass: ActivityIndicatorTableViewCell.self)
        }
    }
    
    lazy private var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(handleRefresh), forControlEvents: .ValueChanged)
        return control
    }()
    
    private let feedController = FeedController()
    
    private(set) var userController: UserController!
    private(set) var entity: Post.Entity!
    private(set) var entityId: String!
    /// View Controller to target presentation on. Useful if this view controller is embedded within containers.
    private(set) weak var targetPresentationViewController: UIViewController?
    
    func configure(userController: UserController, entity: Post.Entity, entityId: String, targetPresentationViewController: UIViewController?) {
        self.userController = userController
        self.entity = entity
        self.entityId = entityId
        self.targetPresentationViewController = targetPresentationViewController
    }
    
    deinit {
        print("dealloc home and invalidate timer!")
        feedController.refreshTimer?.invalidate()
        feedController.refreshTimer = nil
    }
}

// MARK: - Table Taxonomy

extension FeedViewController {
    
    enum TableSection: Int  {
        case Feed
        case InfiniteScroll
        case Count
    }
    
    enum FeedRowType: Int {
        case Post
        case Separator
        case Count
        
        init(indexPath: NSIndexPath) {
            self = FeedRowType(rawValue: indexPath.row % FeedRowType.Count.rawValue)!
        }
        
        func defaultHeight() -> CGFloat {
            switch self {
            case .Post:
                return UITableViewAutomaticDimension
            case .Separator:
                return 15.0
            case .Count:
                return 0.0
            }
        }
    }
    
    enum InfiniteScrollRowType: Int {
        case ActivityIndicator
        case Count
        
        init(indexPath: NSIndexPath) {
            self = InfiniteScrollRowType(rawValue: indexPath.row % InfiniteScrollRowType.Count.rawValue)!
        }
        
        func defaultHeight() -> CGFloat {
            switch self {
            case .ActivityIndicator:
                return 70.0
            case .Count:
                return 0.0
            }
        }
    }
}

// MARK: - View Lifecycle

extension FeedViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetch()
        scheduleRefresh()
    }
}

// MARK: - Fetch Data

extension FeedViewController {
    
    private func scheduleRefresh() {
        feedController.scheduleRefresh({ [weak self] in
            self?.handleRefresh()
            })
    }
}

// MARK: Request Data

extension FeedViewController {
    
    private func fetch(scrollToTop: Bool = false) {
        feedController.fetch(entity, entityId: entityId, success: { [weak self] in
            self?.fetchSuccessHandler(scrollToTop)
            }, failure: { [weak self] (error) in
                self?.fetchFailureHandler()
            })
    }
    
    private func fetchSuccessHandler(scrollToTop: Bool = false) {
        print("fetch success")
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            if scrollToTop {
                if self.tableView.numberOfRowsInSection(0) > 0 {
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
                }
            }
        })
    }
    
    private func fetchFailureHandler() {
        print("fetch failure")
    }
}

extension FeedViewController {
    
    private func fetchNext() {
        guard let _ = feedController.paging?.next else {
            return
        }
        
        feedController.fetchNext(fetchNextSuccess, failure: fetchNextFailure)
    }
    
    private func fetchNextSuccess() {
        print("fetch next success")
    }
    
    private func fetchNextFailure(error: NSError?) {
        print("fetch next failure")
    }
}

// MARK: Pull To Refresh

extension FeedViewController {
    
    @objc private func handleRefresh() {
        fetch(true)
    }
}

// MARK: - Table

extension FeedViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TableSection.Count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        guard let sectionType = TableSection(rawValue: section) else {
            return rowCount
        }
        
        switch sectionType {
        case .Feed:
            rowCount = feedController.posts.count * FeedRowType.Count.rawValue
        case .InfiniteScroll:
            rowCount = InfiniteScrollRowType.Count.rawValue
        case .Count:
            break
        }
        
        return rowCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let sectionType = TableSection(rawValue: indexPath.section) else {
            fatalError("Invalid table section")
        }
        
        var cell: UITableViewCell!
        switch sectionType {
        case .Feed:
            let rowType = FeedRowType(indexPath: indexPath)
            switch rowType {
            case .Post:
                cell = postCell(forTableView: tableView, atIndexPath: indexPath)
                
            case .Separator:
                cell = separatorCell(forTableView: tableView, atIndexPath: indexPath)
                
            case .Count:
                break
            }
            
        case .InfiniteScroll:
            let rowType = InfiniteScrollRowType(indexPath: indexPath)
            switch rowType {
            case .ActivityIndicator:
                cell = tableView.dequeueReusableCell(withClass: ActivityIndicatorTableViewCell.self, forIndexPath: indexPath)
                
            case .Count:
                break
            }
            
        case .Count:
            break
        }
        
        if let cell = cell {
            cell.selectionStyle = .None
            return cell
        } else {
            fatalError("Method must produce a cell!")
        }
    }
}

extension FeedViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Must return non-zero value or else there is unwanted padding at top of tableview
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var rowHeight: CGFloat = 0.0
        guard let sectionType = TableSection(rawValue: indexPath.section) else { return rowHeight }
        
        switch sectionType {
            
        case .Feed:
            let rowType = FeedRowType(indexPath: indexPath)
            rowHeight = rowType.defaultHeight()
            
        case .InfiniteScroll:
            guard let paging = feedController.paging,
                let _ = paging.next else {
                    break
            }
            
            let rowType = InfiniteScrollRowType(indexPath: indexPath)
            rowHeight = rowType.defaultHeight()
            
        case .Count:
            break
        }
        
        return rowHeight
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let sectionType = TableSection(rawValue: indexPath.section) else { return }
        
        if sectionType == .InfiniteScroll {
            fetchNext()
        }
    }
}

// MARK: - Custom Cells

extension FeedViewController {
    
    // MARK: Separator
    
    private func separatorCell(forTableView tableView: UITableView, atIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let separatorCell = tableView.dequeueReusableCell(withClass: UITableViewCell.self, forIndexPath: indexPath)
        separatorCell.backgroundColor = Theme.Color.Primary.whiteGray
        return separatorCell
    }
    
    // MARK: Post
    
    private func postCell(forTableView tableView: UITableView, atIndexPath indexPath: NSIndexPath) -> PostCell {
        let postCell = tableView.dequeueReusableCell(withClass: PostCell.self, forIndexPath: indexPath)
        
        let index = indexPath.row / FeedRowType.Count.rawValue
        let post = feedController.posts[index]
        
        postCell.reset()
        
        postCell.headerView.avatarButton.setImage(withMediaAsset: post.user.avatar, forState: .Normal)
        let elapsedTime = Utility.abbreviatedElapsedTimeUnit(post.publishDate, toDate: NSDate())
        let authorName = NSPersonNameComponentsFormatter.localizedMediumStyle(withFirstName: post.user.firstName, lastName: post.user.lastName)
        postCell.headerView.configure(authorName, action: nil, timestamp: elapsedTime)
        
        let arrangedSubviews = contentElements(forPost: post)
        for arrangedSubview in arrangedSubviews {
            postCell.contentStackView.addArrangedSubview(arrangedSubview)
        }
        postCell.contentTapGestureHandler = cellTapHandler(forPost: post)

        let actions = actionBarItems(post)
        postCell.actionBar.configure(actions)
        
        return postCell
    }
    
    private func contentElements(forPost post: Post) -> [UIView] {
        
        var arrangedSubviews: [UIView] = []
        
        switch post.template {
        case .Custom:
            break
            
        case .Image:
            if let image = post.elements.images.first {
                let imageView = postImageView(forImage: image)
                arrangedSubviews.append(imageView)
            }
            
        case .TextImageAndHyperlink:
            fallthrough
        case .ImageAndText:
            if let image = post.elements.images.first {
                let imageView = postImageView(forImage: image)
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
                let width = tableView.bounds.width
                videoContainer.imageView.setImage(withPostImage: video.previewImage, length: Int(width))
                videoContainer.imageView.contentMode = .ScaleAspectFit
                videoContainer.playButtonHandler = {
                    print("Thanks for pressing play")
                }
                arrangedSubviews.append(videoContainer)
                
                duration = NSDateComponentsFormatter.videoDurationFormatter.stringFromTimeInterval(video.duration)
            }
            let textView = textDescriptionView(forPost: post)
            if let duration = duration {
                textView.titleLabel.text?.appendContentsOf(" (\(duration))")
            }
            arrangedSubviews.append(textView)
            
            break
        }
        
        return arrangedSubviews
    }
    
    private func textDescriptionView(forPost post: Post) -> PostTextDescriptionView {
        let textDescriptionView = PostTextDescriptionView.init(frame: CGRect.zero)
        textDescriptionView.titleLabel.text = post.heading
        textDescriptionView.descriptionLabel.text = post.subheading
        textDescriptionView.titleLabel.hidden = post.heading.isEmpty
        textDescriptionView.descriptionLabel.hidden = post.subheading == nil || post.subheading!.isEmpty
        return textDescriptionView
    }
    
    private func textDescriptionView(title: TransformableString?, description: TransformableString?) -> PostTextDescriptionView {
        let textDescriptionView = PostTextDescriptionView.init(frame: CGRect.zero)
        set(title, onLabel: textDescriptionView.titleLabel)
        set(description, onLabel: textDescriptionView.descriptionLabel)
        return textDescriptionView
    }
    
    private func set(transformableString: TransformableString?, onLabel label: TTTAttributedLabel) {
        
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
    
    private func postImageView(forImage image: Post.Image) -> UIImageView {
        let imageView = UIImageView(frame: CGRect.zero)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let width = tableView.bounds.width
        let widthConstraint = imageView.widthAnchor.constraintEqualToConstant(width)
        let heightConstraint = imageView.heightAnchor.constraintEqualToConstant(width)
        imageView.addConstraints([heightConstraint, widthConstraint])
        
        imageView.setImage(withPostImage: image, length: Int(width))
        
        return imageView
    }
    
    private func actionBarItems(forPost: Post) -> [PostActionBar.Action] {
        
        let highFiveTitle = NSLocalizedString("FEED_VIEW_POST_TABLE_CELL_ACTION_BAR_BUTTON_TITLE_HIGH_FIVE", comment: "Title for high-five button within post action bar.")
        let commentTitle = NSLocalizedString("FEED_VIEW_POST_TABLE_CELL_ACTION_BAR_BUTTON_TITLE_COMMENT", comment: "Title for comment button within post action bar.")
        let shareTitle = NSLocalizedString("FEED_VIEW_POST_TABLE_CELL_ACTION_BAR_BUTTON_TITLE_SHARE", comment: "Title for share button within post action bar.")
        let highFive = PostActionBar.Action(title: highFiveTitle, handler: nil)
        let comment = PostActionBar.Action(title: commentTitle, handler: nil)
        let share = PostActionBar.Action(title: shareTitle, handler: nil)
        return [highFive, comment, share]
    }
    
    private func cellTapHandler(forPost post: Post) -> ((cell: PostCell) -> Void)? {
        
        var handler: ((cell: PostCell) -> Void)?
        
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
            handler = { [weak self] (cell) in
                guard let video = post.elements.videos.first else { return }

                let player = AVPlayer(URL: video.asset.URI)
                let videoViewController = AVPlayerViewController()
                videoViewController.player = player
                
                dispatch_async(dispatch_get_main_queue(), { [weak self] in
                    self?.targetPresentationViewController?.presentViewController(videoViewController, animated: true, completion: {
                        videoViewController.player?.play()
                    })
                })
                
            }
            break
        }
        
        return handler
    }
}

// MARK: - Tab Bar Scroll

extension FeedViewController: TabBarTopScrollDelegate {
    
    func scrollToTop() {
        tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
    }
}
