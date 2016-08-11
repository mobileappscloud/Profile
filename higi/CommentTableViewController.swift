//
//  CommentTableViewController.swift
//  higi
//
//  Created by Remy Panicker on 7/18/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class CommentTableViewController: UIViewController {
    
    private static let maximumCharacterCount = 8000
    
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
    
    private lazy var textInputView: TextInputView = {
        let height: CGFloat = 50.0
        let width = self.view.bounds.width
        let textInputView = TextInputView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        textInputView.layer.borderWidth = 1.0
        textInputView.layer.borderColor = Theme.Color.Content.Comment.TextInput.borderColor.CGColor
        
        textInputView.textView.delegate = self
        textInputView.textView.maximumNumberOfLines = 4
        textInputView.textView.placeholder = self.placeholder
        textInputView.textView.cornerRadius = 5.0
        textInputView.textView.borderWidth = 1.0
        textInputView.textView.borderColor = Theme.Color.Content.Comment.TextInput.borderColor
        
        textInputView.rightButton.tintColor = Theme.Color.Content.Comment.TextInput.buttonTintColor
        textInputView.rightButton.enabled = self.commentIsValid(textInputView.textView.text)
        textInputView.buttonHandler = self.textInputViewButtonHandler
        
        return textInputView
    }()
    
    @IBOutlet var textInputViewBottomLayoutConstraint: NSLayoutConstraint!
    
    private var placeholder: String {
        get {
            let commentPlaceholder = NSLocalizedString("COMMENT_VIEW_TEXT_INPUT_PLACEHOLDER_FOR_COMMENT", comment: "Placeholder for entering a comment in the text input field on comment view.")
            let replyPlaceholder = NSLocalizedString("COMMENT_VIEW_TEXT_INPUT_PLACEHOLDER_FOR_REPLY", comment: "Placeholder for entering a reply in the text input field on comment view.")
            let isComment = commentController.targetInteractiveContent is Post
            return isComment ? commentPlaceholder : replyPlaceholder
        }
    }
    
    private var tableSections: [TableSection : Range<Int>] = [:]
    
    private(set) var userController: UserController!
    private(set) var commentController: CommentController!
}

// MARK: - Configuration

extension CommentTableViewController {
    
    func configure(userController: UserController, post: Post) {
        self.userController = userController
        self.commentController = CommentController(post: post, targetInteractiveContent: post)
    }
}

// MARK: - Docked Text Input View

extension CommentTableViewController {
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        return textInputView
    }
}

// MARK: - View Lifecycle

extension CommentTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentController.fetchComments({ [weak self] in
            self?.fetchCommentsSuccess()
            }, failure: { [weak self] in
                self?.fetchCommentsFailure()
            })
    }
}

// MARK: - Fetch Comments

extension CommentTableViewController {
 
    private func fetchCommentsSuccess() {
        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            self?.tableView.reloadData()
        })
    }
    
    private func fetchCommentsFailure() {
        
    }
}


// MARK: - Table Taxonomy

extension CommentTableViewController {
    
    enum TableSection  {
        case Post
        case Separator
        case Comment
        case InfiniteScroll
        
        static let allKeys: [TableSection] = [.Post, .Separator, .Comment, .InfiniteScroll]
    }
}

// MARK: - Table Data Source

