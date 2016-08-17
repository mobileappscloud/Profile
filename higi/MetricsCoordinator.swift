//
//  MetricsCoordinator.swift
//  higi
//
//  Created by Remy Panicker on 12/7/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import Foundation
import UIKit

private let defaultItemHeight: CGFloat = 40.0
private let defaultTextColor = UIColor.blackColor()
private let defaultSelectedTextColor = Theme.Color.primary

final class MetricsCoordinator: NSObject {
    
    weak var delegate: MetricsCoordinatorDelegate? = nil
    
    /// Supported types of metrics
    let types: [MetricsType]!

    /// Stores index of previously selected metric. **Warning:** Do not write to this property directly as it automatically tracks the `selectedIndex`.
    private(set) var previouslySelectedIndex: Int? = nil
    
    /// Stores index of currently selected metric
    var selectedIndex: Int = 0 {
        willSet {
            self.previouslySelectedIndex = self.selectedIndex
        }
    }
    
    /// Maximum allowable index based on metric types
    private var maxIndex: Int { get {
            return self.types.count - 1
        }
    }
    
    /// Data set with various metric graph points.
    lazy private var dataSet: MetricGraphPoints = {
        let dataFactory = MetricDataFactory()
        
//        let data = MetricDataFactory().metricData(nil, activitiesDictionary: nil)
        
        let data = dataFactory.metricData(SessionController.Instance.checkins, activitiesDictionary: SessionController.Instance.activities)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MetricsCoordinator.didRefreshData(_:)), name: ApiUtility.ACTIVITIES, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MetricsCoordinator.didRefreshData(_:)), name: ApiUtility.CHECKINS, object: nil)
        
        return data
    }()
    
    /// Array of view controllers corresponding with metric types
    private(set) lazy var pageViewControllers: [UIViewController] = {
        var viewControllers: [UIViewController] = []
        for index in 0...self.maxIndex {
            
            let child = UIStoryboard(name: "MetricsPage", bundle: nil).instantiateInitialViewController() as! MetricChildViewController
            child.viewLifecycleResponder = self
            let type = self.types[index]
            child.configure(type)
            
            let delegate: NewMetricDelegate!
            switch type {
            case .DailySummary:
                let activityDelegate = NewActivityMetricDelegate(data: self.dataSet.dailySummary)
                activityDelegate.dailySummaryPresentationDelegate = child
                delegate = activityDelegate
            case .BloodPressure:
                delegate = NewBloodPressureMetricDelegate(data: self.dataSet.bloodPressure)
            case .Pulse:
                delegate = NewPulseMetricDelegate(data: self.dataSet.pulse)
            case .Weight:
                delegate = NewWeightMetricDelegate(data: self.dataSet.weight)
            case .BodyMassIndex:
                delegate = NewBodyMassIndexMetricDelegate(data: self.dataSet.bodyMassIndex)
            case .BodyFat:
                delegate = NewBodyFatMetricDelegate(data: self.dataSet.bodyFat)
            }
            child.metricDelegate = delegate
            
            viewControllers.append(child)
        }
        return viewControllers
    }()
    
    let referenceCell: TextCollectionViewCell = {
        let nib = UINib(nibName: "TextCollectionViewCell", bundle: nil)
        let cell = nib.instantiateWithOwner(nil, options: nil).first
        return cell as! TextCollectionViewCell
    }()
    
    init(types: [MetricsType]) {
        self.types = types
    }
}

// MARK: - Data Refresh

extension MetricsCoordinator {
    
