//
//  TextViewController.swift
//  higi
//
//  Created by Remy Panicker on 6/11/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class TextViewController: UIViewController {

    @IBOutlet var label: UILabel! {
        didSet {
            label.text = nil
        }
    }
    
    @IBOutlet private var labelTopConstraint: NSLayoutConstraint!
    @IBOutlet private var labelBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var labelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var labelTrailingConstraint: NSLayoutConstraint!
}

extension TextViewController {
    
    func configure(text: String?, textColor: UIColor?, backgroundColor: UIColor?) {
        label.text = text
        if let textColor = textColor {
            label.textColor = textColor
        }
        if let backgroundColor = backgroundColor {
            view.backgroundColor = backgroundColor
            label.backgroundColor = backgroundColor
        }
    }
    
    func configure(margins: CGFloat) {
        let constraints = [labelTopConstraint, labelBottomConstraint, labelLeadingConstraint, labelTrailingConstraint]
        for constraint in constraints {
            constraint.constant = margins
        }
    }
}
