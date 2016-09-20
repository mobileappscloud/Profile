//
//  LeaderboardAAAViewController.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 9/8/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class LeaderboardAAAViewController: UIViewController {
    
    // Injected
    private var userController: UserController!
    private var leaderboardAAAController: LeaderboardAAAController!
    
    // Lazy
    private lazy var leaderboardTableViewController: LeaderboardTableViewController = {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier(String(LeaderboardTableViewController.self)) as! LeaderboardTableViewController
        let leaderboardRankingsController = LeaderboardRankingsController(rankings: self.leaderboardAAAController.leaderboardMemberAnalysisAndRankings!.rankings!)
        vc.configure(userController: self.userController, leaderboardRankingsController: leaderboardRankingsController, pageIndex: 0)
        return vc
    }()
    
    private lazy var leaderboardComparisonViewController: LeaderboardComparisonViewController = {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier(String(LeaderboardComparisonViewController.self)) as! LeaderboardComparisonViewController
        vc.configure(userController: self.userController, leaderboardAAAController: self.leaderboardAAAController, pageIndex: 1)
        return vc
    }()
    
    lazy private var loadingViewController: UIViewController = {
        let storyboard = UIStoryboard(name: LeaaderboardAAAStoryboard.name, bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier(LeaaderboardAAAStoryboard.LeaderboardViewLoading.storyboardIdentifier)
        return viewController
    }()
    
    // Stored
    private var pendingPageIndex = 0
    private var pagedViewControllers: [UIViewController] = []
    private var leaderboardPageViewController: UIPageViewController?
    
    // Outlets
    
    @IBOutlet var headerStackView: UIStackView!
    
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var memberAnalysisImageView: UIImageView!
    
    @IBOutlet var progressionTimeLabel: UILabel! {
        didSet {
            progressionTimeLabel.textColor = Theme.Color.Leaderboard.AAAView.progressionTimeText
            progressionTimeLabel.text = nil
        }
    }
    @IBOutlet var analysisTextLabel: UILabel! {
        didSet {
            analysisTextLabel.textColor = Theme.Color.Leaderboard.AAAView.leaderboardMessageText
        }
    }
    @IBOutlet var actionTeaserTextLabel: UILabel! {
        didSet {
            actionTeaserTextLabel.textColor = Theme.Color.Leaderboard.AAAView.inviteYourFriendsText
        }
    }
    
    @IBOutlet var pageContainerViewTopConstraint: NSLayoutConstraint!
}

// MARK: - Lifecycle

extension LeaderboardAAAViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("LEADERBOARD_VIEW_TITLE_TEXT", comment: "The text for the title of the leaderboard view.")
        showPlaceholderView()
        fetchLeaderboardAnalysisAndRankings()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let pageViewController = segue.destinationViewController as? UIPageViewController where segue.identifier == "toPageViewController" {
            pageViewController.dataSource = self
            pageViewController.delegate = self
            leaderboardPageViewController = pageViewController
            pageViewController.view.backgroundColor = Theme.Color.Leaderboard.AAAView.pageViewControllerBackground
        }
    }
}

// MARK: - Helpers

extension LeaderboardAAAViewController {
    private func fetchLeaderboardAnalysisAndRankings() {
        leaderboardAAAController.fetchLeaderboardAnalysisAndRankings(userController.user, success: {
            [weak self] in
            dispatch_async(dispatch_get_main_queue(), {
                self?.configureView()
                self?.hidePlaceholderView()
            })
        }, failure: {
            [weak self]
            error in
            dispatch_async(dispatch_get_main_queue(), {
                self?.hidePlaceholderView()
                // TODO: Peter Ryszkiewicz: Handle
            })
        })

    }
}

// MARK: - Configuration

extension LeaderboardAAAViewController {
    func configure(userController userController: UserController, leaderboardOwnerId: UniqueId) {
        self.userController = userController
        self.leaderboardAAAController = LeaderboardAAAController(leaderboardOwnerId: leaderboardOwnerId)
    }
    
