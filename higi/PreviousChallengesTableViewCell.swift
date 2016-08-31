//
//  PreviousChallengesTableViewCell.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 8/26/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

class PreviousChallengesTableViewCell: UITableViewCell {
    @IBOutlet var previousChallengesLabel: UILabel! {
        didSet {
            previousChallengesLabel.text = NSLocalizedString("CHALLENGES_VIEW_PREVIOUS_CHALLENGES_TEXT", comment: "Text for Previous Challenges in the challenge table view.")
            previousChallengesLabel.textColor = Theme.Color.primary
        }
    }
    @IBOutlet var rightChevronImageView: UIImageView! {
        didSet {
            rightChevronImageView.tintColor = Theme.Color.primary
        }
    }
}
