//
//  FeedTableViewController.swift
//  higi
//
//  Created by Remy Panicker on 6/21/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class FeedTableViewController: UIViewController {

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
        feedController.refreshTimer?.invalidate()
        feedController.refreshTimer = nil
    }
}

// MARK: - Table Taxonomy

extension FeedTableViewController {
    
    enum TableSection: Int  {
        case Feed
        case InfiniteScroll
        case _count
    }
    
    enum FeedRowType: Int {
        case Post
        case Separator
        case _count
        
        init(indexPath: NSIndexPath) {
            self = FeedRowType(rawValue: indexPath.row % FeedRowType._count.rawValue)!
        }
        
        func defaultHeight() -> CGFloat {
            switch self {
            case .Post:
                return UITableViewAutomaticDimension
            case .Separator:
                return 15.0
            case ._count:
                return 0.0
            }
        }
    }
    
    enum InfiniteScrollRowType: Int {
        case ActivityIndicator
        case _count
        
        init(indexPath: NSIndexPath) {
            self = InfiniteScrollRowType(rawValue: indexPath.row % InfiniteScrollRowType._count.rawValue)!
        }
        
        func defaultHeight() -> CGFloat {
            switch self {
            case .ActivityIndicator:
                return 70.0
            case ._count:
                return 0.0
            }
        }
    }
}

// MARK: - View Lifecycle

extension FeedTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetch()
        scheduleRefresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
}

// MARK: - Fetch Data

extension FeedTableViewController {
    
    private func scheduleRefresh() {
        feedController.scheduleRefresh({ [weak self] in
            self?.handleRefresh()
            })
    }
}

// MARK: Request Data

extension FeedTableViewController {
    
    private func fetch(scrollToTop: Bool = false) {
        feedController.fetch(entity, entityId: entityId, success: { [weak self] in
            self?.fetchSuccessHandler(scrollToTop)
            }, failure: { [weak self] (error) in
                self?.fetchFailureHandler()
            })
    }
    
    private func fetchSuccessHandler(scrollToTop: Bool = false) {
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
        dispatch_async(dispatch_get_main_queue(), {
            self.refreshControl.endRefreshing()
        })
    }
}

extension FeedTableViewController {
    
    private func fetchNext() {
        guard let _ = feedController.paging?.next else {
            return
        }
        
        feedController.fetchNext(fetchNextSuccess, failure: fetchNextFailure)
    }
    
    private func fetchNextSuccess() {

    }
    
    private func fetchNextFailure(error: NSError?) {

    }
}

// MARK: Pull To Refresh

extension FeedTableViewController {
    
    @objc private func handleRefresh() {
        fetch(true)
    }
}

// MARK: - Table

extension FeedTableViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TableSection._count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        guard let sectionType = TableSection(rawValue: section) else {
            return rowCount
        }
        
        switch sectionType {
        case .Feed:
            rowCount = feedController.posts.count * FeedRowType._count.rawValue
        case .InfiniteScroll:
            rowCount = InfiniteScrollRowType._count.rawValue
        case ._count:
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
                
            case ._count:
                break
            }
            
        case .InfiniteScroll:
            let rowType = InfiniteScrollRowType(indexPath: indexPath)
            switch rowType {
            case .ActivityIndicator:
                cell = tableView.dequeueReusableCell(withClass: ActivityIndicatorTableViewCell.self, forIndexPath: indexPath)
                
            case ._count:
                break
            }
            
        case ._count:
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

extension FeedTableViewController: UITableViewDelegate {

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
            
        case ._count:
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

extension FeedTableViewController {
    
    // MARK: Separator
    
    private func separatorCell(forTableView tableView: UITableView, atIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let separatorCell = tableView.dequeueReusableCell(withClass: UITableViewCell.self, forIndexPath: indexPath)
        separatorCell.backgroundColor = Theme.Color.Primary.whiteGray
        return separatorCell
    }
    
    // MARK: - Post
    
    private func postIndex(forIndexPath indexPath: NSIndexPath) -> Int {
        guard indexPath.section == TableSection.Feed.rawValue &&
            FeedRowType(indexPath: indexPath) == .Post else {
            fatalError("This method assumes an indexPath in the Feed section")
        }
        
        return indexPath.row / FeedRowType._count.rawValue
    }
    
    private func postCell(forTableView tableView: UITableView, atIndexPath indexPath: NSIndexPath) -> PostCell {        
        let index = postIndex(forIndexPath: indexPath)
        let post = feedController.posts[index]

        let postCell = PostCellUtility.postCell(forTableView: tableView, atIndexPath: indexPath, post: post, userController: userController, targetPresentationViewController: targetPresentationViewController, cellActionBarItemDelegate: self)
        
        return postCell
    }
}

// MARK: - Table Cell Action Item Delegate

extension FeedTableViewController: TableCellActionBarItemDelegate {
    
    func didTap<T : UITableViewCell where T : ActionBarDisplaying>(button: UIButton, forAction action: ActionBar.Action, inActionBar actionBar: ActionBar, cell: T) {
        
        guard let indexPath = tableView.indexPathForCell(cell) else { return }
        
        let index = postIndex(forIndexPath: indexPath)
        let post = feedController.posts[index]
        
        switch action.type {
        case .Like:
            let newPost = feedController.like(post, forUser: userController.user, success: nil, failure: { [weak self] _ in
                guard let strongSelf = self else { return }
                
                let updatedPost = strongSelf.feedController.locallyUpdate(post, incrementedLikeCount: -1)
                ActionBarUtility.update(cell.actionBar, forContent: updatedPost)
                })
            
            ActionBarUtility.update(cell.actionBar, forContent: newPost)
            
        case .Unlike:
            let newPost = feedController.unlike(post, success: nil, failure: { [weak self] _ in
                guard let strongSelf = self else { return }
                
                let updatedPost = strongSelf.feedController.locallyUpdate(post, incrementedLikeCount: 1)
                ActionBarUtility.update(cell.actionBar, forContent: updatedPost)
                })
            
            ActionBarUtility.update(cell.actionBar, forContent: newPost)
            
        case .Comment:
            fallthrough
        case .Reply:
                ActionBarUtility.navigateToCommentViewController(userController, post: post, targetPresentationViewController: targetPresentationViewController)
            break
            
        case .Share:
            break
            
        case .Likers:
            break
            
        case .Commenters:
            break
        }

    }
}

// MARK: - Tab Bar Scroll

extension FeedTableViewController: TabBarTopScrollDelegate {
    
    func scrollToTop() {
        tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
    }
}
