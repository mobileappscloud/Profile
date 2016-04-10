//
//  ButtonTableViewCell.swift
//  higi
//
//  Created by Remy Panicker on 4/8/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class ButtonTableViewCell: UITableViewCell {

    @IBOutlet var button: UIButton! {
        didSet {
            button.setTitle("", forState: .Normal)
        }
    }
    
    var tapHandler: ((cell: ButtonTableViewCell) -> Void)?
}

extension ButtonTableViewCell {
    
    @IBAction private func didTapButton(sender: UIButton) {
        tapHandler?(cell: self)
    }
}
