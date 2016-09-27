//
//  ChallengeProgressView.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 7/29/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class ChallengeProgressView: ReusableXibView {
    
    // MARK: Outlets
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var progressView: UIView!
    @IBOutlet var progressWidthConstraint: NSLayoutConstraint!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet var goalMilestoneOverlayView: UIView! {
        didSet {
            goalMilestoneOverlayView.backgroundColor = Theme.Color.Challenge.ProgressView.trackColor
        }
    }
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
            updateCornerRadii()
        }
    }
    
    @IBOutlet var wattsLabel: UILabel! {
        didSet {
            wattsLabel.textColor = Theme.Color.Challenge.ProgressView.wattsLabel
        }
    }
    
    // MARK: Properties
    
    @IBInspectable var progressColor: UIColor = Theme.Color.Challenge.ProgressView.progressColor {
        didSet {
            progressView.backgroundColor = progressColor
            trackView.layer.borderColor = progressColor.CGColor
            renderMilestones()
        }
    }

    private var _progress: CGFloat = 0.0 {
        didSet {
            updateProgressWidth()
            renderMilestones()
            setNeedsLayout()
            layoutIfNeeded()
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
        return heightConstraint.constant * 2
    }
    
    static let heightForCompetitiveBar: CGFloat = 15
    static let heightForNonCompetitiveBar: CGFloat = 7
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setNeedsLayout()
        layoutIfNeeded()
        updateCornerRadii()
        renderMilestones()
        progressBarAnimationDuration = defaultProgressBarAnimation
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateProgressWidth()
        renderMilestones()
        truncateLabel()
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
    
    private func updateCornerRadii() {
        trackView.cornerRadius = heightConstraint.constant / 2
        progressView.cornerRadius = heightConstraint.constant / 2
        goalMilestoneOverlayView.cornerRadius = heightConstraint.constant / 2
    }
    
    private func updateProgressWidth() {
        layoutIfNeeded()
        let fractionalDistance = self._progress == 0 ? CGFloat.min : self._progress
        progressWidthConstraint.constant = trackView.bounds.width * fractionalDistance
    }
    
    private func truncateLabel() {
        if let text = wattsLabel.text where textIsTruncated(text) {
            wattsLabel.text = nil
        }
    }
    
    private func textIsTruncated(text: String) -> Bool {
        wattsLabel.layoutIfNeeded()
        return (text as NSString).sizeWithAttributes([
            NSFontAttributeName: wattsLabel.font
        ]).width > wattsLabel.bounds.width
    }
}
