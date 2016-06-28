//
//  PostCell.swift
//  higi
//
//  Created by Remy Panicker on 6/27/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class PostCell: UITableViewCell {
    
    @IBOutlet var headerView: PostHeaderView!
    
    @IBOutlet var contentContainer: UIView!
    
    @IBOutlet var textDescriptionView: PostTextDescriptionView!
    
    @IBOutlet var actionBar: PostActionBar!
}

extension PostCell {
    
    func reset() {
        headerView.avatarButton.setImage(nil, forState: .Normal)
        headerView.nameActionLabel.text = nil
        headerView.timestampLabel.text = nil
        
        textDescriptionView.titleLabel.text = nil
        textDescriptionView.descriptionLabel.text = nil
        
        actionBar.configure([])
    }
}
