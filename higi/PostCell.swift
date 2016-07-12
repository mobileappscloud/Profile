//
//  PostCell.swift
//  higi
//
//  Created by Remy Panicker on 6/27/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class PostCell: UITableViewCell {
    
    @IBOutlet var headerView: PostHeaderView!
    
    @IBOutlet var contentStackView: UIStackView! {
        didSet {
            contentStackView.addGestureRecognizer(self.tapGestureRecognizer)
        }
    }
    
    @IBOutlet var actionBar: PostActionBar!
    
    lazy private var tapGestureRecognizer: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapContentArea))
        tap.delegate = self.tapDelegate
        return tap
    }()
    lazy private var tapDelegate: PostContentTapGestureRecognizerDelegate = {
        return PostContentTapGestureRecognizerDelegate()
    }()
    
    var contentTapGestureHandler: ((cell: PostCell) -> Void)?
}

extension PostCell {
    
    func reset() {
        headerView.avatarButton.setImage(nil, forState: .Normal)
        headerView.configure(nil, action: nil, timestamp: nil)
        
        for subview in contentStackView.arrangedSubviews {
            contentStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        
        actionBar.configure([])
    }
}

extension PostCell {
    
    @objc private func didTapContentArea(sender: UITapGestureRecognizer) {
        self.contentTapGestureHandler?(cell: self)
    }
}