    func didRefreshData(notification: NSNotification) {
        self.dataSet = MetricDataFactory().metricData(SessionController.Instance.checkins, activitiesDictionary: SessionController.Instance.activities)
        for viewController in pageViewControllers {
            guard let viewController = viewController as? MetricChildViewController else { break }
            guard let type = viewController.type else { break }
            guard let delegate = viewController.metricDelegate else { break }
            
            switch type {
            case .DailySummary:
                if let delegate = delegate as? NewActivityMetricDelegate {
                    delegate.updateData(self.dataSet.dailySummary)
                }
            case .BloodPressure:
                if let delegate = delegate as? NewBloodPressureMetricDelegate {
                    delegate.updateData(self.dataSet.bloodPressure)
                }
            case .Pulse:
                if let delegate = delegate as? NewPulseMetricDelegate {
                    delegate.updateData(self.dataSet.pulse)
                }
            case .Weight:
                if let delegate = delegate as? NewWeightMetricDelegate {
                    delegate.updateData(self.dataSet.weight)
                }
            case .BodyMassIndex:
                if let delegate = delegate as? NewBodyMassIndexMetricDelegate {
                    delegate.updateData(self.dataSet.bodyMassIndex)
                }
            case .BodyFat:
                if let delegate = delegate as? NewBodyFatMetricDelegate {
                    delegate.updateData(self.dataSet.bodyFat)
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                viewController.reloadData()
            })
        }
    }
}

// MARK: - View Lifecycle Responder

extension MetricsCoordinator: MetricChildViewLifecycleResponder {
   
    func metricChildViewController(viewController: MetricChildViewController, didAppearAnimated animated: Bool) {
        guard let viewControllerIndex = self.pageViewControllers.indexOf(viewController) else {
            return
        }
        if self.selectedIndex == viewControllerIndex {
            return
        }
        
        self.selectedIndex = viewControllerIndex
        let toIndexPath = NSIndexPath(forItem: self.selectedIndex, inSection: 0)
        var fromIndexPath: NSIndexPath?
        if let fromIndex = self.previouslySelectedIndex {
            fromIndexPath = NSIndexPath(forItem: fromIndex, inSection: 0)
        }
        self.delegate?.metricChildViewController(viewController, didAppearAnimated: animated, toIndexPath: toIndexPath, fromIndexPath: fromIndexPath)
        
    }
}

// MARK: - Page View Controller

extension MetricsCoordinator: UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {

        var index = self.pageViewControllers.indexOf(viewController)!
        if index == 0 {
            index = self.maxIndex
        } else {
            index -= 1
        }
        return self.pageViewControllers[index]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var index = self.pageViewControllers.indexOf(viewController)!
        if index == self.maxIndex {
            index = 0
        } else {
            index += 1
        }
        return self.pageViewControllers[index]
    }
}

extension MetricsCoordinator: UIPageViewControllerDelegate {
        
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        if !completed {
            return
        }

        guard let previousViewController = previousViewControllers.first,
            let previousIndex = self.pageViewControllers.indexOf(previousViewController),
            let currentViewController = pageViewController.viewControllers?.first,
            let currentIndex = self.pageViewControllers.indexOf(currentViewController) else {
                return
        }
        
        self.selectedIndex = currentIndex
        
        let toIndexPath = NSIndexPath(forItem: currentIndex, inSection: 0)
        let fromIndexPath = NSIndexPath(forItem: previousIndex, inSection: 0)
        
        self.delegate?.metricsPageViewController(pageViewController, didTransitionToViewControllerAtIndexPath: toIndexPath, fromViewControllerAtIndexPath: fromIndexPath)
    }
}

// MARK: - Collection View

extension MetricsCoordinator: TextMenuCollectionViewConfiguration {
    
}

extension MetricsCoordinator: UICollectionViewDataSource {
    
    private enum Sections: Int {
        case Metrics
        case _count
    }
    
    private enum MetricCell: Int {
        case DailySummary
        case BloodPressure
        case Pulse
        case Weight
        case BodyMassIndex
        case BodyFat
        case _count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return Sections._count.rawValue
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        
        if let aSection = Sections(rawValue: section) {
            switch aSection {
            case .Metrics:
                count = MetricCell._count.rawValue
            case ._count:
                break
            }
        }
        return count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell: UICollectionViewCell? = nil
        
        if let section = Sections(rawValue: indexPath.section) {
            switch section {
            case .Metrics:
                let textCell = collectionView.dequeueReusableCellWithReuseIdentifier(TextCollectionViewCell.cellReuseIdentifier, forIndexPath: indexPath) as! TextCollectionViewCell
                
                self.configureCell(textCell, indexPath: indexPath)
                
                cell = textCell
            case ._count:
                break
            }
        }
        
        return cell!
    }
    
