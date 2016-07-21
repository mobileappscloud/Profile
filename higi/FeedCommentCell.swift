//
//  FeedCommentCell.swift
//  higi
//
//  Created by Remy Panicker on 7/19/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class FeedCommentCell: UITableViewCell {
    
    @IBOutlet var leadingConstraint: NSLayoutConstraint!
    
    @IBOutlet var avatarButton: UIButton! {
        didSet {
            avatarButton.setImage(nil, forState: .Normal)
            
            let length = avatarButton.bounds.width
            avatarButton.layer.cornerRadius = length/2
        }
    }
    
    var buttonHandler: ((cell: FeedCommentCell) -> Void)?
    
    @IBOutlet var primaryLabel: TTTAttributedLabel!
    
    @IBOutlet var secondaryLabel: UILabel!
    
    @IBOutlet var actionBar: PostActionBar!
}

extension FeedCommentCell {
    
    @IBAction private func didTapAvatarButton(sender: UIButton) {
        buttonHandler?(cell: self)
    }
}
