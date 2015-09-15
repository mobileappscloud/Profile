//
//  SwitchTableViewCell.swift
//  higi
//
//  Created by Remy Panicker on 9/15/15.
//  Copyright (c) 2015 higi, LLC. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchControl: UISwitch!
    
    var delegate: SwitchTableViewCellDelegate?;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .None;
    }

    @IBAction func didToggleSwitch(sender: AnyObject) {
        delegate?.valueDidChangeForSwitchCell(self)
    }
}

protocol SwitchTableViewCellDelegate {
    func valueDidChangeForSwitchCell(cell: SwitchTableViewCell);
}
