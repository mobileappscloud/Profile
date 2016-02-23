//
//  TextCollectionViewCell.swift
//  higi
//
//  Created by Remy Panicker on 12/4/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import UIKit

/// Collection view cell intended for use with a text label.
final class TextCollectionViewCell: UICollectionViewCell {

    static let cellReuseIdentifier = "TextCollectionViewCellReuseIdentifier"
    
    @IBOutlet var textLabel: UILabel!
    
    @IBOutlet var bottomAccessoryView: UIView!
}
