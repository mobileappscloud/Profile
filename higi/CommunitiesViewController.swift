//
//  CommunitiesViewController.swift
//  higi
//
//  Created by Remy Panicker on 3/25/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class CommunitiesViewController: UIViewController {
    
    struct Storyboard {
        static let name = "Communities"
        
        private struct Scene {
            static let summaryList = "CommunitiesViewControllerStoryboardIdentifier"
            static let expandedList = "CommunitiesExpandedViewControllerStoryboardIdentifier"
            static let loadingView = "CommunityListLoading"
        }
        
        private struct Segue {
            static let expandedList = "CommunitiesExpandedViewControllerSegue"
        }
    }
    
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.separatorStyle = .None
            tableView.allowsSelection = false
            
            tableView.estimatedRowHeight = 211.0
            tableView.sectionFooterHeight = 0.0
            
            tableView.register(nibWithHeaderFooterClass: TitleTableHeaderFooterView.self)
            tableView.register(nibWithCellClass: CommunityListingTableViewCell.self)
            tableView.register(cellClass: UITableViewCell.self)
            tableView.register(nibWithCellClass: ButtonTableViewCell.self)
        }
    }
    
    private var loadingViewController: UIViewController = {
        let storyboard = UIStoryboard(name: Storyboard.name, bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier(Storyboard.Scene.loadingView)
        return viewController
    }()
    
    lazy private var joinedCommunitiesController: CommunitiesController = {
        let controller = JoinedCommunitiesController()
        return controller
    }()
    
    lazy private var unjoinedCommunitiesController: CommunitiesController = {
        let controller = JoinedCommunitiesController()
        return controller
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("COMMUNITIES_VIEW_TITLE", comment: "Title for communities view.")
        
        view.addSubview(loadingViewController.view, pinToEdges: true)

        joinedCommunitiesController.fetch(communitiesFetchSuccess, failure: communitiesFetchFailure)
        unjoinedCommunitiesController.fetch(communitiesFetchSuccess, failure: communitiesFetchFailure)
    }
}

extension CommunitiesViewController {
    
    func communitiesFetchSuccess() -> Void {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            
            let duration: NSTimeInterval = 1.0
            UIView.animateWithDuration(duration, animations: {
                self.loadingViewController.view.alpha = 0.0
                }, completion: { completed in
                self.loadingViewController.view.removeFromSuperview()
            })
        })
    }
    
    func communitiesFetchFailure(error: NSError?) -> Void {
        if let error = error {
            print(error)
        }
    }
}

// MARK: - Table

extension CommunitiesViewController {
    
    private enum TableSection: Int  {
        case YourCommunities
        case MoreCommunities
        case Count
        
        func maxCommunityCount() -> Int {
            return 10
        }
        
        func maxRowIndex() -> Int {
            return maxCommunityCount() - 1
        }
        
        func defaultHeight() -> CGFloat {
            switch self {
            case .YourCommunities:
                fallthrough
            case .MoreCommunities:
                return 60.0
            case .Count:
                return 0.0
            }
        }
    }
    
    private enum CommunitiesRowType: Int {
        case Content
        case Separator
        case ViewAdditional
        case Count
        
        init(indexPath: NSIndexPath) {
            self = CommunitiesRowType(rawValue: indexPath.row % CommunitiesRowType.Count.rawValue)!
        }
        
        func defaultHeight() -> CGFloat {
            switch self {
            case .Content:
                return UITableViewAutomaticDimension
            case .Separator:
                return 30.0
            case .ViewAdditional:
                return 60.0
            case .Count:
                return 0.0
            }
        }
    }
}

// MARK: - Table Data Source

