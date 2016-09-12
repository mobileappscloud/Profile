//
//  LeaderboardTableViewController.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 9/8/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class LeaderboardTableViewController: UIViewController {
    
    // Properties
    var pageIndex: Int?
    
    // Outlets
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.register(cellClass: UITableViewCell.self)
            tableView.register(nibWithCellClass: LeaderboardRankingTableViewCell.self)
        }
    }
    
    //Injected
    
    private var userController: UserController!
    private var leaderboardRankingsController: LeaderboardRankingsController!
}

// MARK: - Helpers

extension LeaderboardTableViewController {
    private func rankingForIndexPath(indexPath: NSIndexPath) -> Leaderboard.Rankings.Ranking {
        return leaderboardRankingsController.rankings.rankings[indexPath.row / RankingsRowType._count.rawValue]
    }
    
    private func cellBackgroundColorForIndexPath(indexPath: NSIndexPath) -> UIColor {
        switch rankingForIndexPath(indexPath).percentile {
            case 0..<33: return Theme.Color.Leaderboard.Ranking.topThird
            case 33..<67: return Theme.Color.Leaderboard.Ranking.middleThird
            default: return Theme.Color.Leaderboard.Ranking.bottomThird
        }
    }
    
    private func configure(leaderboardRankingTableViewCell cell: LeaderboardRankingTableViewCell, forIndexPath indexPath: NSIndexPath) {
        let ranking = rankingForIndexPath(indexPath)
        
        cell.rankView.backgroundColor = cellBackgroundColorForIndexPath(indexPath)
        
        cell.rankLabel.text = "\(ranking.ranking)"
        cell.rankLabel.textColor = Theme.Color.Leaderboard.Ranking.number
        
        let lastInitial: String = ranking.user.lastName.characters.first == nil ? "" : " \(ranking.user.lastName.characters.first!)."
        cell.userNameLabel.text = "\(ranking.user.firstName)\(lastInitial)"
        cell.userNameLabel.font = UIFont.systemFontOfSize(16.0)

        let wattsNumberString = NSNumberFormatter.localizedStringFromNumber(ranking.score, numberStyle: .DecimalStyle)
        let wattsLabelFormat = NSLocalizedString("LEADERBOARD_VIEW_WATTS_FORMAT", comment: "Format for displaying how many watts a user has")
        cell.wattsLabel.text = String(format: wattsLabelFormat, arguments: [wattsNumberString])
        cell.wattsLabel.font = UIFont.systemFontOfSize(12.0)

        if userController.user.identifier == ranking.user.identifier {
            cell.backgroundColor = Theme.Color.Leaderboard.Ranking.userCellBackground
            cell.userNameLabel.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightBold)
            cell.wattsLabel.font = UIFont.systemFontOfSize(12.0, weight: UIFontWeightBold)
        }
        
        cell.userImageView.setImage(withMediaAsset: ranking.user.photo) //TODO: Optimize - can cause lots of network calls if user swipes around leaderboard
    }
    
    func configure(userController userController: UserController, leaderboardRankingsController: LeaderboardRankingsController, pageIndex: Int?) {
        self.userController = userController
        self.leaderboardRankingsController = leaderboardRankingsController
        self.pageIndex = pageIndex
    }
}

// MARK: - UITableViewDataSource
extension LeaderboardTableViewController: UITableViewDataSource {
    var separatorCount: Int {
        return leaderboardRankingsController.rankings.rankings.count
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
        case .Rankings:
            rowCount = leaderboardRankingsController.rankings.rankings.count + separatorCount
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
        case .Rankings:
            let rowType = RankingsRowType(indexPath: indexPath)
            switch rowType {
            case .Content:
                let rankingCell = tableView.dequeueReusableCell(withClass: LeaderboardRankingTableViewCell.self, forIndexPath: indexPath)
                configure(leaderboardRankingTableViewCell: rankingCell, forIndexPath: indexPath)
                cell = rankingCell
                
            case .Separator:
                let separatorCell = tableView.dequeueReusableCell(withClass: UITableViewCell.self, forIndexPath: indexPath)
                separatorCell.backgroundColor = Theme.Color.Primary.whiteGray
                cell = separatorCell
                
            case ._count:
                break
            }
            
        case ._count:
            break
        }
        
        guard cell != nil else {
            fatalError("Method must produce a cell!")
        }
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension LeaderboardTableViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var rowHeight: CGFloat = 0.0
        guard let sectionType = TableSection(rawValue: indexPath.section) else { return rowHeight }
        
        switch sectionType {
            case .Rankings: rowHeight = RankingsRowType(indexPath: indexPath).defaultHeight()
            case ._count: break
        }
        
        return rowHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let sectionType = TableSection(rawValue: indexPath.section) else { return }
        
        switch sectionType {
        case .Rankings:
            //TODO: Navigate to the user's profile
            break
        case ._count:
            break
        }
    }
}

// MARK: - Table Enums

extension LeaderboardTableViewController {
    
    enum TableSection: Int  {
        case Rankings
        case _count
    }
    
    enum RankingsRowType: Int {
        case Content
        case Separator
        case _count
        
        init(indexPath: NSIndexPath) {
            self = RankingsRowType(rawValue: indexPath.row % RankingsRowType._count.rawValue)!
        }
        
        func defaultHeight() -> CGFloat {
            switch self {
            case .Content:
                return 44.0
            case .Separator:
                return 3.0
            case ._count:
                return 0.0
            }
        }
    }
    
}
