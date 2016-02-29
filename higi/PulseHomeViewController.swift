//
//  PulseHomeViewController.swift
//  higi
//
//  Created by Dan Harms on 8/4/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation
import QuartzCore
import SafariServices

class PulseHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var headerExcerpt: UILabel!
    
    var loadingArticles = false, doneRefreshing = true;
    
    var refreshArc: CAShapeLayer!;
    
    var refreshControl: UIRefreshControl!;
    
    var pullRefreshView: PullRefresh!;
    
    var prevArticles:[PulseArticle] = [];
    
    var universalLinkObserver: NSObjectProtocol? = nil    
    
    override func viewDidLoad()  {
        super.viewDidLoad();
        self.title = NSLocalizedString("PULSE_HOME_VIEW_TITLE", comment: "Title for Pulse view.");
        self.automaticallyAdjustsScrollViewInsets = false;
        tableView.separatorInset = UIEdgeInsetsZero;
        tableView.backgroundView?.backgroundColor = UIColor.blackColor();
        let pulseNib = UINib(nibName: "PulseCellView", bundle: nil)
        tableView.registerNib(pulseNib, forCellReuseIdentifier: "PulseCell")
        
        fillTopContainer();
        
        createPullToRefresh();
    }
    
    func fillTopContainer() {
        let article = SessionController.Instance.pulseArticles.first;
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
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (!loadingArticles && indexPath.item == SessionController.Instance.pulseArticles.count - 2) {
            loadingArticles = true;
            addMoreArticles();
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let adjustedIndexItem = indexPath.item + 1
        if !isValidIndex(adjustedIndexItem) {
            return UITableViewCell()
        }
        let article = SessionController.Instance.pulseArticles[adjustedIndexItem]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PulseCell", forIndexPath: indexPath) as! PulseCell
        cell.title.frame.size = CGSize(width: 194, height: 36);
        cell.title.text = article.title as String;
        cell.title.sizeToFit();
        cell.excerpt.text = article.excerpt as String;
        cell.excerpt.sizeToFit();
        cell.spinner.startAnimating();
        cell.articleImage.clipsToBounds = true;
        cell.articleImage.image = nil;
        cell.articleImage.setImageWithURL(NSURL(string: article.imageUrl as String));
        cell.clipsToBounds = true;
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let adjustedIndexItem = indexPath.item + 1
        if !isValidIndex(adjustedIndexItem) {
            return
        }
        
        let article = SessionController.Instance.pulseArticles[adjustedIndexItem]
        gotoArticle(article)
    }
    
    private func isValidIndex(index: Int) -> Bool {
        let maxIndex = SessionController.Instance.pulseArticles.count - 1
        return index <= maxIndex
    }
    
    func gotoArticle(article: PulseArticle) {
        let URLString = article.permalink
        if #available(iOS 9.0, *) {
            let URL = NSURL(string: URLString as String)!
            let safariViewController = SFSafariViewController(URL: URL, entersReaderIfAvailable: true)
            self.navigationController?.presentViewController(safariViewController, animated: true, completion: nil)
        } else {
            let webController = WebViewController(nibName: "WebView", bundle: nil);
            webController.url = URLString;
            self.navigationController!.pushViewController(webController, animated: true);
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateNavBar();
    }
    
    func updateNavBar() {
        let scrollY = tableView.contentOffset.y;
        if (scrollY >= 0) {
            CATransaction.setDisableActions(true);
            refreshArc.strokeStart = 0.0;
            refreshArc.strokeEnd = 0.0;
            CATransaction.setDisableActions(false);
            pullRefreshView.icon.alpha = 0.0;
            pullRefreshView.circleContainer.alpha = 0.0;
            pullRefreshView.backgroundColor = UIColor.clearColor();
        } else {
            let alpha = max(1.0 + scrollY / (tableView.frame.size.height * 0.195), 0.0);
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
            if SessionController.Instance.pulseArticles.count < self.prevArticles.count {
                SessionController.Instance.pulseArticles = self.prevArticles;
            }
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
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait;
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
        
        let toPath = UIBezierPath();
        let radius = pullRefreshView.circleContainer.frame.size.width / 2.0;
        let center = CGPoint(x: radius, y: radius);
        let startingPoint = CGPoint(x: center.x, y: 0);
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
        
        prevArticles = SessionController.Instance.pulseArticles;
        SessionController.Instance.pulseArticles = [];
        addMoreArticles();
    }
    
}

extension PulseHomeViewController: UniversalLinkHandler {
    
    func handleUniversalLink(URL: NSURL, pathType: PathType, parameters: [String]?) {
        
        let application = UIApplication.sharedApplication().delegate as! AppDelegate
        if application.didRecentlyLaunchToContinueUserActivity() {
            let loadingViewController = self.presentLoadingViewController()
            
            self.universalLinkObserver = NSNotificationCenter.defaultCenter().addObserverForName(ApiUtility.PULSE, object: nil, queue: nil, usingBlock: { (notification) in
                self.pushPulseView(URL, pathType: pathType, presentedViewController: loadingViewController)
                if let observer = self.universalLinkObserver {
                    NSNotificationCenter.defaultCenter().removeObserver(observer)
                }
            })
        } else {
            self.pushPulseView(URL, pathType: pathType, presentedViewController: nil)
        }
    }
    
    private func pushPulseView(URL: NSURL, pathType: PathType, presentedViewController: UIViewController?) {
        let pulseHomeViewController = PulseHomeViewController(nibName: "PulseHomeView", bundle: nil);
        dispatch_async(dispatch_get_main_queue(), {
            Utility.mainNavigationController()?.revealController.setFrontViewPosition(.Left, animated: false)
            
            presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
            Utility.mainNavigationController()?.drawerController.navController?.popToRootViewControllerAnimated(true)
            Utility.mainNavigationController()?.drawerController.navController?.pushViewController(pulseHomeViewController, animated: false)
        })
        
        if pathType == .PulseArticle {
            let article = PulseArticle(permalink: URL);
            pulseHomeViewController.gotoArticle(article);
        }
    }
}