    private func configureCell(cell: TextCollectionViewCell, indexPath: NSIndexPath) {
        
        var text: String? = nil
        if let item = MetricCell(rawValue: indexPath.row) {
            switch item {
            case .DailySummary:
                text = "Activity"
            case .BloodPressure:
                text = "Blood Pressure"
            case .Pulse:
                text = "Pulse"
            case .Weight:
                text = "Weight"
            case .BodyMassIndex:
                text = "BMI"
            case .BodyFat:
                text = "Body Fat"
            case ._count:
                break
            }
        }
        cell.textLabel.text = text
        
        let color: UIColor!
        let font: UIFont!
        let hideAccessoryView: Bool!
        if indexPath.row == self.selectedIndex {
            color = defaultSelectedTextColor
            font = UIFont.boldSystemFontOfSize(15.0)
            hideAccessoryView = false
        } else {
            color = defaultTextColor
            font = UIFont.systemFontOfSize(15.0)
            hideAccessoryView = true
        }
        cell.textLabel.textColor = color
        cell.textLabel.font = font
        cell.bottomAccessoryView.backgroundColor = color
        cell.bottomAccessoryView.hidden = hideAccessoryView
    }
}

extension MetricsCoordinator: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedIndex = indexPath.item
        var previousIndexPath: NSIndexPath? = nil
        if self.previouslySelectedIndex != nil {
            previousIndexPath = NSIndexPath(forItem: self.previouslySelectedIndex!, inSection: 0)
        }
        
        self.delegate?.metricsTypeCollectionView(collectionView, didSelectItemAtIndexPath: indexPath, previouslyAtIndexPath: previousIndexPath)
        
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
        collectionView.reloadData()
    }
}

extension MetricsCoordinator: UICollectionViewDelegateFlowLayout {

    // Dynamic-sizing
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        self.configureCell(referenceCell, indexPath: indexPath)
        var size = referenceCell.systemLayoutSizeFittingSize(UILayoutFittingExpandedSize)
        size.height = defaultItemHeight
        
        return size
    }

    // Provide left/right insets so that the content view is centered aligned
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {

        guard let collectionViewLayout = collectionViewLayout as? SingleRowTextMenuFlowLayout else { return UIEdgeInsetsZero }

        // Assume the collection view fills the screen width. The only way to get an accurate reading of the current collection view width is by querying `self` on the collection view's superview, but this is not feasible when decoupling the flow layout delegate method from the collection view's metricDelegate view.
        let collectionViewWidth = UIScreen.mainScreen().bounds.size.width
        
        var contentSizeWidth: CGFloat = 0.0
        
        // Calculate width of visible cells because `contentSize` cannot be trusted for an accurate reading. The content size is invalid or not set when the collection view is first initialized and when a size class transition initially occur.
        let startIndex = 0
        let endIndex = collectionView.numberOfItemsInSection(section) - 1
        for indexRow in startIndex...endIndex {
            let indexPath = NSIndexPath(forRow: indexRow, inSection: section)
            
            let size =  self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath)
            contentSizeWidth += size.width
            contentSizeWidth += collectionViewLayout.minimumInteritemSpacing
            
            if contentSizeWidth > collectionViewWidth { break }
        }
    
        let defaultInset = SingleRowTextMenuFlowLayout.defaultInset
        if contentSizeWidth >= collectionViewWidth { return UIEdgeInsets(top: 0, left: defaultInset, bottom: 0, right: defaultInset) }
        
        let excessMargin = collectionViewWidth - contentSizeWidth
        let margin = max(defaultInset, excessMargin/2.0)

        return UIEdgeInsets(top: 0.0, left: margin, bottom: 0.0, right: margin)
    }
}

// MARK: - Delegate Protocol

protocol MetricsCoordinatorDelegate: class {
    
    func metricChildViewController(viewController: MetricChildViewController, didAppearAnimated animated: Bool, toIndexPath: NSIndexPath, fromIndexPath: NSIndexPath?)
    
    func metricsTypeCollectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath, previouslyAtIndexPath previousIndexPath: NSIndexPath?)
    
    func metricsPageViewController(pageController: UIPageViewController, didTransitionToViewControllerAtIndexPath toIndexPath: NSIndexPath, fromViewControllerAtIndexPath fromIndexPath: NSIndexPath)
}
