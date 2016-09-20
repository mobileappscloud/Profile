//
//  ScrollToLocationButton.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 9/15/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class ScrollToLocationButton: ReusableXibView {
    
    // MARK: Properties
    var chevronDirection = ChevronDirection.up {
        didSet {
            chevronImageView.image = chevronDirection.image
        }
    }
    
    var buttonTappedCallback: (() -> ())?

    // MARK: Outlets
    @IBOutlet var backgroundView: UIView! {
        didSet {
            backgroundView.backgroundColor = Theme.Color.Leaderboard.Ranking.jumpToLocationButtonBackground
        }
    }
    
    @IBOutlet var chevronImageView: UIImageView! {
        didSet {
            chevronImageView.image = chevronDirection.image
            chevronImageView.tintColor = Theme.Color.Leaderboard.Ranking.jumpToLocationButtonContentColor
        }
    }
    
    @IBOutlet var scrollToLabel: UILabel! {
        didSet {
            scrollToLabel.textColor = Theme.Color.Leaderboard.Ranking.jumpToLocationButtonContentColor
        }
    }

}

// MARK: - Lifecycle

extension ScrollToLocationButton {
    override func awakeFromNib() {
        backgroundView.setNeedsLayout()
        backgroundView.layoutIfNeeded()
        backgroundView.cornerRadius = backgroundView.bounds.height / 2
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonTapped)))
    }
}

// MARK: - Helpers

extension ScrollToLocationButton {
    func buttonTapped(gestureRecognizer: UITapGestureRecognizer) {
        buttonTappedCallback?()
    }
}

// MARK: - Enums

extension ScrollToLocationButton {
    enum ChevronDirection {
        case up
        case down
        
        var imageName: String {
            switch self {
                case .up: return "chevron-up"
                case .down: return "chevron-down"
            }
        }
        
        var image: UIImage? {
            return UIImage(named: imageName)?.imageWithRenderingMode(.AlwaysTemplate)
        }
    }
}