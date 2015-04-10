//
//  TourViewController.swift
//  higi
//
//  Created by Dan Harms on 8/25/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class TourViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pager: UIPageControl!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var skip: UIButton!
    @IBOutlet weak var done: UIButton!
    
    var firstImage, secondImage, thirdImage: UIImageView!
    
    var mode: String!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        switch (mode!) {
        case "dashboard":
            loadDashboardTour();
        case "bodystats":
            loadBodyStatsTour();
        default:
            closeTour(nil);
        }
        scrollView.addSubview(firstImage);
        scrollView.addSubview(secondImage);
        scrollView.addSubview(thirdImage);
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        skip.layer.borderWidth = 1;
        skip.layer.borderColor = UIColor.whiteColor().CGColor;
        var frame = self.view.frame;
        scrollView.frame = frame;
        scrollView.contentSize = CGSize(width: 3 * frame.size.width, height: frame.size.height);
        backgroundImage.frame = frame;
        firstImage.frame = frame;
        frame.origin.x += self.view.frame.size.width;
        secondImage.frame = frame;
        frame.origin.x += self.view.frame.size.width;
        thirdImage.frame = frame;
    }
    
    
    
    func loadDashboardTour() {
        backgroundImage.image = Utility.iphone5Image("dashboard_background");
        firstImage = UIImageView(image: Utility.iphone5Image("dashboard1"));
        secondImage = UIImageView(image: Utility.iphone5Image("dashboard2"));
        thirdImage = UIImageView(image: Utility.iphone5Image("dashboard3"));
    }
    
    func loadBodyStatsTour() {
        backgroundImage.image = Utility.iphone5Image("bodystats_background");
        firstImage = UIImageView(image: Utility.iphone5Image("bodystats1"));
        secondImage = UIImageView(image: Utility.iphone5Image("bodystats2"));
        thirdImage = UIImageView(image: Utility.iphone5Image("bodystats3"));
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var page = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width));
        pager.currentPage = page;
        pagerChanged(pager);
    }
    
    @IBAction func pagerChanged(sender: AnyObject) {
        var page = pager.currentPage;
        
        var frame = scrollView.frame;
        
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        scrollView.setContentOffset(frame.origin, animated: true);
        if (page == 2) {
            skip.hidden = true;
            done.hidden = false;
        }
    }
    
    @IBAction func closeTour(sender: AnyObject!) {
        if (sender as! UIButton == skip) {
            Flurry.logEvent("\(mode)_Skipped");
        }
        (sender as! UIButton).enabled = false;
        self.presentingViewController?.dismissViewControllerAnimated(false, completion: nil);
    }
    
    override func shouldAutorotate() -> Bool {
        return false;
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue);
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait;
    }
    
}