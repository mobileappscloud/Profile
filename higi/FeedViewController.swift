//
//  FeedViewController.swift
//  higi
//
//  Created by Remy Panicker on 6/21/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class FeedViewController: UIViewController {

    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.separatorStyle = .None
            
            tableView.estimatedRowHeight = 211.0
            tableView.sectionHeaderHeight = 0.0
            tableView.sectionFooterHeight = 0.0
            
            tableView.register(nibWithCellClass: PostCell.self)
            tableView.register(cellClass: UITableViewCell.self)
            tableView.register(nibWithCellClass: ActivityIndicatorTableViewCell.self)
        }
    }
    
    private(set) var userController: UserController!
    private(set) var entity: Post.Entity!
    private(set) var entityId: String!
    
    private let feedController = FeedController()
    
    func configure(userController: UserController, entity: Post.Entity, entityId: String) {
        self.userController = userController
        self.entity = entity
        self.entityId = entityId
    }
}

// MARK: - Table

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

extension FeedViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetch()
    }
}

extension FeedViewController {
    
    private func fetch() {
        feedController.fetch(entity, entityId: entityId, success: { [weak self] in
            self?.fetchSuccessHandler()
        }, failure: { [weak self] (error) in
            self?.fetchFailureHandler()
        })
    }
    
    private func fetchNext() {
        
    }
}

extension FeedViewController {
    
    private func fetchSuccessHandler() {
        print("fetch success")
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
    private func fetchFailureHandler() {
        print("fetch failure")
    }
}

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
                let postCell = tableView.dequeueReusableCell(withClass: PostCell.self, forIndexPath: indexPath)
                
                let index = indexPath.row / FeedRowType.Count.rawValue
                let post = feedController.posts[index]
                
                postCell.reset()
                
                // TODO: Remove this fake configuration code
                postCell.headerView.avatarButton.setImage(UIImage(named: "higi-logo"), forState: .Normal)
                postCell.headerView.nameActionLabel.text = "Remy commented on some stuff"
                postCell.headerView.timestampLabel.text = Utility.abbreviatedElapsedTimeUnit(post.publishDate, toDate: NSDate())
                
                postCell.textDescriptionView.titleLabel.text = post.heading
                postCell.textDescriptionView.descriptionLabel.text = post.subheading
                
                let action = PostActionBar.Action(title: "Share", handler: nil)
                postCell.actionBar.configure([action])
                
                cell = postCell
                
            case .Separator:
                let separatorCell = tableView.dequeueReusableCell(withClass: UITableViewCell.self, forIndexPath: indexPath)
                separatorCell.backgroundColor = Theme.Color.Primary.whiteGray
                cell = separatorCell
                
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
    
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        // Must return non-zero value or else there is unwanted padding at top of tableview
//        return CGFloat.min
//    }
//    
//    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return CGFloat.min
//    }
    
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
