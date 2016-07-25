//
//  CommentViewController.swift
//  higi
//
//  Created by Remy Panicker on 7/18/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class CommentViewController: UIViewController {
    
    @IBOutlet private(set) var tableView: UITableView! {
        didSet {
            tableView.separatorStyle = .None
            
            tableView.estimatedRowHeight = 211.0
            tableView.sectionHeaderHeight = 0.0
            tableView.sectionFooterHeight = 0.0
            
            tableView.register(nibWithCellClass: PostCell.self)
            tableView.register(nibWithCellClass: CommentCell.self)
            tableView.register(cellClass: UITableViewCell.self)
            tableView.register(nibWithCellClass: ActivityIndicatorTableViewCell.self)
        }
    }
    
    private var tableSections: [TableSection : Range<Int>] = [:]
    
    private(set) var userController: UserController!
    private(set) var commentController: CommentController!
}

extension CommentViewController {
    
    func configure(userController: UserController, post: Post) {
        self.userController = userController
        self.commentController = CommentController(post: post)
    }
}

// MARK: - View Lifecycle

extension CommentViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentController.fetchComments({ [weak self] in
            self?.fetchCommentsSuccess()
            }, failure: { [weak self] in
                self?.fetchCommentsFailure()
            })
    }
}

extension CommentViewController {
    
    private func fetchCommentsSuccess() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
    private func fetchCommentsFailure() {
        
    }
}


// MARK: - Table Taxonomy

extension CommentViewController {
    
    enum TableSection  {
        case Post
        case Separator
        case Comment
        case InfiniteScroll
        
        static let allKeys: [TableSection] = [.Post, .Separator, .Comment, .InfiniteScroll]
    }
}

// MARK: - Table Data Source

extension CommentViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        let postRange = 0...0
        let separatorRange = postRange.endIndex...postRange.endIndex
        let commentCount = commentController.comments.count
        let commentRangeEnd = (commentCount > 0) ? separatorRange.endIndex.advancedBy(commentCount - 1) : separatorRange.endIndex
        let commentRange = separatorRange.endIndex...commentRangeEnd
        let infiniteScrollRange = commentRange.endIndex...commentRange.endIndex
        
        tableSections = [
            .Post : postRange,
            .Separator : separatorRange,
            .Comment : commentRange,
            .InfiniteScroll : infiniteScrollRange
        ]
        
        return infiniteScrollRange.endIndex
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        
        if let tableSection = tableSection(forSection: section) {
            switch tableSection {
            case .Comment:
                if let index = commentIndex(forSection: section) {
                    let comment = commentController.comments[index]
                    rowCount += 1
                    rowCount += comment.replies.count
                }
                break
                
            case .Post:
                fallthrough
            case .Separator:
                fallthrough
            case .InfiniteScroll:
                rowCount = 1
            }
        }
        
        return rowCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let tableSection = tableSection(forSection: indexPath.section) else {
            fatalError("Attempted to fetch cell for an invalid section.")
        }
        
        var cell: UITableViewCell?
        
        switch tableSection {
        case .Post:
            cell = postCell(forIndexPath: indexPath)
            break
            
        case .Separator:
            cell = separatorCell(forIndexPath: indexPath)
            break
            
        case .Comment:
            cell = commentCell(forIndexPath: indexPath)
            break
            
        case .InfiniteScroll:
            cell = infiniteScrollCell(forIndexPath: indexPath)
            break
        }
        
        if let cell = cell {
            cell.selectionStyle = .None
            
            return cell
        } else {
            fatalError("Method did not produce a table cell!")
        }
    }
}

// MARK: - Table Delegate

extension CommentViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Must return non-zero value or else there is unwanted padding at top of tableview
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var rowHeight: CGFloat = 0.0
        guard let sectionType = tableSection(forSection: indexPath.section) else { return rowHeight }
        
        switch sectionType {
        case .InfiniteScroll:
            guard let paging = commentController.paging,
                let _ = paging.next else {
                    break
            }
            fallthrough
        case .Post:
            fallthrough
        case .Comment:
            rowHeight = UITableViewAutomaticDimension
            
        case .Separator:
            rowHeight = 15.0
        }
        
        return rowHeight
    }
    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        guard let sectionType = TableSection(rawValue: indexPath.section) else { return }
//        
//        if sectionType == .InfiniteScroll {
//            fetchNext()
//        }
//    }
}

