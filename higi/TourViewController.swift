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
    @IBOutlet weak var skip: UIButton! {
        didSet {
            skip.setTitle(NSLocalizedString("TOUR_VIEW_SKIP_BUTTON_TITLE", comment: "Title for 'skip' button on Tour view."), forState: .Normal)
        }
    }
    @IBOutlet weak var done: UIButton! {
        didSet {
            done.setTitle(NSLocalizedString("TOUR_VIEW_DONE_BUTTON_TITLE", comment: "Title for 'done' button on Tour view."), forState: .Normal)
        }
    }
    
    var firstImage, secondImage, thirdImage: UIImageView!
    
    var mode: String!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        switch (mode!) {
        case "dashboard":
            loadDashboardTour();
        case "Metrics":
            loadMetricsTour();
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
    
    func loadMetricsTour() {
        backgroundImage.image = Utility.iphone5Image("Metrics_background");
        firstImage = UIImageView(image: Utility.iphone5Image("Metrics1"));
        secondImage = UIImageView(image: Utility.iphone5Image("Metrics2"));
        thirdImage = UIImageView(image: Utility.iphone5Image("Metrics3"));
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let page = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width));
        pager.currentPage = page;
        pagerChanged(pager);
    }
    
    @IBAction func pagerChanged(sender: AnyObject) {
        let page = pager.currentPage;
        
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
}