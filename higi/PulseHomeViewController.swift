//
//  PulseHomeViewController.swift
//  higi
//
//  Created by Dan Harms on 8/4/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation
import QuartzCore

class PulseHomeViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var headerExcerpt: UILabel!
    
    var loadingArticles = false, doneRefreshing = true;
    
    var refreshArc: CAShapeLayer!;
    
    var refreshControl: UIRefreshControl!;
    
    var pullRefreshView: PullRefresh!;
    
    override func viewDidLoad()  {
        super.viewDidLoad();
        self.title = "Pulse";
        self.automaticallyAdjustsScrollViewInsets = false;
        tableView.separatorInset = UIEdgeInsetsZero;
        tableView.backgroundView?.backgroundColor = UIColor.blackColor();
        
        fillTopContainer();
        
        createPullToRefresh();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        updateNavBar();
    }
    
    func fillTopContainer() {
        var article = SessionController.Instance.pulseArticles.first;
        if (article != nil) {
            headerTitle.text = article!.title as String;
            headerExcerpt.text = article!.excerpt as String;
            headerExcerpt.sizeToFit();
            headerImage.clipsToBounds = true;
            headerImage.setImageWithURL(NSURL(string: article!.imageUrl as String));
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SessionController.Instance.pulseArticles.count - 1;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (!loadingArticles && indexPath.item == SessionController.Instance.pulseArticles.count - 2) {
            loadingArticles = true;
            addMoreArticles();
        }
        var cell = tableView.dequeueReusableCellWithIdentifier("PulseCell") as! PulseCell!;
        if (cell == nil) {
            cell = UINib(nibName: "PulseCellView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! PulseCell;
        }
        var article = SessionController.Instance.pulseArticles[indexPath.item + 1];
        cell.title.frame.size = CGSize(width: 194, height: 36);
        cell.title.text = article.title as String;
        cell.title.sizeToFit();
        cell.excerpt.text = article.excerpt as String;
        cell.excerpt.sizeToFit();
        cell.spinner.startAnimating();
        cell.articleImage.clipsToBounds = true;
        cell.articleImage.image = nil;
        cell.articleImage.setImageWithURL(NSURL(string: article.imageUrl as String));
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        gotoArticle(SessionController.Instance.pulseArticles[indexPath.item + 1]);
    }
    
    func gotoArticle(article: PulseArticle) {
        var webController = WebViewController(nibName: "WebView", bundle: nil);
        webController.url = article.permalink;
        webController.isPulseArticle = true;
        self.navigationController!.pushViewController(webController, animated: true);
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateNavBar();
    }
    
    func updateNavBar() {
        var scrollY = tableView.contentOffset.y;
        if (scrollY >= 0) {
            CATransaction.setDisableActions(true);
            refreshArc.strokeStart = 0.0;
            refreshArc.strokeEnd = 0.0;
            CATransaction.setDisableActions(false);
            pullRefreshView.icon.alpha = 0.0;
            pullRefreshView.circleContainer.alpha = 0.0;
            pullRefreshView.backgroundColor = UIColor.clearColor();
            var alpha = min(scrollY / 100, 1);
            self.fakeNavBar.alpha = alpha;
            self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 1.0 - alpha, alpha: 1.0)];
            if (alpha < 0.5) {
                toggleButton!.setBackgroundImage(UIImage(named: "nav_ocmicon"), forState: UIControlState.Normal);
                toggleButton!.alpha = 1 - alpha;
                self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
                self.pointsMeter.setLightText();
            } else {
                toggleButton!.setBackgroundImage(UIImage(named: "nav_ocmicon_inverted"), forState: UIControlState.Normal);
                toggleButton!.alpha = alpha;
                self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
                self.pointsMeter.setDarkText();
            }
        } else {
            self.fakeNavBar.alpha = 0;
            self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 0)];
            var alpha = max(1.0 + scrollY / (tableView.frame.size.height * 0.195), 0.0);
            if (!refreshControl.refreshing && doneRefreshing) {
                pullRefreshView.icon.alpha = 1.0 - alpha;
                pullRefreshView.circleContainer.alpha = 1.0 - alpha;
                CATransaction.setDisableActions(true);
                refreshArc.strokeEnd = (1 - alpha);
                CATransaction.setDisableActions(false);
                if (alpha == 0) {
                    doneRefreshing = false;
                    refreshControl.beginRefreshing();
                    UIApplication.sharedApplication().beginIgnoringInteractionEvents();
                    refresh();
                }
            }
        }
    }
    
    func addMoreArticles() {
        ApiUtility.grabNextPulseArticles({
            self.tableView.reloadData();
            self.loadingArticles = false;
            if (self.refreshControl.refreshing) {
                self.fillTopContainer();
                self.refreshControl.endRefreshing();
            }
        });
    }
    
    @IBAction func gotoHeaderArticle(sender: AnyObject) {
        gotoArticle(SessionController.Instance.pulseArticles.first!);
    }
    
    override func shouldAutorotate() -> Bool {
        return false;
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue;
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait;
    }
    
    func createPullToRefresh() {
        pullRefreshView = UINib(nibName: "PullRefreshView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! PullRefresh;
        
        refreshControl = UIRefreshControl();
        refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged);
        refreshControl.tintColor = UIColor.clearColor();
        refreshControl.addSubview(pullRefreshView);
        tableView.addSubview(refreshControl);
        
        refreshArc = CAShapeLayer();
        refreshArc.lineWidth = 3;
        refreshArc.fillColor = UIColor.clearColor().CGColor;
        refreshArc.strokeColor = UIColor.whiteColor().CGColor;
        
        var toPath = UIBezierPath();
        var radius = pullRefreshView.circleContainer.frame.size.width / 2.0;
        var center = CGPoint(x: radius, y: radius);
        var startingPoint = CGPoint(x: center.x, y: 0);
        toPath.moveToPoint(startingPoint);
        toPath.addArcWithCenter(center, radius: radius, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(3 * M_PI_2), clockwise: true);
        toPath.closePath();
        
        refreshArc.path = toPath.CGPath;
        
        refreshArc.strokeStart = 0.0;
        refreshArc.strokeEnd = 0.0;
        
        pullRefreshView.circleContainer.layer.addSublayer(refreshArc);
        
    }
    
    func refresh() {
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 0.0)];
        pullRefreshView.icon.alpha = 1.0;
        pullRefreshView.circleContainer.alpha = 1.0;
        CATransaction.begin();
        CATransaction.setDisableActions(true);
        refreshArc.strokeStart = 0.0;
        refreshArc.strokeEnd = 1.0;
        CATransaction.setDisableActions(false);
        CATransaction.commit();
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            while (true) {
                dispatch_async(dispatch_get_main_queue(), {
                    CATransaction.begin();
                    CATransaction.setAnimationDuration(0.5);
                    self.refreshArc.strokeStart = 1.0;
                    CATransaction.commit();
                });
                NSThread.sleepForTimeInterval(0.6);
                if (!self.refreshControl.refreshing) {
                    break;
                }
                dispatch_async(dispatch_get_main_queue(), {
                    CATransaction.begin();
                    CATransaction.setDisableActions(true);
                    self.refreshArc.strokeEnd = 0.0;
                    self.refreshArc.strokeStart = 0.0;
                    CATransaction.setDisableActions(false);
                    CATransaction.commit();
                });
                NSThread.sleepForTimeInterval(0.05);
                dispatch_async(dispatch_get_main_queue(), {
                    CATransaction.begin();
                    CATransaction.setAnimationDuration(0.5);
                    self.refreshArc.strokeEnd = 1.0;
                    CATransaction.commit();
                });
                NSThread.sleepForTimeInterval(0.45);
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.pullRefreshView.circleContainer.alpha = 0;
                self.pullRefreshView.icon.alpha = 0;
                CATransaction.begin();
                CATransaction.setDisableActions(true);
                self.refreshArc.strokeStart = 0.0;
                self.refreshArc.strokeEnd = 0.0;
                CATransaction.setDisableActions(false);
                CATransaction.commit();
                self.doneRefreshing = true;
                UIApplication.sharedApplication().endIgnoringInteractionEvents();
            });
        });
        
        SessionController.Instance.pulseArticles = [];
        addMoreArticles();
    }
    
}