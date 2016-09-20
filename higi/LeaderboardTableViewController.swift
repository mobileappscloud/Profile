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
    var pageIndex: Int!
    private let buttonAnimationDuration = 0.25
    private var hidingJumpToTopButton = false
    private var hidingJumpToYouButton = false
    private let bottomSeparatorCount = 1
    private let topSeparatorCount = 1
    private var initiallyScrolledToUser = false
    private let mainButtonAlpha: CGFloat = 0.9

    // Outlets
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.register(cellClass: UITableViewCell.self)
            tableView.register(nibWithCellClass: LeaderboardRankingTableViewCell.self)
        }
    }
    
    @IBOutlet var jumpToTopButton: ScrollToLocationButton! {
        didSet {
            let jumpToTopText = NSLocalizedString("LEADERBOARD_VIEW_JUMP_TO_TOP_TEXT", comment: "Text for the button telling the user to 'Jump to Top', for the leaderboard table.")
            jumpToTopButton.scrollToLabel.text = jumpToTopText
            jumpToTopButton.chevronDirection = .up
            jumpToTopButton.hidden = true
            jumpToTopButton.buttonTappedCallback = {
                [weak self] in
                self?.scrollToTopButtonTapped()
            }
        }
    }
    
    @IBOutlet var jumpToYouButton: ScrollToLocationButton! {
        didSet {
            let jumpToYouText = NSLocalizedString("LEADERBOARD_VIEW_JUMP_TO_YOU_TEXT", comment: "Text for the button telling the user to 'Jump to You', for the leaderboard table.")
            jumpToYouButton.scrollToLabel.text = jumpToYouText
            jumpToYouButton.chevronDirection = .down
            jumpToTopButton.hidden = true
            jumpToYouButton.buttonTappedCallback = {
                [weak self] in
                self?.scrollToYouButtonTapped()
            }
        }
    }
    
    //Injected
    
    private var userController: UserController!
    private var leaderboardRankingsController: LeaderboardRankingsController!
    
    // Lazy
    
    lazy var rankings: Leaderboard.Rankings = {
        return self.leaderboardRankingsController.rankings
    }()
    
    lazy var userRankingIndex: Int? = {
        self.rankings.rankings.indexOf { $0.user.identifier == self.userController.user.identifier }
    }()

    lazy var userRanking: Leaderboard.Rankings.Ranking? = {
        guard let userRankingIndex = self.userRankingIndex else { return nil }
        return self.rankings.rankings[userRankingIndex]
    }()

    lazy var userIndexPath: NSIndexPath? = {
        guard let userRankingIndex = self.userRankingIndex else { return nil }
        return self.indexPathForRankingIndex(userRankingIndex)
    }()

}

// MARK: - Lifecycle

extension LeaderboardTableViewController {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !initiallyScrolledToUser {
            scrollToUser(animated: false)
            initiallyScrolledToUser = true
        }
    }
}

// MARK: - Helpers

extension LeaderboardTableViewController: PageIndexed {
    
    private func rankingForIndexPath(indexPath: NSIndexPath) -> Leaderboard.Rankings.Ranking {
        return rankings.rankings[(indexPath.row - bottomSeparatorCount) / RankingsRowType._count.rawValue]
    }
    
    private func indexPathForRankingIndex(index: Int) -> NSIndexPath {
        return NSIndexPath(forRow: index * RankingsRowType._count.rawValue + topSeparatorCount, inSection: 0)
    }
    
    private func cellBackgroundColorForIndexPath(indexPath: NSIndexPath) -> UIColor {
        switch rankingForIndexPath(indexPath).percentile {
            case 0..<33: return Theme.Color.Leaderboard.Ranking.bottomThirdBackgroundColor
            case 33..<67: return Theme.Color.Leaderboard.Ranking.middleThirdBackgroundColor
            default: return Theme.Color.Leaderboard.Ranking.topThirdBackgroundColor
        }
    }
    
    private func configure(leaderboardRankingTableViewCell cell: LeaderboardRankingTableViewCell, forIndexPath indexPath: NSIndexPath) {
        let ranking = rankingForIndexPath(indexPath)
        
        cell.rankView.backgroundColor = cellBackgroundColorForIndexPath(indexPath)
        
        cell.rankLabel.text = "\(ranking.ranking)"
        cell.rankLabel.textColor = Theme.Color.Leaderboard.Ranking.numberLabel
        
        let lastInitial: String = ranking.user.lastName.characters.first == nil ? "" : " \(ranking.user.lastName.characters.first!)."
        cell.userNameLabel.text = "\(ranking.user.firstName)\(lastInitial)"
        cell.userNameLabel.font = UIFont.systemFontOfSize(16.0)
        cell.userNameLabel.textColor = Theme.Color.Leaderboard.Ranking.userNameLabel

        let wattsNumberString = NSNumberFormatter.localizedStringFromNumber(ranking.score, numberStyle: .DecimalStyle)
        let wattsLabelFormat = NSLocalizedString("LEADERBOARD_VIEW_WATTS_FORMAT", comment: "Format for displaying how many watts a user has")
        cell.wattsLabel.text = String(format: wattsLabelFormat, arguments: [wattsNumberString])
        cell.wattsLabel.font = UIFont.systemFontOfSize(12.0)

        if userController.user.identifier == ranking.user.identifier {
            cell.backgroundColor = Theme.Color.Leaderboard.Ranking.userCellBackgroundColor
            cell.userNameLabel.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightBold)
            cell.wattsLabel.font = UIFont.systemFontOfSize(12.0, weight: UIFontWeightBold)
        } else {
            cell.backgroundColor = Theme.Color.Leaderboard.Ranking.defaultCellBackgroundColor
        }
        
