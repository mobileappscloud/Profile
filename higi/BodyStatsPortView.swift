//
//  BodyStatsPortView.swift
//  higi
//
//  Created by Dan Harms on 7/22/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class BodyStatsPortView: UIView {
    
    @IBOutlet var scrollView: UIScrollView!;
    @IBOutlet var pager: UIPageControl!;
    @IBOutlet var orientationIndicator: UIImageView!;
    
    class func instanceFromNib() -> BodyStatsPortView {
        return UINib(nibName: "BodyStatsPort", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! BodyStatsPortView
    }
    
}