//
//  ChallengeProgressTableViewCell.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 9/22/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class ChallengeProgressTableViewCell: UITableViewCell {

    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var challengeProgressView: ChallengeProgressView!
    @IBOutlet var dashedLineView: UIView!
}

extension ChallengeProgressTableViewCell {
    func reset() {
        challengeProgressView.userImageView.image = UIImage(named: "profile-placeholder")
        userNameLabel.text = nil
    }
}
