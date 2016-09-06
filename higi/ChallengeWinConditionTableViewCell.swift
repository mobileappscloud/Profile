//
//  ChallengeWinConditionTableViewCell.swift
//  higi
//
//  Created by Remy Panicker on 8/31/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ChallengeWinConditionTableViewCell: UITableViewCell {

    @IBOutlet var placeLabel: UILabel! {
        didSet {
            placeLabel.textColor = Theme.Color.Challenge.Detail.WinCondition.placeLabel
        }
    }
    
    @IBOutlet var winConditionLabel: UILabel! {
        didSet {
            winConditionLabel.textColor = Theme.Color.Challenge.Detail.WinCondition.winConditionLabel
        }
    }
    
    @IBOutlet var prizeIconImageView: UIImageView!
    @IBOutlet var prizeLabel: UILabel! {
        didSet {
            prizeLabel.textColor = Theme.Color.Challenge.Detail.WinCondition.prizeLabel
        }
    }
    
    @IBOutlet var prizeImageView: UIImageView! {
        didSet {
            prizeImageView.image = nil
        }
    }
}
