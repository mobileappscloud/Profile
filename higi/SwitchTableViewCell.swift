//
//  SwitchTableViewCell.swift
//  higi
//
//  Created by Remy Panicker on 9/15/15.
//  Copyright (c) 2015 higi, LLC. All rights reserved.
//

import UIKit

final class SwitchTableViewCell: UITableViewCell {

    let switchControl = UISwitch();
    
    var delegate: SwitchTableViewCellDelegate?;
    
    // MARK: - Initialization
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        
        self.switchControl.addTarget(self, action: #selector(SwitchTableViewCell.didToggleSwitch), forControlEvents: UIControlEvents.TouchUpInside);
        self.accessoryView = switchControl;
        self.selectionStyle = .None;
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    // MARK: - Value Change
    
    func didToggleSwitch() {
        delegate?.valueDidChangeForSwitchCell(self)
    }
}

protocol SwitchTableViewCellDelegate {
    func valueDidChangeForSwitchCell(cell: SwitchTableViewCell);
}
