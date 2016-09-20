//
//  LeaderboardComparisonViewController.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 9/13/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class LeaderboardComparisonViewController: UIViewController, PageIndexed {
    
    // MARK: - Outlets
    
    @IBOutlet var topThirdView: UIView! {
        didSet {
            topThirdView.backgroundColor = Theme.Color.Leaderboard.Ranking.topThirdBackgroundColor
        }
    }
    
    @IBOutlet var middleThirdView: UIView! {
        didSet {
            middleThirdView.backgroundColor = Theme.Color.Leaderboard.Ranking.middleThirdBackgroundColor
        }
    }
    
    @IBOutlet var bottomThirdView: UIView! {
        didSet {
            bottomThirdView.backgroundColor = Theme.Color.Leaderboard.Ranking.bottomThirdBackgroundColor
        }
    }
    
    @IBOutlet var placementLabel: UILabel! {
        didSet {
            placementLabel.textColor = Theme.Color.Leaderboard.ComparisonView.placementBottomText
        }
    }
    
    @IBOutlet var placementLevelView: UIView! {
        didSet {
            placementLevelView.backgroundColor = Theme.Color.Leaderboard.ComparisonView.placementAnnotations
        }
    }
    
    @IBOutlet var placementLevelVerticalAlignmentConstraint: NSLayoutConstraint!
    
    @IBOutlet var youLabelContainerView: UIView!
    
    @IBOutlet var youLabel: UILabel! {
        didSet {
            youLabel.textColor = Theme.Color.Leaderboard.ComparisonView.placementAnnotations
            youLabel.text = NSLocalizedString("LEADERBOARD_COMPARISON_VIEW_YOU_TEXT", comment: "Text for telling the user, 'you'")
        }
    }
    
    // Injected
    private var userController: UserController!
    private var leaderboardAAAController: LeaderboardAAAController! // assume this has an analysis and rankings, otherwise this VC should not have been segued to
    
    // MARK: - Properties
    
    /// Determines the relative vertical location of the placement level. In [0.0, 1.0]
    /// 0.0 corresponds to the top of the placement.
    private var _placementLevel: CGFloat = 1.0 {
        didSet {
            let fractionalDistance = _placementLevel == 0 ? CGFloat.min : _placementLevel
            self.placementLevelVerticalAlignmentConstraint = self.placementLevelVerticalAlignmentConstraint.setMultiplier(fractionalDistance)
        }
    }
    
    var placementLevel: CGFloat {
        get {
            return _placementLevel
        }
        set {
            guard newValue >= 0.0 && newValue <= 1.0 else { return }
            _placementLevel = newValue
        }
    }
    
    var pageIndex: Int!
    
    // MARK: - Lazy Properties
    lazy var rankings: Leaderboard.Rankings = {
        return self.leaderboardAAAController.leaderboardMemberAnalysisAndRankings!.rankings!
    }()
    
    lazy var analysis: Leaderboard.Member.Analysis = {
        return self.leaderboardAAAController.leaderboardMemberAnalysisAndRankings!.analysis!
    }()
    
    lazy var userRanking: Leaderboard.Rankings.Ranking = {
        let userRanking = self.rankings.rankings.filter { (ranking) -> Bool in
            ranking.user.identifier == self.userController.user.identifier
        }.first!
        return userRanking
    }()
    
}

// MARK: - Lifecycle

extension LeaderboardComparisonViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        placementLevel = 1.0
        configureUserPlacement()
    }
    
    func configure(userController userController: UserController, leaderboardAAAController: LeaderboardAAAController, pageIndex: Int) {
        self.userController = userController
        self.leaderboardAAAController = leaderboardAAAController
        self.pageIndex = pageIndex
    }
}

// MARK: - Helpers
extension LeaderboardComparisonViewController {
    private func configureYouLabelContainerView() {
        youLabelContainerView.setNeedsLayout()
        youLabelContainerView.layoutIfNeeded()
        youLabelContainerView.cornerRadius = youLabelContainerView.bounds.width / 2
        youLabelContainerView.layer.borderWidth = 2
        youLabelContainerView.layer.borderColor = Theme.Color.Leaderboard.ComparisonView.placementAnnotations.CGColor
    }
    
    private func configurePlacementLevel() {
        let placementLevel = (100.0 - CGFloat(userRanking.percentile)) / 100.0
        self.placementLevel = placementLevel
    }

    private func configurePlacementLabel() {
        let rankingNumberText = NSNumberFormatter.localizedStringFromNumber(userRanking.ranking, numberStyle: .DecimalStyle)
        let rankingsNumberText = NSNumberFormatter.localizedStringFromNumber(rankings.rankings.count, numberStyle: .DecimalStyle)
        let placementTextFormat = NSLocalizedString("LEADERBOARD_VIEW_COMPARISON_PLACEMENT_FORMAT", comment: "Format for telling the user what place they are in")
        placementLabel.text = String(format: placementTextFormat, arguments: [rankingNumberText, rankingsNumberText])
    }

    private func configureUserPlacement() {
        configureYouLabelContainerView()
        configurePlacementLevel()
        configurePlacementLabel()
    }
}