// MARK: - Custom Cells

extension CommentViewController {
    
    private func postCell(forIndexPath indexPath: NSIndexPath) -> PostCell {
//        let postCell = tableView.dequeueReusableCell(withClass: PostCell.self, forIndexPath: indexPath)
//        
        let post = commentController.post
        
        let postCell = FeedViewController().postCell(forTableView: tableView, atIndexPath: indexPath, post: post)
        
        
        
        return postCell
    }
    
    private func separatorCell(forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let separatorCell = tableView.dequeueReusableCell(withClass: UITableViewCell.self, forIndexPath: indexPath)
        separatorCell.backgroundColor = Theme.Color.Primary.whiteGray
        return separatorCell
    }
    
    private func commentCell(forIndexPath indexPath: NSIndexPath) -> CommentCell {
        let commentCell = tableView.dequeueReusableCell(withClass: CommentCell.self, forIndexPath: indexPath)
//        commentCell.actionBar.hidden = true
        
        guard let index = commentIndex(forSection: indexPath.section) else { fatalError() }
        
        if index % 2 == 0 {
            commentCell.backgroundColor = Theme.Color.Primary.white
        } else {
            commentCell.backgroundColor = Theme.Color.Primary.whiteGray
        }
        
        let commentObject = commentController.comments[index]
        
        commentCell.avatarButton.setImage(withMediaAsset: commentObject.user.avatar, forState: .Normal)
        commentCell.primaryLabel.text = "\(commentObject.user.firstName) \(commentObject.user.lastName)"
        commentCell.secondaryLabel.text = commentObject.text
        
        var post = commentController.post
        
        let highFiveTitle = NSLocalizedString("FEED_VIEW_POST_TABLE_CELL_ACTION_BAR_BUTTON_TITLE_HIGH_FIVE", comment: "Title for high-five button within post action bar.")
        let highFive = PostActionBar.Action(type: .HighFive, title: highFiveTitle, imageName: nil, handler: { [weak self] (button, action) in
            
            })
        
        let commentTitle = "Reply"
        let comment = PostActionBar.Action(type: .Comment, title: commentTitle, imageName: nil, handler: { [weak self] (button, action) in
//            self?.commentTapHandler(forPost: post)
            })
        
        let shareTitle = NSLocalizedString("FEED_VIEW_POST_TABLE_CELL_ACTION_BAR_BUTTON_TITLE_SHARE", comment: "Title for share button within post action bar.")
        let share = PostActionBar.Action(type: .Share, title: shareTitle, imageName: nil, handler: { [weak self] (button, action) in
//            self?.shareTapHandler(forPost: post)
            })
        
        let highFiversTitle = post.likeCount == 0 ? "" : String(post.likeCount)
        let highFivers = PostActionBar.Action(type: .HighFivers, title: highFiversTitle, imageName: "action-bar-high-five-icon", handler: { [weak self] (button, action) in
//            self?.highFiversTapHandler(forPost: post)
            })
        
        let commentersTitle = post.commentCount == 0 ? "" : String(post.commentCount)
        let commenters = PostActionBar.Action(type: .Commenters, title: commentersTitle, imageName: "action-bar-chatter-icon", handler: { [weak self] (button, action) in
//            self?.commentersTapHandler(forPost: post)
            })
        
        commentCell.actionBar.configure([highFive, comment, share, highFivers, commenters])
        
        commentCell.actionBar.stackViewLeadingConstraint.constant = -1
        
        return commentCell
    }
    
    private func infiniteScrollCell(forIndexPath indexPath: NSIndexPath) -> ActivityIndicatorTableViewCell {
        return tableView.dequeueReusableCell(withClass: ActivityIndicatorTableViewCell.self, forIndexPath: indexPath)
    }
}

// MARK: - Table Helpers

extension CommentViewController {
    
    private func tableSection(forSection section: Int) -> TableSection? {
        var tableSection: TableSection? = nil
        for key in TableSection.allKeys {
            if let range = tableSections[key] where range.contains(section) {
                tableSection = key
                break
            }
        }
        return tableSection
    }
    
    private func commentIndex(forSection section: Int) -> Int? {
        guard let range = tableSections[.Comment] where range.contains(section) else { return nil }
        
        let commentCount = commentController.comments.count
        if !(commentCount > 0) { return nil }
        
        let index = section - range.startIndex
        if (index >= commentCount) { return nil }
        
        return index
    }
}
