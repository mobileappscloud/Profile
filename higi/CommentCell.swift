//
//  CommentCell.swift
//  higi
//
//  Created by Remy Panicker on 7/19/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class CommentCell: UITableViewCell, ActionBarDisplaying, ActionBarItemDelegate, TableCellActionBarItemDelegating {
    
    // TODO: Verify if this property is necessary
    @IBOutlet var leadingConstraint: NSLayoutConstraint!
    
    @IBOutlet var avatarButton: UIButton! {
        didSet {
            avatarButton.setImage(nil, forState: .Normal)
            
            let length = avatarButton.bounds.width
            avatarButton.layer.cornerRadius = length/2
        }
    }
    
    @IBOutlet var primaryLabel: TTTAttributedLabel!
    
    @IBOutlet var secondaryLabel: UILabel!
    
    @IBOutlet var actionBar: ActionBar! {
        didSet {
            actionBar.actionItemDelegate = self
        }
    }
    
    weak var cellActionBarItemDelegate: TableCellActionBarItemDelegate?
}

extension CommentCell {
    
    func reset() {
        avatarButton.setImage(nil, forState: .Normal)
        
        primaryLabel.text = nil
        primaryLabel.attributedText = nil
        
        secondaryLabel.text = nil
        secondaryLabel.attributedText = nil
        
        actionBar.configure([])
        
        cellActionBarItemDelegate = nil
    }
}