extension CommunitiesViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TableSection.Count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        guard let sectionType = TableSection(rawValue: section) else {
            return rowCount
        }
        
        switch sectionType {
        case .YourCommunities:
            let communityCount = min(joinedCommunitiesController.communities.count, sectionType.maxCommunityCount())
            rowCount = communityCount * CommunitiesRowType.Count.rawValue
        case .MoreCommunities:
            let communityCount = min(unjoinedCommunitiesController.communities.count, sectionType.maxCommunityCount())
            rowCount = communityCount * CommunitiesRowType.Count.rawValue
        case .Count:
            break
        }
        return rowCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let sectionType = TableSection(rawValue: indexPath.section) else {
            fatalError("Invalid table section")
        }
        
        if self.tableView(tableView, heightForRowAtIndexPath: indexPath) == 0.0 {
            return tableView.dequeueReusableCell(withClass: UITableViewCell.self, forIndexPath: indexPath)
        }
        
        var cell: UITableViewCell?
        
        switch sectionType {
            
        case .YourCommunities:
            let rowType = CommunitiesRowType(indexPath: indexPath)
            switch rowType {
            case .Content:
                cell = joinedCell(forIndexPath: indexPath)
                
            case .Separator:
                cell = separatorCell(forIndexPath: indexPath)
                
            case .ViewAdditional:
                cell = viewAdditionalCell(forIndexPath: indexPath)
                
            case .Count:
                break
            }
            
        case .MoreCommunities:
            let rowType = CommunitiesRowType(indexPath: indexPath)
            switch rowType {
            case .Content:
                cell = unjoinedCell(forIndexPath: indexPath)
                
            case .Separator:
                cell = separatorCell(forIndexPath: indexPath)
                
            case .ViewAdditional:
                cell = viewAdditionalCell(forIndexPath: indexPath)
                
            case .Count:
                break
            }
            
        case .Count:
            break
        }

        if let cell = cell {
            return cell
        } else {
            fatalError("Method must produce a cell!")
        }
    }
}

// MARK: - Table Delegate

extension CommunitiesViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionType = TableSection(rawValue: section) else {
            fatalError("Invalid table section")
        }

        return sectionType.defaultHeight()
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionType = TableSection(rawValue: section) else {
            fatalError("Invalid table section")
        }
        
        var view: UITableViewHeaderFooterView? = nil
        
        switch sectionType {
        case .YourCommunities:
            let title = NSLocalizedString("COMMUNITIES_VIEW_TABLE_SECTION_HEADER_YOUR_COMMUNITIES", comment: "Table section header for joined communities on Community List View.")
            view = communitySectionHeader(title)
            
        case .MoreCommunities:
            let title = NSLocalizedString("COMMUNITIES_VIEW_TABLE_SECTION_HEADER_MORE_COMMUNITIES", comment: "Table section header for unjoined communities on Community List View.")
            view = communitySectionHeader(title)
            
        case .Count:
            break
        }
        
        return view
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var rowHeight: CGFloat = 0.0
        guard let sectionType = TableSection(rawValue: indexPath.section) else { return rowHeight }
        
        switch sectionType {
            
        case .YourCommunities:
            let rowType = CommunitiesRowType(indexPath: indexPath)
            switch rowType {
            case .Content:
                rowHeight = rowType.defaultHeight()
            case .Separator:
                let isMaxRow = (indexPath.row / CommunitiesRowType.Count.rawValue) == sectionType.maxRowIndex()
                rowHeight =  isMaxRow ? 0.0 : rowType.defaultHeight()
            case .ViewAdditional:
                let showAdditional = joinedCommunitiesController.communities.count > sectionType.maxCommunityCount()
                let isMaxRow = (indexPath.row / CommunitiesRowType.Count.rawValue) == sectionType.maxRowIndex()
                rowHeight = (showAdditional && isMaxRow) ? rowType.defaultHeight() : 0.0
                
            case .Count:
                break
            }
            
        case .MoreCommunities:
            let rowType = CommunitiesRowType(indexPath: indexPath)
            switch rowType {
            case .Content:
                rowHeight = rowType.defaultHeight()
            case .Separator:
                let isMaxRow = (indexPath.row / CommunitiesRowType.Count.rawValue) == sectionType.maxRowIndex()
                rowHeight =  isMaxRow ? 0.0 : rowType.defaultHeight()
            case .ViewAdditional:
                let showAdditional = unjoinedCommunitiesController.communities.count > sectionType.maxCommunityCount()
                let isMaxRow = (indexPath.row / CommunitiesRowType.Count.rawValue) == sectionType.maxRowIndex()
                rowHeight = (showAdditional && isMaxRow) ? rowType.defaultHeight() : 0.0
                
            case .Count:
                break
            }
            
        case .Count:
            break
        }
        
        return rowHeight
    }
}

// MARK: - Custom Section

extension CommunitiesViewController {
    
