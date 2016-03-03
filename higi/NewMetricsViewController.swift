//
//  NewMetricsViewController.swift
//  higi
//
//  Created by Remy Panicker on 12/4/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import UIKit

private struct Storyboard {
    
    private struct Segue {
        static let embedCollectionViewIdentifier = "EmbedCollectionViewStoryboardSegueIdentifier"
        static let embedPageViewIdentifier = "EmbedPageViewStoryboardSegueIdentifier"
    }
}

final class NewMetricsViewController: UIViewController {
    
    /// Supported types of metrics
    lazy private(set) var types = MetricsType.allValues
    
    /// Image view which hints that the view supports resizing due to image rotation
    @IBOutlet private var rotateDeviceImageView: UIImageView!
    
    /// Collection view which serves as navigation menu.
    private var collectionViewController: TextCollectionViewController!
    
    /// Page view controller which contains child Metric views.
    private var pageViewController: MetricsPageViewController!
    
    /// Object which coordinates interactions between container views.
    lazy private(set) var coordinator: MetricsCoordinator = {
       return MetricsCoordinator(types: self.types)
    }()
    
    private var universalLinkCheckinsObserver: NSObjectProtocol? = nil
    private var universalLinkActivitiesObserver: NSObjectProtocol? = nil
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /** 
        @internal This must be set, otherwise -cellForItem: is not called on the collection view
        along with other unwanted side effects on container views with their own scroll views.
        */
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.title = NSLocalizedString("METRICS_VIEW_TITLE", comment: "Title for metrics view.")

        if let navigationController = self.navigationController {
            navigationController.hidesBarsWhenVerticallyCompact = true
        }
        
        self.coordinator.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Workaround to ensure selected collection view cell is centered and visible
        let selectedIndexPath = NSIndexPath(forItem: coordinator.selectedIndex, inSection: 0)
        self.collectionViewController.collectionView?.scrollToItemAtIndexPath(selectedIndexPath, atScrollPosition: .CenteredHorizontally, animated: false)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case Storyboard.Segue.embedCollectionViewIdentifier:
            guard let collectionViewController = segue.destinationViewController as? TextCollectionViewController else { break }
            
            self.collectionViewController = collectionViewController
            self.collectionViewController.collectionViewConfigurator = self.coordinator
            self.collectionViewController.collectionView?.delegate = self.coordinator
            self.collectionViewController.collectionView?.dataSource = self.coordinator
            self.collectionViewController.collectionView?.backgroundColor = UIColor(white: 0.945, alpha: 1.0)
            
        case Storyboard.Segue.embedPageViewIdentifier:
            guard let pageViewController = segue.destinationViewController as? MetricsPageViewController else { break }
            guard let childViewController = self.coordinator.pageViewControllers.first else { break }
            
            self.pageViewController = pageViewController
            self.pageViewController.delegate = self.coordinator
            self.pageViewController.dataSource = self.coordinator
            self.pageViewController.setViewControllers([childViewController], direction: .Forward, animated: false, completion: nil)
            
        default:
            break
        }
    }
}

extension NewMetricsViewController {
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let isVerticallyCompact = self.traitCollection.verticalSizeClass == .Compact
        
        // Disable scrolling between page views when the screen is vertically compact
        let scrollEnabled = !isVerticallyCompact
        self.pageViewController.scrollEnabled(scrollEnabled)
        
        // Invalidate collection view layout so that insets are recalculated for new container dimensions
        self.collectionViewController.collectionViewLayout.invalidateLayout()
        
        // After size class changes, the selected collection cell should be re-centered to ensure that it is fully visible on-screen.
        let indexPath = NSIndexPath(forItem: self.coordinator.selectedIndex, inSection: 0)
        // For some reason, this causes the simulator to crash. When targeting the simulator, Xcode will display a warning that this code will never execute, but that is a target specific warning.
        if TARGET_OS_SIMULATOR != 1 {
            // Scroll the cell after a slight delay so that the rotation animation can complete.
            Utility.delay(0.2, closure: { [weak self] in
                self?.collectionViewController.collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
            })
        }
        
        if isVerticallyCompact {
            rotateDeviceImageView.hidden = true
            if !PersistentSettingsController.boolForKey(.MetricsViewDidRotateDeviceToVerticalSizeClassCompact) {
                PersistentSettingsController.setBool(true, key: .MetricsViewDidRotateDeviceToVerticalSizeClassCompact)
            }
        } else {
            rotateDeviceImageView.hidden = PersistentSettingsController.boolForKey(.MetricsViewDidRotateDeviceToVerticalSizeClassCompact)
        }
    }
}

// MARK: - Metrics Coordinator Delegate

extension NewMetricsViewController: MetricsCoordinatorDelegate {
    
    /**
     Forwarding method which notifies the delegate that a new page viewcontroller has appeared.
     
     - parameter viewController: View controller which is currently visible in page view controller.
     - parameter animated:       'true' if the page transition was animated, otherwise `false`.
     - parameter toIndexPath:    Index path for the view controller which was previously displayed.
     - parameter fromIndexPath:  Index path for the view controller which is currently displayed.
     */
    func metricChildViewController(viewController: MetricChildViewController, didAppearAnimated animated: Bool, toIndexPath: NSIndexPath, fromIndexPath: NSIndexPath?) {
        // Ensure collection view updates in response to page view transition which is completed without triggering the scroll delegate method.
        self.collectionViewController.collectionView?.scrollToItemAtIndexPath(toIndexPath, atScrollPosition: .CenteredHorizontally, animated: true)
        self.collectionViewController.collectionView?.reloadData()
    }
    
