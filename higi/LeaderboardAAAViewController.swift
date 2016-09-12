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
        let leaderboardRankingsController = LeaderboardRankingsController(rankings: self.leaderboardAAAController.leaderboardMemberAnalysisAndRankings.rankings!)
        vc.configure(userController: self.userController, leaderboardRankingsController: leaderboardRankingsController, pageIndex: 0)
        return vc
    }()
    
    private lazy var leaderboardComparisonViewController: LeaderboardTableViewController = {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier(String(LeaderboardTableViewController.self)) as! LeaderboardTableViewController // temporary
        let leaderboardRankingsController = LeaderboardRankingsController(rankings: self.leaderboardAAAController.leaderboardMemberAnalysisAndRankings.rankings!)
        vc.configure(userController: self.userController, leaderboardRankingsController: leaderboardRankingsController, pageIndex: 1)
        return vc
    }()
    
    // Outlets
    
    @IBOutlet var pageControl: UIPageControl! {
        didSet {
            pageControl.numberOfPages = 2
            pageControl.currentPage = 0
        }
    }
    
    @IBOutlet var memberAnalysisImageView: UIImageView! {
        didSet {
            memberAnalysisImageView.setImage(withMediaAsset: leaderboardAAAController.leaderboardMemberAnalysisAndRankings.analysis?.image)
        }
    }

}

// MARK: - Lifecycle

extension LeaderboardAAAViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let pageViewController = segue.destinationViewController as? UIPageViewController where segue.identifier == "toPageViewController" {
            pageViewController.dataSource = self
            pageViewController.delegate = self
            pageViewController.setViewControllers([leaderboardTableViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        }
    }
}

// MARK: - Configuration

extension LeaderboardAAAViewController {
    func configure(userController userController: UserController, leaderboardAAAController: LeaderboardAAAController) {
        self.userController = userController
        self.leaderboardAAAController = leaderboardAAAController
    }
}

// MARK: - Page View Controller Data Source

extension LeaderboardAAAViewController: UIPageViewControllerDataSource {
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if viewController === leaderboardTableViewController {
            return nil
        }
        if viewController === leaderboardComparisonViewController {
            return leaderboardTableViewController
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if viewController === leaderboardTableViewController {
            return leaderboardComparisonViewController
        }
        if viewController === leaderboardComparisonViewController {
            return nil
        }
        return nil
    }
}

// MARK: - Page View Controller Delegate

extension LeaderboardAAAViewController: UIPageViewControllerDelegate {
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    }
}


// MARK: - Page View Controller Enums

extension LeaderboardAAAViewController {
    enum Page {
        case leaderboard
        case comparison
    }
}