        cell.userImageView.image = UIImage(named: "profile-placeholder")
        if let userPhoto = ranking.user.photo {
            cell.userImageView.setImage(withMediaAsset: userPhoto) //TODO: Optimize - can cause lots of network calls if user swipes around leaderboard
        }
    }
    
    func configure(userController userController: UserController, leaderboardRankingsController: LeaderboardRankingsController, pageIndex: Int) {
        self.userController = userController
        self.leaderboardRankingsController = leaderboardRankingsController
        self.pageIndex = pageIndex
    }
}

// MARK: - UITableViewDataSource
extension LeaderboardTableViewController: UITableViewDataSource {
    var separatorCount: Int {
        return rankings.rankings.count + bottomSeparatorCount
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
            rowCount = rankings.rankings.count + separatorCount
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
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            hideJumpToTopButton()
        }
        if !userIsBelowIndexPaths([indexPath]) {
            hideJumpToYouButton()
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollingUpQuickly(withVelocity: velocity) {
            displayJumpToTopButton()
        }
        if scrollingDownQuickly(withVelocity: velocity) {
            displayJumpToYouButton()
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollingDownwards(scrollView: scrollView) {
            hideJumpToTopButton()
        }
        if scrollingUpwards(scrollView: scrollView) {
            hideJumpToYouButton()
        }
    }
    
    private func scrollingUpQuickly(withVelocity velocity: CGPoint) -> Bool {
        return velocity.y < -1.0
    }

    private func scrollingDownQuickly(withVelocity velocity: CGPoint) -> Bool {
        return velocity.y > 1.0
    }

    private func scrollingDownwards(scrollView scrollView: UIScrollView) -> Bool {
        return scrollView.panGestureRecognizer.translationInView(scrollView.superview).y < 0
    }

    private func scrollingUpwards(scrollView scrollView: UIScrollView) -> Bool {
        return scrollView.panGestureRecognizer.translationInView(scrollView.superview).y > 0
    }

    private func displayJumpToTopButton() {
        if tableView.indexPathsForVisibleRows?.contains({ $0.row == 0 }) == true  { return } // already at the top
        guard jumpToTopButton.hidden else { return }
        
        jumpToTopButton.hidden = false
        UIView.animateWithDuration(buttonAnimationDuration, delay: 0.0, options: [], animations: {
            self.jumpToTopButton.alpha = self.mainButtonAlpha
        }, completion: nil)
    }
    
    private func hideJumpToTopButton() {
        guard !jumpToTopButton.hidden && !hidingJumpToTopButton else { return }
        
        hidingJumpToTopButton = true
        UIView.animateWithDuration(buttonAnimationDuration, delay: 0.0, options: [], animations: {
            self.jumpToTopButton.alpha = 0.0
        }, completion: {
            [weak self] completed in
            self?.jumpToTopButton.hidden = completed
            self?.hidingJumpToTopButton = false
        })
    }
    
    private func displayJumpToYouButton() {
        guard jumpToYouButton.hidden else { return }
        guard userIsBelowIndexPaths(tableView.indexPathsForVisibleRows) else { return }
        
        jumpToYouButton.hidden = false
        UIView.animateWithDuration(buttonAnimationDuration, delay: 0.0, options: [], animations: {
            self.jumpToYouButton.alpha = self.mainButtonAlpha
        }, completion: nil)
    }
    
    private func hideJumpToYouButton() {
        guard !jumpToYouButton.hidden && !hidingJumpToYouButton else { return }
        
        hidingJumpToYouButton = true
        UIView.animateWithDuration(buttonAnimationDuration, delay: 0.0, options: [], animations: {
            self.jumpToYouButton.alpha = 0.0
        }, completion: {
            [weak self] completed in
            self?.jumpToYouButton.hidden = completed
            self?.hidingJumpToYouButton = false
        })
    }
    
    private func userIsBelowIndexPaths(indexPaths: [NSIndexPath]?) -> Bool {
        guard let lastIndexPath = indexPaths?.last, let userRanking = userRanking else {
            return false
        }
        let lastRanking = rankingForIndexPath(lastIndexPath)
        return userRanking.ranking > lastRanking.ranking // assume good ranking values (increasing) from the server
    }
    
    private func scrollToTopButtonTapped() {
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        hideJumpToTopButton()
    }

    private func scrollToYouButtonTapped() {
        scrollToUser()
    }
    
    private func scrollToUser(animated animated: Bool = true) {
        guard let userIndexPath = userIndexPath else { return }
        tableView.scrollToRowAtIndexPath(userIndexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: animated)
        hideJumpToYouButton()
    }
}

// MARK: - Table Enums

extension LeaderboardTableViewController {
    
    enum TableSection: Int  {
        case Rankings
        case _count
    }
    
    enum RankingsRowType: Int {
        case Separator
        case Content
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
