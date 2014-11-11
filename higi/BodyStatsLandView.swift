//
//  BodyStatsLandView.swift
//  higi
//
//  Created by Dan Harms on 7/22/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class BodyStatsLandView: UIView {
    
    @IBOutlet var buttonAll: UIButton!
    @IBOutlet var button6m: UIButton!
    @IBOutlet var button3m: UIButton!
    @IBOutlet var button1m: UIButton!
    @IBOutlet var pager: UIPageControl!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    
    class func instanceFromNib() -> BodyStatsLandView {
        return UINib(nibName: "BodyStatsLand", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as BodyStatsLandView
    }
    
}