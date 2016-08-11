//
//  PostCell.swift
//  higi
//
//  Created by Remy Panicker on 6/27/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class PostCell: UITableViewCell, ActionBarDisplaying, ActionBarItemDelegate, TableCellActionBarItemDelegating {
    
    @IBOutlet var headerView: PostHeaderView!
    
    @IBOutlet var contentStackView: UIStackView! {
        didSet {
            contentStackView.addGestureRecognizer(self.tapGestureRecognizer)
        }
    }
    
    @IBOutlet var actionBar: ActionBar! {
        didSet {
            actionBar.actionItemDelegate = self
        }
    }
    
    lazy private var tapGestureRecognizer: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapContentArea))
        tap.delegate = self.tapDelegate
        return tap
    }()
    lazy private var tapDelegate: PostContentTapGestureRecognizerDelegate = {
        return PostContentTapGestureRecognizerDelegate()
    }()
    
    typealias ContentTapHandler = ((cell: PostCell) -> Void)
    var contentTapGestureHandler: ContentTapHandler?
    
    weak var cellActionBarItemDelegate: TableCellActionBarItemDelegate?
}

extension PostCell {
    
    func reset() {
        headerView.avatarButton.setImage(nil, forState: .Normal)
        headerView.primaryLabel.text = nil
        headerView.primaryLabel.attributedText = nil
        headerView.secondaryLabel.text = nil
        headerView.secondaryLabel.attributedText = nil
        
        for subview in contentStackView.arrangedSubviews {
            contentStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        
        actionBar.configure([])
        
        contentTapGestureHandler = nil
        
        cellActionBarItemDelegate = nil
    }
}

extension PostCell {
    
    @objc private func didTapContentArea(sender: UITapGestureRecognizer) {
        self.contentTapGestureHandler?(cell: self)
    }
}
