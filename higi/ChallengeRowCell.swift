//
//  ChallengeRowCell.swift
//  higi
//
//  Created by Joe Sangervasi on 10/31/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class ChallengeRowCell: UITableViewCell {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var daysLeft: UILabel!
    @IBOutlet var title: UILabel!
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var pager: UIPageControl!
    
    var currentPage = 1

    class func instanceFromNib() -> ChallengeRowCell {
        return UINib(nibName: "ChallengeRowCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeRowCell
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var page = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width));
        self.pager.currentPage = page;
        changePage(self.pager);
    }
    
    @IBAction func changePage(sender: AnyObject) {
        var pager = sender as UIPageControl;
        var page = self.pager.currentPage;
        self.currentPage = page
        
        var frame = self.scrollView.frame;
        
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        self.scrollView.setContentOffset(frame.origin, animated: true);
    }
}