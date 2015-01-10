//
//  ChallengeDetailsViewController.swift
//  higi
//
//  Created by Jack Miller on 1/9/15.
//  Copyright (c) 2015 higi, LLC. All rights reserved.
//

import Foundation

class ChallengeDetailsViewController: BaseViewController, UIScrollViewDelegate {
    @IBOutlet var pointsLabel:UILabel?;
    
    @IBOutlet weak var participantProgress: UIView!
    @IBOutlet weak var challengeTitle: UILabel!
    @IBOutlet weak var challengeAvatar: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet weak var calendarIcon: UILabel!
    @IBOutlet weak var challengeDaysLeft: UILabel!
    @IBOutlet weak var participantAvatar: UIImageView!
    @IBOutlet weak var placeLabel: UILabel!
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateScroll();
    }
    
    func updateScroll() {
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
    }
    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        return true;
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var page = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width));
        changePage(page);
    }
    
    func changePage(page: Int) {

        var frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        scrollView.setContentOffset(frame.origin, animated: true);
    }
}