    /**
     Forwarding method which notifies the delegate that a new page view controller has been transitioned to.
     
     - parameter pageController: Instance of `UIPageViewController` which contains child view controllers.
     - parameter toIndexPath:    Index path for the view controller which was previously displayed.
     - parameter fromIndexPath:  Index path for the view controller which is currently displayed.
     */
    func metricsPageViewController(pageController: UIPageViewController, didTransitionToViewControllerAtIndexPath toIndexPath: NSIndexPath, fromViewControllerAtIndexPath fromIndexPath: NSIndexPath) {
        
        /** @internal
        Intentionally left unimplemented for the time being because the `UIPageViewController` API doesn't have a method which is called any time a page transition occurs. This method only handles page transitions generated by a swipe gesture with enough velocity to transition to the next page. If the user pans very slowly, the page view will transition to the next view controller, but this method is never called and the transition is only communicated via `UIViewController`'s `-viewDidAppear:`. We will rely on UIViewController's view lifecycle methods until a better solution is found. Please refer to `MetricChildViewLifecycleResponder`.
        */
    }
    
    /**
     Forwarding method which notifies the delegate that cell selection has occurred.
     
     - parameter collectionView:    Instance of `UICollectionView` with cells.
     - parameter indexPath:         Index path of the collection view cell which was selected.
     - parameter previousIndexPath: Index path of the collection view cell which was previously selected.
     */
    func metricsTypeCollectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath, previouslyAtIndexPath previousIndexPath: NSIndexPath?) {
        
        var direction: UIPageViewControllerNavigationDirection = .Forward
        if let previousIndexPath = previousIndexPath?.item where indexPath.item < previousIndexPath {
            direction = .Reverse
        }
        
        let viewController = self.coordinator.pageViewControllers[indexPath.item]

        if self.traitCollection.verticalSizeClass == .Compact {
            self.pageViewController.setViewControllers([viewController], direction: direction, animated: false, completion: nil)
        } else {
            // Workaround for UIPageViewController bug when animating transition:  http://stackoverflow.com/a/17330606
            self.pageViewController.setViewControllers([viewController], direction: direction, animated: true, completion: { (finished) in
                if !finished {
                    return
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.pageViewController.setViewControllers([viewController], direction: direction, animated: false, completion: nil)
                })
            })
        }
    }
}

// MARK: - Navigation

extension NewMetricsViewController {
    
    func navigate(toMetricViewWithType metricType: MetricsType) {
        guard let targetIndex = self.types.indexOf(metricType) else { return }
        
        let indexPath = NSIndexPath(forItem: targetIndex, inSection: 0)
        self.collectionViewController.collectionView?.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .CenteredHorizontally)
        self.collectionViewController.collectionView?.delegate?.collectionView!(self.collectionViewController.collectionView!, didSelectItemAtIndexPath: indexPath)        
    }
}

// MARK: - Universal Link

extension NewMetricsViewController: UniversalLinkHandler {
    
    func handleUniversalLink(URL: NSURL, pathType: PathType, parameters: [String]?) {
        
        var loadedActivities = false
        var loadedCheckins = false
        let application = UIApplication.sharedApplication().delegate as! AppDelegate
        if application.didRecentlyLaunchToContinueUserActivity() {
            let loadingViewController = self.presentLoadingViewController()
            
            self.universalLinkActivitiesObserver = NSNotificationCenter.defaultCenter().addObserverForName(ApiUtility.ACTIVITIES, object: nil, queue: nil, usingBlock: { (notification) in
                loadedActivities = true
                self.navigateToMetricsView(pathType, loadedActivites: loadedActivities, loadedCheckins: loadedCheckins, presentedViewController: loadingViewController)
                if let observer = self.universalLinkActivitiesObserver {
                    NSNotificationCenter.defaultCenter().removeObserver(observer)
                }
            })
            self.universalLinkCheckinsObserver = NSNotificationCenter.defaultCenter().addObserverForName(ApiUtility.CHECKINS, object: nil, queue: nil, usingBlock: { (notification) in
                loadedCheckins = true
                self.navigateToMetricsView(pathType, loadedActivites: loadedActivities, loadedCheckins: loadedCheckins, presentedViewController: loadingViewController)
                if let observer = self.universalLinkCheckinsObserver {
                    NSNotificationCenter.defaultCenter().removeObserver(observer)
                }
            })
        } else {
            self.navigateToMetricsView(pathType, loadedActivites: true, loadedCheckins: true, presentedViewController: nil)
        }
    }
    
    private func navigateToMetricsView(pathType: PathType, loadedActivites: Bool, loadedCheckins: Bool, presentedViewController: UIViewController?) {
        if !loadedActivites || !loadedCheckins {
            return
        }
        
        let targetMetricsType: MetricsType
        switch pathType {
        case .MetricsBloodPressure:
            targetMetricsType = .BloodPressure
        case .MetricsPulse:
            targetMetricsType = .Pulse
        case .MetricsWeight:
            targetMetricsType = .Weight
        default:
            targetMetricsType = .DailySummary
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
            self.navigate(metricsType: targetMetricsType)
        })
    }
    
    func navigate(metricsType type: MetricsType) {
        guard let mainTabBarController = Utility.mainTabBarController() else { return }
        
        mainTabBarController.selectedIndex = TabBarController.ViewControllerIndex.Metrics.rawValue
        // Dumb workaround which ensures embedded view controllers are loaded
        Utility.delay(0.1, closure: {
            mainTabBarController.metricsViewController.navigate(toMetricViewWithType: type)
        })
    }
}
