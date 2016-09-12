//
//  LeaderboardStatusWidgetView.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 8/22/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class LeaderboardStatusWidgetView: ReusableXibView {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var placementDescriptionLabel: UILabel!

    @IBOutlet var seeLeaderboardLabel: UILabel! {
        didSet {
            seeLeaderboardLabel.text = NSLocalizedString("LEADERBOARD_VIEW_SEE_LEADERBOARD_TEXT", comment: "Text for see leaderboard in the leaderboard widget")
        }
    }
    
    // Injected
    var viewTapped: (() -> ())?
    
    func setAnalysis(analysis: Leaderboard.Member.Analysis) {
        imageView.setImage(withMediaAsset: analysis.image)
        placementDescriptionLabel.text = analysis.text
    }
}

// MARK: - Lifecycle
extension LeaderboardStatusWidgetView {
    override func awakeFromNib() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    }
    
    func tapped(recognizer: UITapGestureRecognizer) {
        viewTapped?()
    }
}
