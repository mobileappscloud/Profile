//
//  ChallengeStatusIndicatorView.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 7/27/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

@IBDesignable
final class ChallengeStatusIndicatorView: ReusableXibView {
    @IBOutlet var strikethroughView: UIView!
    
    private let animationDuration = 0.5
    private let strikethroughAngle = CGFloat(M_PI_4)
    
    var state: ChallengeTableViewCellModel.State = .joinedAndUnderway {
        didSet {
            UIView.animateWithDuration(animationDuration) {
                self.configureStateChanged()
            }
        }
    }
    
    private var color: UIColor {
        switch state {
        case .unjoinedAndUnderway:
            return Theme.Color.Challenge.Status.unjoinedAndUnderway
        case .unjoinedAndNotUnderway:
            return Theme.Color.Challenge.Status.unjoinedAndNotUnderway
        case .joinedAndUnderway:
            return Theme.Color.Challenge.Status.joinedAndUnderway
        case .joinedAndNotUnderway:
            return Theme.Color.Challenge.Status.joinedAndNotUnderway
        case .tabulatingResults:
            return Theme.Color.Challenge.Status.tabulatingResults
        case .challengeComplete:
            return Theme.Color.Challenge.Status.challengeComplete
        case .cancelled:
            return Theme.Color.Challenge.Status.cancelled
        }
    }
    
    private func configureStateChanged() {
        self.backgroundColor = color
        self.strikethroughView.alpha = self.state == .cancelled ? 1.0 : 0.0
    }
    
    private func configureViews() {
        layer.cornerRadius = bounds.width / 2.0
        strikethroughView.transform = CGAffineTransformMakeRotation(strikethroughAngle)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
        configureStateChanged()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        state = .joinedAndUnderway
        configureViews()
    }

}