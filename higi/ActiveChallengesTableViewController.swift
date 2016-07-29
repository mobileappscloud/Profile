//
//  ActiveChallengesTableViewController.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 7/27/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class ActiveChallengesTableViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 400
            
            tableView.register(nibWithCellClass: ChallengeTableViewCell.self)
            tableView.register(cellClass: UITableViewCell.self)
            tableView.register(nibWithCellClass: ActivityIndicatorTableViewCell.self)
        }
    }
}

//MARK: - UITableViewDataSource
extension ActiveChallengesTableViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TableSection.Count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        guard let sectionType = TableSection(rawValue: section) else {
            return rowCount
        }
        
        switch sectionType {
        case .Challenges:
            rowCount = 5 //TODO: Peter Ryszkiewicz: Make dynamic
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
        case .Challenges:
            let rowType = ChallengesRowType(indexPath: indexPath)
            switch rowType {
            case .Content:
                
                let challengeCell = tableView.dequeueReusableCell(withClass: ChallengeTableViewCell.self)!
                
                let model = ChallengeTableViewCellModel(
                    titleText: "Crazy Steppers Challenge",
                    challengeStatusState: ChallengeStatusIndicatorView.State.joinedAndUnderway,
                    dateText: "Jan 16 - 30, 2016",
                    participantCountText: "2.5K participating",
                    mainImageView: UIImage(named: "challenge-detail-header")!,
                    communityImage: UIImage(named: "chatter-button-normal")!,
                    communityText: "We heart it",
                    challengeInformationUpperText: NSAttributedString(string: "Goal: Most Watts Earned"),
                    challengeInformationLowerText: NSAttributedString(string: "Prizes: No Prize"),
                    challengeInformationImage: UIImage(named: "chat-bubble-green"),
                    showChallengeInformationStatus: false
                )
                
                challengeCell.setModel(model)
                
                cell = challengeCell
                
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
        
        guard cell != nil else {
            fatalError("Method must produce a cell!")
        }
        
        cell.selectionStyle = .None
        return cell
    }
    
}

//MARK: - UITableViewDelegate
extension ActiveChallengesTableViewController: UITableViewDelegate {
    
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
            
        case .Count:
            break
        }
        
        return rowHeight
    }
}

// MARK: - Table Enums

extension ActiveChallengesTableViewController {
    
    enum TableSection: Int  {
        case Challenges
        case InfiniteScroll
        case Count
    }
    
    enum ChallengesRowType: Int {
        case Content
        case Separator
        case Count
        
        init(indexPath: NSIndexPath) {
            self = ChallengesRowType(rawValue: indexPath.row % ChallengesRowType.Count.rawValue)!
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
