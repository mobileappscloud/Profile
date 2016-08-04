//
//  NSLayoutConstraint+Utility.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 8/1/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    /// Set the multiplier of a constraint. From http://stackoverflow.com/a/33003217/3352495
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        NSLayoutConstraint.deactivateConstraints([self])
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant
        )
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        newConstraint.active = true
        
        NSLayoutConstraint.activateConstraints([newConstraint])
        return newConstraint
    }
}