    private func communitySectionHeader(title: String) -> TitleTableHeaderFooterView {
        let header = tableView.dequeueResuableHeaderFooterView(withClass: TitleTableHeaderFooterView.self)!
        header.titleLabel.text = title
        header.contentView.backgroundColor = Theme.Color.Primary.whiteGray
        header.contentView.alpha = 0.8
        return header
    }
}

// MARK: - Custom Cells

extension CommunitiesViewController {
    
    private func joinedCell(forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let index = indexPath.row / CommunitiesRowType.Count.rawValue
        let community = joinedCommunitiesController.communities[index]
        return cell(community, indexPath: indexPath)
    }
    
    private func unjoinedCell(forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let index = indexPath.row / CommunitiesRowType.Count.rawValue
        let community = unjoinedCommunitiesController.communities[index]
        return cell(community, indexPath: indexPath)
    }
    
    private func cell(community: Community, indexPath: NSIndexPath) -> CommunityListingTableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: CommunityListingTableViewCell.self, forIndexPath: indexPath)
        cell.layer.cornerRadius = 5.0
        
        cell.reset()
        
        cell.listingView.configure(community.name, memberCount: community.memberCount)
        if let bannerURL = community.header?.URI {
            cell.listingView.headerImageView.setImageWithURL(bannerURL)
        }
        if let logoURL = community.logo?.URI {
            cell.listingView.logoImageView.setImageWithURL(logoURL)
        }
        
        if community.isMember {
            let title = NSLocalizedString("COMMUNITY_LISTING_TABLE_CELL_ACCESSORY_BUTTON_TITLE_JOIN", comment: "Title for accessory button on community listing table cell to join a community.")
            cell.configureAccessoryButton(title, titleColor: UIColor.whiteColor(), backgroundColor: Theme.Color.primary, handler: { (cell) in
                
            })
        }

        return cell
    }
    
    private func separatorCell(forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self, forIndexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    private func viewAdditionalCell(forIndexPath indexPath: NSIndexPath) -> ButtonTableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ButtonTableViewCell.self, forIndexPath: indexPath)
        
        guard let sectionType = TableSection(rawValue: indexPath.section) else {
            fatalError("Invalid table section.")
        }
        
        let title = sectionType == .YourCommunities ? NSLocalizedString("COMMUNITIES_LIST_VIEW_ADDITIONAL_BUTTON_TITLE_YOUR_COMMUNITIES", comment: "Title for button to view expanded list of your communities.") :
            NSLocalizedString("COMMUNITIES_LIST_VIEW_ADDITIONAL_BUTTON_TITLE_MORE_COMMUNITIES", comment: "Title for button to view expanded list of more communities.")
        cell.button.setTitle(title, forState: .Normal)
        cell.tapHandler = { [weak self] (cell) in
            let userInfo = ["sectionType" : sectionType.rawValue] as AnyObject
            self?.performSegueWithIdentifier(Storyboard.Segue.expandedList, sender: userInfo)
        }
        return cell
    }
}

// MARK: - Navigation

extension CommunitiesViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.Segue.expandedList {
            guard let viewController = segue.destinationViewController as? CommunitiesExpandedViewController,
                let userInfo = sender as? [String : Int],
                let rawValue = userInfo["sectionType"],
                let sectionType = TableSection(rawValue: rawValue) else { return }
            
            let title: String
            let controller: CommunitiesController
            if sectionType == .YourCommunities {
                title = NSLocalizedString("COMMUNITIES_EXPANDED_LIST_TITLE_YOUR_COMMUNITIES", comment: "Title for expanded list view of your communities.")
                controller = joinedCommunitiesController
            } else {
                title = NSLocalizedString("COMMUNITIES_EXPANDED_LIST_TITLE_MORE_COMMUNITIES", comment: "Title for expanded list view of more communities.")
                controller = unjoinedCommunitiesController
            }
            
            viewController.title = title
            viewController.controller = controller
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
            self.navigationController?.delegate = self
        }
    }
}

extension CommunitiesViewController: UINavigationControllerDelegate {
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        guard let viewController = viewController as? CommunitiesExpandedViewController else { return }
        
        let section = CommunitiesExpandedViewController.TableSection.Communities.rawValue
        let row = TableSection.YourCommunities.maxCommunityCount() * CommunitiesRowType.Count.rawValue
        let indexPath = NSIndexPath(forRow: row, inSection: section)
        viewController.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
    }
}
