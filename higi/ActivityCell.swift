//
//  ActivityCell.swift
//  higi
//
//  Created by Dan Harms on 10/29/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class ActivityCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var activity: UILabel!
    @IBOutlet weak var coloredPoint: UIView!
    @IBOutlet weak var points: UILabel!
    @IBOutlet weak var error: UILabel!
}