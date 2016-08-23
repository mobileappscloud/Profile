//
//  ChallengeInfoTableViewCell.swift
//  higi
//
//  Created by Remy Panicker on 8/22/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

/// Table cell for displaying challenge info.
final class ChallengeInfoTableViewCell: UITableViewCell {
    
    /// Header label for challenge description.
    @IBOutlet private var descriptionHeaderLabel: UILabel! {
        didSet {
            descriptionHeaderLabel.text = NSLocalizedString("CHALLENGE_DETAIL_TABLE_CELL_DESCRIPTION_HEADER_TEXT", comment: "Text for cell in challenge detail table for description header.")
        }
    }
    
    /// Label for challenge description.
    @IBOutlet private var descriptionBodyLabel: UILabel! {
        didSet {
            descriptionBodyLabel.text = nil
        }
    }
    
    /// Header label for goal description.
    @IBOutlet private var goalHeaderLabel: UILabel! {
        didSet {
            goalHeaderLabel.text = NSLocalizedString("CHALLENGE_DETAIL_TABLE_CELL_GOAL_HEADER_TEXT", comment: "Text for cell in challenge detail table for goal header.")
        }
    }
    
    /// Label for challenge goal description.
    @IBOutlet private var goalBodyLabel: UILabel! {
        didSet {
            goalBodyLabel.text = nil
        }
    }
}

extension ChallengeInfoTableViewCell {
    
    func configure(withChallengeDescription description: String?, goalDescription: String?) {
        if description == nil {
            descriptionHeaderLabel.hidden = true
            descriptionBodyLabel.hidden = true
        } else {
            descriptionBodyLabel.text = description
        }
        
        if goalDescription == nil {
            goalHeaderLabel.hidden = true
            goalBodyLabel.hidden = true
        } else {
            goalBodyLabel.text = goalDescription
        }
    }
}
