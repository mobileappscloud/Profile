//
//  LeaderboardUserView.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 8/18/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class LeaderboardUserView: ReusableXibView {
    @IBOutlet var placementLabel: UILabel!
    @IBOutlet var userImageView: UIImageView!
    
    override func awakeFromNib() {
        themeBorder()
    }
    
    private func themeBorder() {
        layer.borderWidth = 1
        layer.borderColor = Theme.Color.Leaderboard.User.borderColor.CGColor
    }
}
