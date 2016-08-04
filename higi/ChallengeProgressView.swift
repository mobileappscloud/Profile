//
//  ChallengeProgressView.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 7/29/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

class ChallengeProgressView: ReusableXibView {
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var barView: UIView!
    @IBOutlet var progressTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var trackView: UIView!
    
    @IBInspectable var height: CGFloat {
        get {
            return heightConstraint.constant
        }
        set {
            heightConstraint.constant = newValue
            barView.cornerRadius = heightConstraint.constant / 2
        }
    }
    
    private var _progress: CGFloat = 0.0 {
        didSet {
            UIView.animateWithDuration(progressBarAnimationDuration) {
                let fractionalDistance = self._progress == 0 ? CGFloat.min : self._progress
                self.progressTrailingConstraint = self.progressTrailingConstraint.setMultiplier(fractionalDistance)
                self.layoutIfNeeded()
            }
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
            guard newValue >= 0.0 && newValue <= 1.0 else {
                return
            }
            _progress = newValue
        }
    }
    
    /// Locations for milestones. Values should be in [0.0, 1.0]
    var progressMilestones: [CGFloat] = [] {
        didSet {
            renderMilestones()
        }
    }
    
    private var milestoneViews: [UIView] = []
    
    private func renderMilestones() {
        milestoneViews.forEach { (milestoneView) in
            milestoneView.removeFromSuperview()
        }
        milestoneViews = []
        progressMilestones.forEach { (milestone) in
            renderMilestoneAt(fractionalDistance: milestone)
        }
    }
    
    var nodeHeight: CGFloat {
        return 12.0
    }
    
    private func renderMilestoneAt(fractionalDistance fractionalDistance: CGFloat) {
        let fractionalDistance = fractionalDistance == 0 ? CGFloat.min : fractionalDistance
        let goalCircle = UIView(frame: CGRect.zero)
        goalCircle.translatesAutoresizingMaskIntoConstraints = false
        goalCircle.backgroundColor = Theme.Color.Primary.green
        goalCircle.cornerRadius = nodeHeight / 2
        milestoneViews.append(goalCircle)
        insertSubview(goalCircle, belowSubview: userImageView) // FIXME: Goal circles are still underneath the user image
        
        addConstraints([
            NSLayoutConstraint(item: goalCircle, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: barView, attribute: NSLayoutAttribute.Trailing, multiplier: fractionalDistance, constant: 0.0),
            NSLayoutConstraint(item: goalCircle, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: barView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0)
        ])
        goalCircle.addConstraints([
            NSLayoutConstraint(item: goalCircle, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: nodeHeight),
            NSLayoutConstraint(item: goalCircle, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: nodeHeight)
        ])
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        barView.cornerRadius = heightConstraint.constant / 2
        renderMilestones()
        progressBarAnimationDuration = defaultProgressBarAnimation
    }
    
    override func layoutSubviews() {
        renderMilestones()
    }
    
}
