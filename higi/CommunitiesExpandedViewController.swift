//
//  CommunitiesExpandedViewController.swift
//  higi
//
//  Created by Remy Panicker on 4/10/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class CommunitiesExpandedViewController: UIViewController {

    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.separatorStyle = .None
            tableView.allowsSelection = false
            
            tableView.estimatedRowHeight = 211.0
            
            tableView.register(nibWithCellClass: CommunityListingTableViewCell.self)
            tableView.register(cellClass: UITableViewCell.self)
            tableView.register(nibWithCellClass: ActivityIndicatorTableViewCell.self)
        }
    }
    
    var controller: CommunitiesController!
}

extension CommunitiesExpandedViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchNextCommunities()
    }
}

// MARK: -

extension CommunitiesExpandedViewController {
    
    private func fetchNextCommunities() {
        guard let _ = controller.paging?.next else {
            return
        }
        
        controller.fetchNext(fetchNextSuccess, failure: fetchNextFailure)
    }
    
    private func fetchNextSuccess() {
        guard let paging = controller.paging else { return }
        
        let previousPageNumber = paging.pageNumber - 1
        let previousCollectionMaxIndex = previousPageNumber * paging.pageSize
        
        let currentCollectionMaxIndex = controller.communities.count - 1
        
        let section = TableSection.Communities.rawValue
        var indexPaths: [NSIndexPath] = []
        
        for index in previousCollectionMaxIndex...currentCollectionMaxIndex {
            for rowType in 0..<CommunitiesRowType.Count.rawValue {
                let calculatedIndex = (index * CommunitiesRowType.Count.rawValue) + rowType
                let indexPath = NSIndexPath(forRow: calculatedIndex, inSection: section)
                indexPaths.append(indexPath)
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.beginUpdates()
            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Bottom)
            self.tableView.endUpdates()
        })
    }
    
    private func fetchNextFailure(error: NSError?) {
        if let error = error {
            print(error)
        }
    }
}

// MARK: - Table

extension CommunitiesExpandedViewController {
    
    enum TableSection: Int  {
        case Communities
        case InfiniteScroll
        case Count
    }
    
    enum CommunitiesRowType: Int {
        case Separator
        case Content
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
                return 80.0
            case .Count:
                return 0.0
            }
        }
    }
}

// MARK: - Table Data Source

extension CommunitiesExpandedViewController: UITableViewDataSource {
    
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
            rowCount = controller.communities.count * CommunitiesRowType.Count.rawValue
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
        
        var cell: UITableViewCell?
        switch sectionType {
        case .Communities:
            let rowType = CommunitiesRowType(indexPath: indexPath)
            switch rowType {
            case .Content:
                let index = indexPath.row / CommunitiesRowType.Count.rawValue
                let community = controller.communities[index]
                let communityCell = CommunitiesTableUtility.cell(tableView, community: community, indexPath: indexPath)
                communityCell.interactiveContentTapHandler = { (cell) in
                    let segue = CommunitiesViewController.Storyboard.Segue.DetailView(community: community)
                    self.performSegueWithIdentifier(CommunitiesViewController.Storyboard.Segue.DetailView.identifier, sender: segue.userInfo())
                }
                
                if !community.isMember {
                    let segueInfo = CommunitiesViewController.Storyboard.Segue.DetailView(community: community, join: true)
                    let delegate = CommunityListingButtonDelegate(presentingViewController: self, segueIdentifier: CommunitiesViewController.Storyboard.Segue.DetailView.joinIdentifier, userInfo: segueInfo.userInfo())
                    CommunitiesTableUtility.addJoinButton(toCell: communityCell, delegate: delegate)
                }
                
                cell = communityCell
                
            case .Separator:
                cell = CommunitiesTableUtility.separatorCell(tableView, forIndexPath: indexPath)
                
            case .Count:
                break
            }
            
        case .InfiniteScroll:
            let rowType = InfiniteScrollRowType(indexPath: indexPath)
            switch rowType {
            case .ActivityIndicator:
                cell = indicatorCell(forIndexPath: indexPath)
                
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

extension CommunitiesExpandedViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var rowHeight: CGFloat = 0.0
        guard let sectionType = TableSection(rawValue: indexPath.section) else { return rowHeight }
        
        switch sectionType {
            
        case .Communities:
            let rowType = CommunitiesRowType(indexPath: indexPath)
            rowHeight = rowType.defaultHeight()
            
        case .InfiniteScroll:
            guard let paging = controller.paging,
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
            fetchNextCommunities()
        }
    }
}

// MARK: - Custom Cells 

extension CommunitiesExpandedViewController {
    
    private func indicatorCell(forIndexPath indexPath: NSIndexPath) -> ActivityIndicatorTableViewCell {
        return tableView.dequeueReusableCell(withClass: ActivityIndicatorTableViewCell.self, forIndexPath: indexPath)
    }
}

// MARK: - Navigation

extension CommunitiesExpandedViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == CommunitiesViewController.Storyboard.Segue.DetailView.identifier ||
            segue.identifier == CommunitiesViewController.Storyboard.Segue.DetailView.joinIdentifier {
            guard let viewController = segue.destinationViewController as? CommunityDetailViewController,
                let userInfo = CommunitiesViewController.Storyboard.Segue.DetailView(userInfo: sender) else { return }
            
            viewController.community = userInfo.community
        }
    }
}
