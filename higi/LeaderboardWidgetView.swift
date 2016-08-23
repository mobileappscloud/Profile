//
//  LeaderboardWidgetView.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 8/18/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class LeaderboardWidgetView: ReusableXibView {
    @IBOutlet var topTenLabel: UILabel! {
        didSet {
            topTenLabel.text = NSLocalizedString("LEADERBOARD_VIEW_TOP_10_TITLE", comment: "Text for Top 10 on Leaderboard in the leaderboard widget")
        }
    }
    
    @IBOutlet var seeLeaderboardLabel: UILabel! {
        didSet {
            seeLeaderboardLabel.text = NSLocalizedString("LEADERBOARD_VIEW_SEE_LEADERBOARD_TEXT", comment: "Text for see leaderboard in the leaderboard widget")
        }
    }

    @IBOutlet var leaderboardUsersStackView: UIStackView! {
        didSet {
            //TODO: Peter Ryszkiewicz: Remove
            for i in 0...10 {
                let leaderboardUserView = LeaderboardUserView()
                leaderboardUserView.placementLabel.text = "\(i)"
                leaderboardUsersStackView.addArrangedSubview(leaderboardUserView)
            }
        }
    }
    
    func setLeaderboardImages(images: [UIImage]) {
        leaderboardUsersStackView.subviews.forEach { (subview) in
            subview.removeFromSuperview()
        }
        for i in 0..<images.count {
            let leaderboardUserView = LeaderboardUserView()
            leaderboardUserView.placementLabel.text = "\(i)"
            leaderboardUserView.userImageView.image = images[i]
            leaderboardUsersStackView.addArrangedSubview(leaderboardUserView)
        }
    }

}
