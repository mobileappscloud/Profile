//
//  BpCheckinCell.swift
//  higi
//
//  Created by Dan Harms on 8/13/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class BpCheckinCell: UITableViewCell {
    
    @IBOutlet weak var gauge: UIImageView!
    @IBOutlet weak var systolicArrow: UIImageView!
    @IBOutlet weak var systolicChange: UILabel!
    @IBOutlet weak var diastolicArrow: UIImageView!
    @IBOutlet weak var diastolicChange: UILabel!
    @IBOutlet weak var systolic: UILabel!
    @IBOutlet weak var diastolic: UILabel!
    @IBOutlet weak var bpClass: UILabel!
}