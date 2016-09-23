//
//  ChallengeParticipantTableViewCell.swift
//  higi
//
//  Created by Remy Panicker on 9/6/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ChallengeParticipantTableViewCell: UITableViewCell {

     /// MARK: Outlets
    
    @IBOutlet var avatarImageView: UIImageView!
    
    @IBOutlet var nameLabel: UILabel!

     /// Vertical stack view used for adding additional content to the cell.
    @IBOutlet var contentStackView: UIStackView!
}

extension ChallengeParticipantTableViewCell {
    
    func reset() {
        avatarImageView.image = UIImage(named: "profile-placeholder")
        nameLabel.text = nil
        
        for subview in contentStackView.arrangedSubviews {
            if subview == nameLabel { continue }
            contentStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }
}
