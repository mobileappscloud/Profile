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
            struct ExpandedList {
                static let identifier = "CommunitiesExpandedViewControllerSegue"
                let sectionType: TableSection
                
                init(sectionType: TableSection) {
                    self.sectionType = sectionType
                }
                
                func userInfo() -> AnyObject {
                    return ["sectionType" : sectionType.rawValue]
                }
                
                init?(userInfo: AnyObject?) {
                    guard let userInfo = userInfo as? NSDictionary,
                        let sectionTypeRawValue = userInfo["sectionType"] as? TableSection.RawValue,
                        let sectionType = TableSection(rawValue: sectionTypeRawValue) else { return nil }
                    
                    self.sectionType = sectionType
                }
            }
            
            struct DetailView {
                static let identifier = "CommunityDetailViewControllerSegue"
                let community: Community
                var join: Bool = false
                
                init(community: Community, join: Bool = false) {
                    self.community = community
                    self.join = join
                }
                
                func userInfo() -> AnyObject {
                    return ["community" : community, "join" : join]
                }
                
                init?(userInfo: AnyObject?) {
                    guard let userInfo = userInfo as? NSDictionary,
                        let community = userInfo["community"] as? Community,
                        let join = userInfo["join"] as? Bool else { return nil }
                    
                    self.community = community
                    self.join = join
                }
            }
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
    
    lazy private var joinedController: CommunitiesController = {
        let controller = CommunitiesController(filter: .Joined)
        return controller
    }()
    
    lazy private var unjoinedController: CommunitiesController = {
        let controller = CommunitiesController(filter: .Unjoined)
        return controller
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("COMMUNITIES_VIEW_TITLE", comment: "Title for communities view.")
        
        view.addSubview(loadingViewController.view, pinToEdges: true)

        joinedController.fetch(communitiesFetchSuccess, failure: communitiesFetchFailure)
        unjoinedController.fetch(communitiesFetchSuccess, failure: communitiesFetchFailure)
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
            let communityCount = min(joinedController.communities.count, sectionType.maxCommunityCount())
            rowCount = communityCount * CommunitiesRowType.Count.rawValue
        case .MoreCommunities:
            let communityCount = min(unjoinedController.communities.count, sectionType.maxCommunityCount())
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
                cell = communityCell(tableView, indexPath: indexPath, controller: joinedController)
                
            case .Separator:
                cell = CommunitiesTableUtility.separatorCell(tableView, forIndexPath: indexPath)
                
            case .ViewAdditional:
                cell = viewAdditionalCell(forIndexPath: indexPath)
                
            case .Count:
                break
            }
            
        case .MoreCommunities:
            let rowType = CommunitiesRowType(indexPath: indexPath)
            switch rowType {
            case .Content:
                cell = communityCell(tableView, indexPath: indexPath, controller: unjoinedController)
                
            case .Separator:
                cell = CommunitiesTableUtility.separatorCell(tableView, forIndexPath: indexPath)
                
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
                fallthrough
        case .MoreCommunities:
            let rowType = CommunitiesRowType(indexPath: indexPath)
            switch rowType {
            case .Content:
                rowHeight = rowType.defaultHeight()
            case .Separator:
                let isMaxRow = (indexPath.row / CommunitiesRowType.Count.rawValue) == sectionType.maxRowIndex()
                rowHeight =  isMaxRow ? 0.0 : rowType.defaultHeight()
            case .ViewAdditional:
                let controller = (sectionType == .YourCommunities) ? joinedController : unjoinedController
                let showAdditional = controller.communities.count > sectionType.maxCommunityCount()
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
    
    private func communityCell(tableView: UITableView, indexPath: NSIndexPath, controller: CommunitiesController) -> CommunityListingTableViewCell {
        let index = indexPath.row / CommunitiesRowType.Count.rawValue
        let community = controller.communities[index]
        
        let cell = CommunitiesTableUtility.cell(tableView, community: community, indexPath: indexPath)
        cell.interactiveContentTapHandler = { (cell) in
            let segue = Storyboard.Segue.DetailView(community: community)
            self.performSegueWithIdentifier(Storyboard.Segue.DetailView.identifier, sender: segue.userInfo())
        }
        
        if community.isMember {
//            let title = NSLocalizedString("COMMUNITY_LISTING_TABLE_CELL_ACCESSORY_BUTTON_TITLE_JOIN", comment: "Title for accessory button on community listing table cell to join a community.")
//            let segueInfo = Storyboard.Segue.DetailView(community: community, join: true)
//            self.performSegueWithIdentifier(Storyboard.Segue.DetailView.identifier, sender: segueInfo.userInfo())            
        }
        
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
            let segue = Storyboard.Segue.ExpandedList(sectionType: sectionType)
            self?.performSegueWithIdentifier(Storyboard.Segue.ExpandedList.identifier, sender: segue.userInfo())
        }
        return cell
    }
}

// MARK: - Navigation

extension CommunitiesViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.Segue.ExpandedList.identifier {
            guard let viewController = segue.destinationViewController as? CommunitiesExpandedViewController,
                let userInfo = Storyboard.Segue.ExpandedList(userInfo: sender) else { return }
            
            let title: String
            let controller: CommunitiesController
            if userInfo.sectionType == .YourCommunities {
                title = NSLocalizedString("COMMUNITIES_EXPANDED_LIST_TITLE_YOUR_COMMUNITIES", comment: "Title for expanded list view of your communities.")
                controller = joinedController
            } else {
                title = NSLocalizedString("COMMUNITIES_EXPANDED_LIST_TITLE_MORE_COMMUNITIES", comment: "Title for expanded list view of more communities.")
                controller = unjoinedController
            }
            
            viewController.title = title
            viewController.controller = controller
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
            self.navigationController?.delegate = self
            
        } else if segue.identifier == Storyboard.Segue.DetailView.identifier {
            guard let viewController = segue.destinationViewController as? CommunityDetailViewController,
                let userInfo = Storyboard.Segue.DetailView(userInfo: sender) else { return }
            
            viewController.community = userInfo.community
        }
    }
}

extension CommunitiesViewController: UINavigationControllerDelegate {
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        
        // Scroll the expanded list view so that the last viewed community cell is at the top of the screen
        guard let viewController = viewController as? CommunitiesExpandedViewController else { return }
        
        let section = CommunitiesExpandedViewController.TableSection.Communities.rawValue
        let row = TableSection.YourCommunities.maxCommunityCount() * CommunitiesRowType.Count.rawValue
        let indexPath = NSIndexPath(forRow: row, inSection: section)
        viewController.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
    }
}

extension CommunitiesViewController: TabBarTopScrollDelegate {
    
    func scrollToTop() {
        tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
    }
}
