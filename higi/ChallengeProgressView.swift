//
//  ChallengeProgressView.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 7/29/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class ChallengeProgressView: ReusableXibView {
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var progressView: UIView!
    @IBOutlet var progressTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet var trackView: UIView! {
        didSet {
            trackView.layer.borderColor = progressColor.CGColor
            trackView.layer.borderWidth = 1.0
        }
    }
    @IBOutlet var goalMilestonesView: UIView!
    
    @IBInspectable var height: CGFloat {
        get {
            return heightConstraint.constant
        }
        set {
            heightConstraint.constant = newValue
            trackView.cornerRadius = heightConstraint.constant / 2
        }
    }
    
    @IBInspectable var progressColor: UIColor = Theme.Color.Challenge.ProgressView.progressColor {
        didSet {
            progressView.backgroundColor = progressColor
            trackView.layer.borderColor = progressColor.CGColor
            renderMilestones()
        }
    }

    private var _progress: CGFloat = 0.0 {
        didSet {
            self.renderMilestones()
            let fractionalDistance = self._progress == 0 ? CGFloat.min : self._progress
            self.progressTrailingConstraint = self.progressTrailingConstraint.setMultiplier(fractionalDistance)
            self.layoutIfNeeded()
        }
    }
    
    private var progressBarAnimationDuration = 0.0
    private let defaultProgressBarAnimation = 0.3
    
    /// Proportion of the progress bar that is filled in. Value should be in [0.0, 1.0]
    @IBInspectable var progress: CGFloat {
        get {
            return _progress
        }
        set {
            if newValue >= 1.0 {
                _progress = 1.0
            } else if newValue <= 0 {
                _progress = 0.0
            } else {
                _progress = newValue
            }
        }
    }
    
    /// Locations for milestones. Values should be in [0.0, 1.0]
    var progressMilestones: [CGFloat] = [] {
        didSet {
            renderMilestones()
        }
    }
    
    var nodeHeight: CGFloat {
        return 14.0
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        trackView.cornerRadius = heightConstraint.constant / 2
        renderMilestones()
        progressBarAnimationDuration = defaultProgressBarAnimation
    }
    
    override func layoutSubviews() {
        renderMilestones()
    }
    
}

// MARK: - Helpers

extension ChallengeProgressView {
    private func renderMilestoneAt(fractionalDistance fractionalDistance: CGFloat) {
        let fractionalDistance = fractionalDistance == 0 ? CGFloat.min : fractionalDistance
        let goalCircle = UIView(frame: CGRect.zero)
        goalCircle.translatesAutoresizingMaskIntoConstraints = false
        goalCircle.cornerRadius = nodeHeight / 2
        if fractionalDistance > progress {
            goalCircle.backgroundColor = Theme.Color.Challenge.ProgressView.trackColor
            goalCircle.layer.borderColor = progressColor.CGColor
            goalCircle.layer.borderWidth = 1.0
        } else {
            goalCircle.backgroundColor = progressColor
        }
        
        goalMilestonesView.addSubview(goalCircle)
        
        addConstraints([
            NSLayoutConstraint(item: goalCircle, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: trackView, attribute: NSLayoutAttribute.Trailing, multiplier: fractionalDistance, constant: 0.0),
            NSLayoutConstraint(item: goalCircle, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: trackView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0)
        ])
        goalCircle.addConstraints([
            NSLayoutConstraint(item: goalCircle, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: nodeHeight),
            NSLayoutConstraint(item: goalCircle, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: nodeHeight)
        ])
    }

    private func renderMilestones() {
        goalMilestonesView.subviews.forEach { (milestoneView) in
            milestoneView.removeFromSuperview()
        }
        progressMilestones.forEach(renderMilestoneAt)
    }
    
}
