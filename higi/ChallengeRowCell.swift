//
//  ChallengeRowCell.swift
//  higi
//
//  Created by Joe Sangervasi on 10/31/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class ChallengeRowCell: UITableViewCell {
    
    @IBOutlet var testView: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var daysLeft: UILabel!
    @IBOutlet var title: UILabel!
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var pager: UIPageControl!

    class func instanceFromNib() -> ChallengeRowCell {
        return UINib(nibName: "ChallengeRowCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeRowCell
    }
}