extension CommentTableViewController: UITableViewDataSource {
    
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
                if let index = commentSection(forTableSection: section) {
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

extension CommentTableViewController: UITableViewDelegate {
    
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

extension CommentTableViewController {
    
    private func postCell(forIndexPath indexPath: NSIndexPath) -> PostCell {
        let post = commentController.post
        let postCell = PostCellUtility.postCell(forTableView: tableView, atIndexPath: indexPath, post: post, userController: userController, targetPresentationViewController: self, cellActionBarItemDelegate: self)
        return postCell
    }
    
    private func separatorCell(forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let separatorCell = tableView.dequeueReusableCell(withClass: UITableViewCell.self, forIndexPath: indexPath)
        separatorCell.backgroundColor = Theme.Color.Primary.whiteGray
        return separatorCell
    }
    
    private func commentCell(forIndexPath indexPath: NSIndexPath) -> CommentCell {
        let commentCell = tableView.dequeueReusableCell(withClass: CommentCell.self, forIndexPath: indexPath)
        
        commentCell.reset()
        
        let comment = self.comment(forIndexPath: indexPath)
        
        commentCell.avatarButton.setImage(withMediaAsset: comment.user.avatar, forState: .Normal)
        
        let authorName = NSPersonNameComponentsFormatter.localizedMediumStyle(withFirstName: comment.user.firstName, lastName: comment.user.lastName)!
        let elapsedTime = Utility.shortElapsedTimeAgo(comment.date)!
        let attrString = attributedString(authorName, elapsedTime: elapsedTime)
        commentCell.primaryLabel.attributedText = attrString
        
        commentCell.secondaryLabel.text = comment.text
        
        let actions = ActionBarUtility.actions(forContent: comment)
        commentCell.actionBar.configure(actions)
        commentCell.cellActionBarItemDelegate = self
        
        if comment.isReply {
            commentCell.backgroundColor = Theme.Color.Primary.whiteGray
        } else {
            commentCell.backgroundColor = Theme.Color.Primary.white
        }
        commentCell.actionBar.stackViewLeadingConstraint.constant = -1
        
        return commentCell
    }
    
    private func attributedString(authorName: String, elapsedTime: String) -> NSAttributedString {
        let format = NSLocalizedString("COMMENT_CELL_HEADER_LABEL_AUTHOR_TIME_FORMAT", comment: "Format of text displayed in header label of comment for an author and time elapsed since publish date.")
        let string = String(format: format, arguments: [authorName, elapsedTime])
        
        let authorNameFont = UIFont.boldSystemFontOfSize(16.0)
        let timeFont = UIFont.italicSystemFontOfSize(14.0)
        
        let attrString = NSMutableAttributedString(string: string)
        
        attrString.addAttributes([NSFontAttributeName : authorNameFont], range: (string as NSString).rangeOfString(authorName))
        attrString.addAttributes([
            NSFontAttributeName : timeFont,
            NSForegroundColorAttributeName : Theme.Color.Primary.silver
            ],
                                 range: (string as NSString).rangeOfString(elapsedTime))
        
        return attrString.copy() as! NSAttributedString
    }
    
    private func infiniteScrollCell(forIndexPath indexPath: NSIndexPath) -> ActivityIndicatorTableViewCell {
        return tableView.dequeueReusableCell(withClass: ActivityIndicatorTableViewCell.self, forIndexPath: indexPath)
    }
}

// MARK: - Table Helpers

extension CommentTableViewController {
    
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
    
    private func commentSection(forTableSection section: Int) -> Int? {
        guard let range = tableSections[.Comment] where range.contains(section) else { return nil }
        
        let commentCount = commentController.comments.count
        if !(commentCount > 0) { return nil }
        
        let commentSection = section - range.startIndex
        if (commentSection >= commentCount) { return nil }
        
        return commentSection
    }
    
    private func comment(forIndexPath indexPath: NSIndexPath) -> Comment {
        guard let commentSection = commentSection(forTableSection: indexPath.section) else { fatalError() }
        
        let primaryComment = commentController.comments[commentSection]
        let comment: Comment
        if indexPath.row == 0 {
            comment = primaryComment
        } else {
            // Since each comment is it's own table section, the first row in a section will be the comment. All replies would be populated underneath the comment. Subtract one from the indexPath's row to take into account the comment row.
            let replyIndex = indexPath.row - 1
            comment = primaryComment.replies[replyIndex]
        }
        return comment
    }
    
    private func content<T: ContentInteractable>(forIndexPath indexPath: NSIndexPath) -> T {
        guard let tableSection = tableSection(forSection: indexPath.section) where tableSection == .Post || tableSection == .Comment else {
            fatalError("Attempted to fetch cell for an invalid section.")
        }
        
        if tableSection == .Post {
            return commentController.post as! T
        } else {
            return comment(forIndexPath: indexPath) as! T
        }
    }
}

// MARK: - Table Cell Action Item Delegate

extension CommentTableViewController: TableCellActionBarItemDelegate {
    
    func didTap<T : UITableViewCell where T : ActionBarDisplaying>(button: UIButton, forAction action: ActionBar.Action, inActionBar actionBar: ActionBar, cell: T) {
        
        guard let indexPath = tableView.indexPathForCell(cell) else { return }
        guard let tableSection = tableSection(forSection: indexPath.section) where tableSection == .Post || tableSection == .Comment else {
            fatalError("Attempted to fetch cell for an invalid section.")
        }

        switch action.type {
        case .Like:
            fallthrough
        case .Unlike:
            if tableSection == .Post {
                let content = self.content(forIndexPath: indexPath) as Post
                updateLike(content, forCell: cell, actionType: action.type)
            } else {
                let content = self.content(forIndexPath: indexPath) as Comment
                updateLike(content, forCell: cell, actionType: action.type)
            }
            
        case .Comment:
            fallthrough
        case .Reply:
            if tableSection == .Post {
                let content = self.content(forIndexPath: indexPath) as Post
                comment(onContent: content, atIndexPath: indexPath)
            } else {
                let content = self.content(forIndexPath: indexPath) as Comment
                comment(onContent: content, atIndexPath: indexPath)
            }
            
        case .Share:
            break
            
        case .Likers:
            break
            
        case .Commenters:
            break
        }
    }
    
    private func comment(onContent content: ContentInteractable, atIndexPath indexPath: NSIndexPath) {
        commentController.targetInteractiveContent = content
        textInputView.textView.placeholder = placeholder
        textInputView.textView.becomeFirstResponder()
    }
    
    private func updateLike<T: ContentInteractable, U : UITableViewCell where U : ActionBarDisplaying>(content: T, forCell cell: U, actionType: ActionBar.Action.Types) {
        
        if actionType == .Like {
            like(content, forCell: cell)
        } else if actionType == .Unlike {
            unlike(content, forCell: cell)
        }
    }
    
    private func like<T: ContentInteractable, U : UITableViewCell where U : ActionBarDisplaying>(content: T, forCell cell: U) {
        let newContent = commentController.like(content, forUser: userController.user, success: nil, failure: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            let updatedContent = strongSelf.commentController.locallyUpdate(content, incrementedLikeCount: -1)
            ActionBarUtility.update(cell.actionBar, forContent: updatedContent)
            })
        
        ActionBarUtility.update(cell.actionBar, forContent: newContent)
    }
    
    private func unlike<T: ContentInteractable, U : UITableViewCell where U : ActionBarDisplaying>(content: T, forCell cell: U) {
        let newContent = commentController.unlike(content, success: nil, failure: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            let updatedContent = strongSelf.commentController.locallyUpdate(content, incrementedLikeCount: 1)
            ActionBarUtility.update(cell.actionBar, forContent: updatedContent)
            })
        
        ActionBarUtility.update(cell.actionBar, forContent: newContent)
    }
}

// MARK: - Text View Delegate

extension CommentTableViewController: UITextViewDelegate {
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let currentCharacterCount = textView.text.characters.count
        
