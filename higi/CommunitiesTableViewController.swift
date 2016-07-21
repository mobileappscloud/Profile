//
//  CommunitiesTableViewController.swift
//  higi
//
//  Created by Remy Panicker on 6/1/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class CommunitiesTableViewController: UIViewController {

    @IBOutlet private(set) var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.separatorStyle = .None
            
            tableView.estimatedRowHeight = 211.0
            tableView.sectionHeaderHeight = 0.0
            tableView.sectionFooterHeight = 0.0
            
            tableView.register(nibWithCellClass: CommunityListingTableViewCell.self)
            tableView.register(cellClass: UITableViewCell.self)
            tableView.register(nibWithCellClass: ActivityIndicatorTableViewCell.self)
            
            tableView.decelerationRate = UIScrollViewDecelerationRateNormal
        }
    }
    
    lazy private var loadingViewController: UIViewController = {
        let storyboard = UIStoryboard(name: "Communities", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("CommunityListLoading")
        return viewController
    }()
    
    private(set) var userController: UserController!
    private(set) var communitiesController: CommunitiesController!
    
    private(set) weak var delegate: CommunitiesTableViewControllerDelegate?
    private(set) weak var communitySubscriptionDelegate: CommunitySubscriptionDelegate?
    
    func configure(userController: UserController, communitiesController: CommunitiesController, delegate: CommunitiesTableViewControllerDelegate?, communitySubscriptionDelegate: CommunitySubscriptionDelegate?) {
        self.userController = userController
        self.communitiesController = communitiesController
        self.delegate = delegate
        self.communitySubscriptionDelegate = communitySubscriptionDelegate
    }
}

extension CommunitiesTableViewController {
    
    func showPlaceholderView() {
        addChildViewController(loadingViewController)
        loadingViewController.view.alpha = 1.0
        tableView.addSubview(loadingViewController.view, pinToEdges: false)
        loadingViewController.didMoveToParentViewController(self)
    }
    
    func hidePlaceholderView() {
        loadingViewController.willMoveToParentViewController(nil)
        tableView.willRemoveSubview(loadingViewController.view)
        UIView.animateWithDuration(0.2, animations: {
            self.loadingViewController.view.alpha = 0.0
            }, completion: { (success) in
                self.loadingViewController.view.removeFromSuperview()
                self.loadingViewController.didMoveToParentViewController(nil)
        })
    }
}

// MARK: - View Lifecycle

extension CommunitiesTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showPlaceholderView()
        communitiesController.fetch(communitiesFetchSuccess, failure: communitiesFetchFailure)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // TODO: Fix this by setting constraints
        loadingViewController.view.frame = tableView.bounds
        loadingViewController.view.frame.size.height = UIScreen.mainScreen().bounds.height
    }
}

// MARK: - Fetch

extension CommunitiesTableViewController {
    
    func communitiesFetchSuccess() -> Void {
        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            self?.tableView.reloadData()
            self?.hidePlaceholderView()
            })
    }
    
    func communitiesFetchFailure(error: NSError?) -> Void {
        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            self?.tableView.reloadData()
            self?.hidePlaceholderView()
            })
        
        if let error = error {
            
        }
    }
}

// MARK: - Paging

extension CommunitiesTableViewController {
    
    private func fetchNextCommunities() {
        guard let _ = communitiesController.paging?.next else {
            return
        }
        
        communitiesController.fetchNext(fetchNextSuccess, failure: fetchNextFailure)
    }
    
    private func fetchNextSuccess() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
    private func fetchNextFailure(error: NSError?) {
        if let error = error {
            
        }
    }
}

// MARK: - Table

extension CommunitiesTableViewController {
    
    enum TableSection: Int  {
        case Communities
        case InfiniteScroll
        case Count
    }
    
    enum CommunitiesRowType: Int {
        case Content
        case Separator
        case Count
        
