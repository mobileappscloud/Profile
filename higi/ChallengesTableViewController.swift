//
//  ChallengesTableViewController.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 7/27/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class ChallengesTableViewController: UIViewController {
    private var userController: UserController!
    private var tableType: TableType!
    
    private lazy var activeChallengeViewModels: [ChallengeTableViewCellModel] = []
    private lazy var challengesController = ChallengesController()
    
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 400
            
            tableView.register(nibWithCellClass: ChallengeTableViewCell.self)
            tableView.register(cellClass: UITableViewCell.self)
            tableView.register(nibWithCellClass: ActivityIndicatorTableViewCell.self)
        }
    }
    
    override func viewDidLoad() {
        fetchChallenges()
    }
    
    func configureWith(userController userController: UserController, tableType: TableType) {
        self.userController = userController
        self.tableType = tableType
    }
    
    private func fetchChallenges() {
        challengesController.fetch(forUser: userController.user, challengesType: tableType.asChallengeType, success: {
            [weak self] in
            dispatch_async(dispatch_get_main_queue()) {
                guard let strongSelf = self else { return }
                strongSelf.activeChallengeViewModels = strongSelf.challengesController.challenges.map(ChallengeTableViewCellModel.init)
                strongSelf.tableView.reloadData()
            }
        }, failure: {
            //TODO: Peter Ryszkiewicz: handle failure
        })
    }
}

//MARK: - UITableViewDataSource
extension ChallengesTableViewController: UITableViewDataSource {
    var separatorCount: Int {
        return activeChallengeViewModels.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TableSection._count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        guard let sectionType = TableSection(rawValue: section) else {
            return rowCount
        }
        
        switch sectionType {
        case .Challenges:
            rowCount = activeChallengeViewModels.count + separatorCount
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
        case .Challenges:
            let rowType = ChallengesRowType(indexPath: indexPath)
            switch rowType {
            case .Content:
                let challengeCell = tableView.dequeueReusableCell(withClass: ChallengeTableViewCell.self)!
                challengeCell.setModel(activeChallengeViewModels[indexPath.row / ChallengesRowType._count.rawValue])
                challengeCell.challengeProgressView?.userImageView.setImage(withMediaAsset: userController.user.photo, transition: true)
                cell = challengeCell
                
            case .Separator:
                let separatorCell = tableView.dequeueReusableCell(withClass: UITableViewCell.self, forIndexPath: indexPath)
                separatorCell.backgroundColor = Theme.Color.Primary.whiteGray
                cell = separatorCell
                
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
        
        guard cell != nil else {
            fatalError("Method must produce a cell!")
        }
        
        cell.selectionStyle = .None
        return cell
    }
    
}

//MARK: - UITableViewDelegate
extension ChallengesTableViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var rowHeight: CGFloat = 0.0
        guard let sectionType = TableSection(rawValue: indexPath.section) else { return rowHeight }
        
        switch sectionType {
            
        case .Challenges:
            let rowType = ChallengesRowType(indexPath: indexPath)
            rowHeight = rowType.defaultHeight()
            
        case .InfiniteScroll:
            let rowType = InfiniteScrollRowType(indexPath: indexPath)
            rowHeight = rowType.defaultHeight()
            
        case ._count:
            break
        }
        
        return rowHeight
    }
}

// MARK: - Table Enums

extension ChallengesTableViewController {
    enum TableType {
        case Current
        case Finished
        case CommunityDetail
        
        var asChallengeType: ChallengesController.ChallengeType {
            switch self {
                case .Current: return ChallengesController.ChallengeType.Current
                case .Finished: return ChallengesController.ChallengeType.Finished
                case .CommunityDetail: return ChallengesController.ChallengeType.Current //TODO: Peter Ryszkiewicz: FIXME
            }
        }
    }
    
    enum TableSection: Int  {
        case Challenges
        case InfiniteScroll
        case _count
    }
    
    enum ChallengesRowType: Int {
        case Content
        case Separator
        case _count
        
        init(indexPath: NSIndexPath) {
            self = ChallengesRowType(rawValue: indexPath.row % ChallengesRowType._count.rawValue)!
        }
        
        func defaultHeight() -> CGFloat {
            switch self {
            case .Content:
                return UITableViewAutomaticDimension
            case .Separator:
                return 17.0
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