    private func configureView() {
        memberAnalysisImageView.setImage(withMediaAsset: leaderboardAAAController.leaderboardMemberAnalysisAndRankings?.analysis?.image)

        // The design requirement is to print the day before the start of the analysis date.
        if let startDate = leaderboardAAAController.leaderboardMemberAnalysisAndRankings?.rankings?.renderInfo.startDate, let dayBeforeStartDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: -1, toDate: startDate, options: []) {
            let sinceDateFormat = NSLocalizedString("LEADERBOARD_VIEW_SINCE_DATE_FORMAT", comment: "Format for text that tells the user since when they had a leaderboard analysis.")
            let sinceText = NSLocalizedString("LEADERBOARD_VIEW_SINCE_TEXT", comment: "Text that tells the user 'since' when they had a leaderboard analysis.")
            let formattedDate = NSDateFormatter.yyyyMMddDateFormatter.stringFromDate(dayBeforeStartDate)
            progressionTimeLabel.text = String(format: sinceDateFormat, arguments: [sinceText, formattedDate])
        }
        analysisTextLabel.text = leaderboardAAAController.leaderboardMemberAnalysisAndRankings?.analysis?.text
        actionTeaserTextLabel.text = leaderboardAAAController.leaderboardMemberAnalysisAndRankings?.analysis?.action?.teaser
        
        if leaderboardAAAController.leaderboardMemberAnalysisAndRankings?.analysis != nil {
            pagedViewControllers = [leaderboardTableViewController, leaderboardComparisonViewController]
        } else {
            pagedViewControllers = [leaderboardTableViewController]
        }
        pageControl.numberOfPages = pagedViewControllers.count
        pageControl.currentPage = 0

        leaderboardPageViewController?.setViewControllers([pagedViewControllers[0]], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        
        if leaderboardAAAController.leaderboardMemberAnalysisAndRankings?.analysis == nil {
            pageContainerViewTopConstraint.active = true
            headerStackView.removeFromSuperview()
        }
    }
}

// MARK: - Page View Controller Data Source

extension LeaderboardAAAViewController: UIPageViewControllerDataSource {
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = (viewController as? PageIndexed)?.pageIndex else { return nil }
        let nextIndex = currentIndex - 1
        guard pagedViewControllers.indices.contains(nextIndex) else { return nil }
        return pagedViewControllers[nextIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = (viewController as? PageIndexed)?.pageIndex else { return nil }
        let nextIndex = currentIndex + 1
        guard pagedViewControllers.indices.contains(nextIndex) else { return nil }
        return pagedViewControllers[nextIndex]
    }
}

// MARK: - Page View Controller Delegate

extension LeaderboardAAAViewController: UIPageViewControllerDelegate {
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        if let pendingPageIndex = (pendingViewControllers.first as? PageIndexed)?.pageIndex {
            self.pendingPageIndex = pendingPageIndex
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            pageControl.currentPage = pendingPageIndex
        }
    }
}

// MARK: - Page Control Action

extension LeaderboardAAAViewController {
    
    @IBAction func pageControlValueChanged(sender: AnyObject) {
        togglePage()
    }
    
    private func togglePage() {
        guard let currentVC = leaderboardPageViewController?.viewControllers?.first as? PageIndexed else { return }
        guard pageControl.currentPage != currentVC.pageIndex else { return }
        let navigationDirection: UIPageViewControllerNavigationDirection = pageControl.currentPage > currentVC.pageIndex ? .Forward : .Reverse
        leaderboardPageViewController?.setViewControllers([pagedViewControllers[pageControl.currentPage]], direction: navigationDirection, animated: true, completion: nil)
    }
}

// MARK: - Page View Controller Enums

extension LeaderboardAAAViewController {
    enum Page {
        case leaderboard
        case comparison
    }
}

private struct LeaaderboardAAAStoryboard {
    static let name = "LeaderboardAAA"
    struct LeaderboardViewLoading {
        static let storyboardIdentifier = String(LeaderboardViewLoading.self)
    }
}

// MARK: - Loading View

extension LeaderboardAAAViewController {
    func showPlaceholderView() {
        addChildViewController(loadingViewController)
        loadingViewController.view.alpha = 1.0
        view.addSubview(loadingViewController.view)
        loadingViewController.view.frame = view.bounds
        loadingViewController.didMoveToParentViewController(self)
    }
    
    func hidePlaceholderView() {
        loadingViewController.willMoveToParentViewController(nil)
        view.willRemoveSubview(loadingViewController.view)
        UIView.animateWithDuration(0.2, animations: {
            self.loadingViewController.view.alpha = 0.0
        }, completion: { (success) in
            self.loadingViewController.view.removeFromSuperview()
            self.loadingViewController.didMoveToParentViewController(nil)
        })
    }
}

// MARK: - Protocols
protocol PageIndexed {
    var pageIndex: Int! { get } // Implicitly unwrapped to be injectable
}