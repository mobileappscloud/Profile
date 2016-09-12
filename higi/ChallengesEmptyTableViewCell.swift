//
//  ChallengesEmptyTableViewCell.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 9/6/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class ChallengesEmptyTableViewCell: UITableViewCell {
    
    @IBOutlet var emptyImageView: UIImageView!
    @IBOutlet var topLabel: UILabel! {
        didSet {
            topLabel.textColor = Theme.Color.Challenge.Table.topLabel
            topLabel.font = UIFont.systemFontOfSize(20, weight: UIFontWeightBold)
        }
    }
    @IBOutlet var middleLabel: UILabel! {
        didSet {
            middleLabel.textColor = Theme.Color.Challenge.Table.middleLabel
        }
    }
    @IBOutlet var exploreCommunitiesLabel: UILabel! {
        didSet {
            exploreCommunitiesLabel.textColor = Theme.Color.Challenge.Table.exploreCommunitiesLabel
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setState(.user)
    }

    func setState(state: ChallengeCollectionRequest.EntityType) {
        switch state {
        case .user:
            emptyImageView.image = UIImage(named: "challenge-list-view-empty-cell")
            topLabel.text = NSLocalizedString("CHALLENGES_VIEW_TABLE_EMPTY_TITLE", comment: "Title for when the challenges table is empty")
            middleLabel.text = NSLocalizedString("CHALLENGES_VIEW_TABLE_EMPTY_MESSAGE", comment: "Message for when the challenges table is empty")
            exploreCommunitiesLabel.text = NSLocalizedString("CHALLENGES_VIEW_TABLE_EMPTY_BOTTOM_TEXT", comment: "Text telling the user to explore communities for when the challenges table is empty")
            exploreCommunitiesLabel.hidden = false

        case .communities:
            emptyImageView.image = UIImage(named: "community-challenge-list-view-empty-cell")
            topLabel.text = NSLocalizedString("CHALLENGES_VIEW_TABLE_COMMUNITY_DETAIL_EMPTY_TITLE", comment: "Title for when the challenges table, within the community detail view, is empty")
            middleLabel.text = NSLocalizedString("CHALLENGES_VIEW_TABLE_COMMUNITY_DETAIL_EMPTY_MESSAGE", comment: "Message for when the challenges table, within the community detail view, is empty")
            exploreCommunitiesLabel.text = nil
            exploreCommunitiesLabel.hidden = true
        }
    }
    
}