        // Current text already meets or exceeds maximum character count
        if currentCharacterCount >= CommentTableViewController.maximumCharacterCount { return false }
        
        // Replacement text will exceed maximum character count
        if (currentCharacterCount + text.characters.count) >= CommentTableViewController.maximumCharacterCount { return false }
        
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        enableRightButton(forTextView: textView)
    }
    
    private func enableRightButton(forTextView textView: UITextView) {
        if commentIsValid(textView.text) {
            if !textInputView.rightButton.enabled {
                dispatch_async(dispatch_get_main_queue(), {
                    self.textInputView.rightButton.enabled = true
                })
            }
        } else {
            if textInputView.rightButton.enabled {
                dispatch_async(dispatch_get_main_queue(), {
                    self.textInputView.rightButton.enabled = false
                })
            }
        }
    }
}

// MARK: - Post Comment

extension CommentTableViewController {
    
    private func textInputViewButtonHandler(sender: UIButton) {
        let text = textInputView.textView.text
        
        guard commentIsValid(text) else { return }
        
        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            self?.toggleElements(false)
            })
        
        commentController.postComment(text, user: userController.user, success: { [weak self] in
            self?.commentPostSuccess()
            }, failure: { [weak self] in
                self?.commentPostFailure()
            })
    }
    
    private func commentPostSuccess() {
        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            self?.textInputView.textView.text = ""
            self?.toggleElements(true)
            self?.tableView.reloadData()
            self?.textInputView.textView.resignFirstResponder()
            })
    }
    
    private func commentPostFailure() {
        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            self?.toggleElements(true)
            })
    }
    
    private func toggleElements(canInteract: Bool) {
        textInputView.rightButton.enabled = canInteract
        textInputView.textView.editable = canInteract
    }
}

extension CommentTableViewController {
    
    private func commentIsValid(comment: String) -> Bool {
        let trimmedText = comment.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if trimmedText.isEmpty || trimmedText.characters.count >= CommentTableViewController.maximumCharacterCount {
            return false
        }
        
        return true
    }
}
