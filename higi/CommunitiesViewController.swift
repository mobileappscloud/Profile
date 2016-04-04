//
//  CommunitiesViewController.swift
//  higi
//
//  Created by Remy Panicker on 3/25/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class CommunitiesViewController: UIViewController {
    
    private struct StoryBoard {
        struct Scene {
            static let communitiesIdentifier = "CommunitiesViewControllerStoryboardIdentifier"
        }
    }
    
    private enum TableSection: Int {
        case YourCommunities
        case MoreCommunities
        case Count
        
        func maxRowCount() -> Int {
            return 10
        }
    }
    
    private enum TableRowType: Int {
        case Content
        case Separator
        case Count
    }
    
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
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
        
        self.title = NSLocalizedString("COMMUNITIES_VIEW_TITLE", comment: "Title for communities view.")
        
        joinedCommunitiesController.fetch({ [weak self] in
            self?.tableView.reloadData()
            }, failure: { (error) in
                if let error = error {
                    
                }
        })
    }
}

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
        case .MoreCommunities:
            rowCount = min(joinedCommunitiesController.communities.count * TableRowType.Count.rawValue, sectionType.maxRowCount() * TableRowType.Count.rawValue)
        case .YourCommunities:
            rowCount = min(unjoinedCommunitiesController.communities.count * TableRowType.Count.rawValue, sectionType.maxRowCount() * TableRowType.Count.rawValue)
        case .Count:
            break
        }
        return rowCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
        
        guard let sectionType = TableSection(rawValue: indexPath.section),
            let rowType = TableRowType(rawValue: indexPath.row) else {
                return UITableViewCell()
        }
        
        let cell: UITableViewCell
        
        switch sectionType {
        case .YourCommunities:
            switch rowType {
            case .Content:
                return UITableViewCell()
            case .Separator:
                return UITableViewCell()
            case .Count:
                break
            }
            
        case .MoreCommunities:
            switch rowType {
            case .Content:
                return UITableViewCell()
            case .Separator:
                return UITableViewCell()
            case .Count:
                break
            }
            
        case .Count:
            break
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

extension CommunitiesViewController: UITableViewDelegate {
    
}
