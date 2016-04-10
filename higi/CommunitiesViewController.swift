//
//  CommunitiesViewController.swift
//  higi
//
//  Created by Remy Panicker on 3/25/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class CommunitiesViewController: UIViewController {
    
    private struct Storyboard {
        private struct Identifier {
            static var loadingView = "CommunityListLoading"
        }
    }
    
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.separatorStyle = .None
            tableView.allowsSelection = false
            tableView.clipsToBounds = false
            tableView.layer.masksToBounds = false
            
            tableView.estimatedRowHeight = 211.0
            tableView.sectionFooterHeight = 0.0
            
            tableView.register(nibWithHeaderFooterClass: TitleTableHeaderFooterView.self)
            tableView.register(nibWithCellClass: CommunityListingTableViewCell.self)
            tableView.register(cellClass: UITableViewCell.self)
            tableView.register(nibWithCellClass: ButtonTableViewCell.self)
        }
    }
    
    private var loadingViewController: UIViewController = {
        let viewController = UIStoryboard(name: "Communities", bundle: nil).instantiateViewControllerWithIdentifier(Storyboard.Identifier.loadingView)
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
    
    lazy private var yourCommunitiesTableHandler: YourCommunitiesTableHandler = {
        let handler = YourCommunitiesTableHandler(tableView: self.tableView, controller: self.joinedCommunitiesController)
        return handler
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
        
        func maxRowCount() -> Int {
            switch self {
            case .YourCommunities:
                fallthrough
            case .MoreCommunities:
                return 10
            case .Count:
                return 0
            }
        }
        
        func maxRowIndex() -> Int {
            return maxRowCount() - 1
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
        
        init?(indexPath: NSIndexPath) {
            self = CommunitiesRowType(rawValue: indexPath.row % CommunitiesRowType.Count.rawValue) ?? .Count
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
            let communityCount = min(joinedCommunitiesController.communities.count, sectionType.maxRowCount())
            rowCount = communityCount * CommunitiesRowType.Count.rawValue
        case .MoreCommunities:
            let communityCount = min(unjoinedCommunitiesController.communities.count, sectionType.maxRowCount())
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
            guard let rowType = CommunitiesRowType(indexPath: indexPath) else {
                fatalError("Invalid row type for Your Communities section.")
            }
            
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
            guard let rowType = CommunitiesRowType(indexPath: indexPath) else {
                fatalError("Invalid row type for More Communities section.")
            }
            
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

// MARK: - Custom Cells

extension CommunitiesViewController {
    
    private func joinedCell(forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: CommunityListingTableViewCell.self, forIndexPath: indexPath)
        cell.layer.cornerRadius = 5.0
        
        let index = indexPath.row / CommunitiesRowType.Count.rawValue
        let community = joinedCommunitiesController.communities[index]
        
        cell.reset()
        
        cell.listingView.configure(community.name, memberCount: community.memberCount)
        if let bannerURL = community.header?.URI {
            cell.listingView.headerImageView.setImageWithURL(bannerURL)
        }
        if let logoURL = community.logo?.URI {
            cell.listingView.logoImageView.setImageWithURL(logoURL)
        }
        
        return cell
    }
    
    private func unjoinedCell(forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: CommunityListingTableViewCell.self, forIndexPath: indexPath)
        cell.layer.cornerRadius = 5.0
        
        let index = indexPath.row / CommunitiesRowType.Count.rawValue
        let community = unjoinedCommunitiesController.communities[index]
        
        cell.reset()
        
        cell.listingView.configure(community.name, memberCount: community.memberCount)
        if let bannerURL = community.header?.URI {
            cell.listingView.headerImageView.setImageWithURL(bannerURL)
        }
        if let logoURL = community.logo?.URI {
            cell.listingView.logoImageView.setImageWithURL(logoURL)
        }

        cell.configureAccessoryButton("Join", titleColor: UIColor.whiteColor(), backgroundColor: Theme.Color.primary, handler: { (cell) in
            
        })
        
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
        
        let title = sectionType == .YourCommunities ? "View All" : "View More"
        cell.button.setTitle(title, forState: .Normal)
        cell.tapHandler = { [weak self] (cell) in
            let viewController = UIViewController()
            viewController.title = sectionType == .YourCommunities ? "Your Communities" : "More Communities"
            dispatch_async(dispatch_get_main_queue(), {
                self?.navigationController?.pushViewController(viewController, animated: true)
            })
        }
        return cell
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
            guard let rowType = CommunitiesRowType(indexPath: indexPath) else { return rowHeight }
            switch rowType {
            case .Content:
                rowHeight = rowType.defaultHeight()
            case .Separator:
                let isMaxRow = (indexPath.row / CommunitiesRowType.Count.rawValue) == sectionType.maxRowIndex()
                rowHeight =  isMaxRow ? 0.0 : rowType.defaultHeight()
            case .ViewAdditional:
                let showAdditional = joinedCommunitiesController.communities.count > sectionType.maxRowCount()
                let isMaxRow = (indexPath.row / CommunitiesRowType.Count.rawValue) == sectionType.maxRowIndex()
                rowHeight = (showAdditional && isMaxRow) ? rowType.defaultHeight() : 0.0
                
            case .Count:
                break
            }
            
        case .MoreCommunities:
            guard let rowType = CommunitiesRowType(indexPath: indexPath) else { return rowHeight }
            switch rowType {
            case .Content:
                rowHeight = rowType.defaultHeight()
            case .Separator:
                let isMaxRow = (indexPath.row / CommunitiesRowType.Count.rawValue) == sectionType.maxRowIndex()
                rowHeight =  isMaxRow ? 0.0 : rowType.defaultHeight()
            case .ViewAdditional:
                let showAdditional = unjoinedCommunitiesController.communities.count > sectionType.maxRowCount()
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