        init(indexPath: NSIndexPath) {
            self = CommunitiesRowType(rawValue: indexPath.row % CommunitiesRowType.Count.rawValue)!
        }
        
        func defaultHeight() -> CGFloat {
            switch self {
            case .Content:
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

// MARK: - Table Data Source

extension CommunitiesTableViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TableSection.Count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        guard let sectionType = TableSection(rawValue: section) else {
            return rowCount
        }
        
        switch sectionType {
        case .Communities:
            rowCount = communitiesController.communities.count * CommunitiesRowType.Count.rawValue
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
        case .Communities:
            let rowType = CommunitiesRowType(indexPath: indexPath)
            switch rowType {
            case .Content:
                let communityCell = tableView.dequeueReusableCell(withClass: CommunityListingTableViewCell.self, forIndexPath: indexPath)
                
                let index = indexPath.row / CommunitiesRowType.Count.rawValue
                let community = communitiesController.communities[index]
                
                communityCell.reset()
                
                communityCell.listingView.bannerContainer.imageView.setImage(withMediaAsset: community.header)
                communityCell.listingView.logoMemberContainer.imageView.setImage(withMediaAsset: community.logo)
                communityCell.listingView.configure(community.name, memberCount: community.memberCount)
                
                if !community.isMember {
                    let segueInfo = CommunitiesViewController.Storyboard.Segue.DetailView(community: community, userController: userController, communitySubscriptionDelegate: communitySubscriptionDelegate, join: true)
                    let delegate = CommunityListingButtonDelegate(presentingViewController: self.parentViewController!.parentViewController!, segueIdentifier: CommunitiesViewController.Storyboard.Segue.DetailView.joinIdentifier, userInfo: segueInfo.userInfo())
                    CommunitiesUtility.addJoinButton(toCell: communityCell, delegate: delegate)
                }
                cell = communityCell
                
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
// MARK: - Table Delegate

extension CommunitiesTableViewController: UITableViewDelegate {
    
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
            
        case .Communities:
            let rowType = CommunitiesRowType(indexPath: indexPath)
            rowHeight = rowType.defaultHeight()
            
        case .InfiniteScroll:
            guard let paging = communitiesController.paging,
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
        
        switch sectionType {
            
        case .InfiniteScroll:
            let rowType = InfiniteScrollRowType(indexPath: indexPath)
            switch rowType {
            case .ActivityIndicator:
                fetchNextCommunities()
            case .Count:
                break
            }
            
        case .Communities:
            fallthrough
        case .Count:
            break
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let section = TableSection(rawValue: indexPath.section) else { return }
        
        if section == .Communities {
            let rowType = CommunitiesRowType(indexPath: indexPath)
            if rowType == .Content {
                
                let index = indexPath.row / CommunitiesRowType.Count.rawValue
                let community = communitiesController.communities[index]
                
                delegate?.communitiesTableViewControllerDidTapDetail(self, communitiesController: communitiesController, userController: userController, community: community, communitySubscriptionDelegate: communitySubscriptionDelegate)
            }
        }
    }
}

// MARK: - Cell Configuration

extension CommunitiesTableViewController {
    
    
}

// MARK: - Tab Bar Scroll

extension CommunitiesTableViewController: TabBarTopScrollDelegate {
    
    func scrollToTop() {
        tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
    }
}

// MARK: - Protocol

protocol CommunitiesTableViewControllerDelegate: class {
    
    func communitiesTableViewControllerDidTapDetail(communitiesTableViewController: CommunitiesTableViewController, communitiesController: CommunitiesController, userController: UserController, community: Community, communitySubscriptionDelegate: CommunitySubscriptionDelegate?)
    
    func communitiesTableViewControllerDidTapJoin(communitiesTableViewController: CommunitiesTableViewController, communitiesController: CommunitiesController, userController: UserController, community: Community, communitySubscriptionDelegate: CommunitySubscriptionDelegate?)
}
