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
    private lazy var dataSet = MetricGraphPoints()
    
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
            case .watts:
                let activityDelegate = NewActivityMetricDelegate(data: self.dataSet.dailySummary)
                activityDelegate.dailySummaryPresentationDelegate = child
                delegate = activityDelegate
            case .bloodPressure:
                delegate = NewBloodPressureMetricDelegate(data: self.dataSet.bloodPressure)
            case .pulse:
                delegate = NewPulseMetricDelegate(data: self.dataSet.pulse)
            case .weight:
                delegate = NewWeightMetricDelegate(data: self.dataSet.weight)
            case .bodyMassIndex:
                delegate = NewBodyMassIndexMetricDelegate(data: self.dataSet.bodyMassIndex)
            case .bodyFat:
                delegate = NewBodyFatMetricDelegate(data: self.dataSet.bodyFat, user: self.userController.user)
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
    
    // MARK: Configurable Properties
    
    /// Supported types of metrics
    let types: [MetricsType]
    
    private var userController: UserController!
    
    weak var delegate: MetricsCoordinatorDelegate? = nil
    
    // MARK: Init
    
    required init(types: [MetricsType]) {
        self.types = types
    }
}

extension MetricsCoordinator {
    
    func configure(withUserController userController: UserController) {
        self.userController = userController
        
        self.fetchData()
    }
}

// MARK: - Data Retreival

extension MetricsCoordinator {
    
    func fetchData() {
        
        let user = userController.user
        let startDate = NSDate.distantPast()
        let endDate = NSDate()
        let sortDescending = true
        let pageSize = 0
        
        types.forEach({ type in
            
            let metricIds = activityMetricIds(forMetricsType: type)
            let includeWatts = type == .watts
            
            ActivityNetworkController.fetch(activitiesForUser: user, withMetrics: metricIds, startDate: startDate, endDate: endDate, includeWatts: includeWatts, sortDescending: sortDescending, pageSize: pageSize, success: { [weak self] (activities, paging) in
                
                guard let strongSelf = self else { return }
                // transform activities to graph points
                // place graph points within structs
                MetricDataFactory.updateGraphPoints(fromActivities: activities, forMetricsType: type, metricGraphPoints: &strongSelf.dataSet)
                strongSelf.refreshData(forMetricsType: type, withActivities: activities)
                
                }, failure: { (error) in
                    // TODO: Handle error
            })
        })
    }
    
    private func activityMetricIds(forMetricsType metricsType: MetricsType) -> [Activity.Metric.Identifier] {
        var metricIds: [Activity.Metric.Identifier] = []
        switch metricsType {
        case .watts:
            break
        case .bloodPressure:
            metricIds.append(.systolic)
            metricIds.append(.diastolic)
        case .pulse:
            metricIds.append(.pulse)
        case .weight:
            metricIds.append(.weight)
        case .bodyMassIndex:
            metricIds.append(.bodyMassIndex)
        case .bodyFat:
            metricIds.append(.fatRatio)
            metricIds.append(.fatMass)
        }
        return metricIds
    }
}

// MARK: - Data Refresh

extension MetricsCoordinator {
    
    private func refreshData(forMetricsType metricsType: MetricsType, withActivities activities: [Activity]) {
        guard let viewController = pageViewControllers.filter({ ($0 as? MetricChildViewController)?.type == metricsType }).first as? MetricChildViewController else { return }
        guard let metricDelegate = viewController.metricDelegate else { return }
        
        metricDelegate.activities = activities
        
        switch metricsType {
        case .watts:
            if let dailySummaryDelegate = metricDelegate as? NewActivityMetricDelegate {
                dailySummaryDelegate.updateData(self.dataSet.dailySummary)
            }
        case .bloodPressure:
            if let bloodPressureDelegate = metricDelegate as? NewBloodPressureMetricDelegate {
                bloodPressureDelegate.updateData(self.dataSet.bloodPressure)
            }
        case .pulse:
            if let pulseDelegate = metricDelegate as? NewPulseMetricDelegate {
                pulseDelegate.updateData(self.dataSet.pulse)
            }
        case .weight:
            if let weightDelegate = metricDelegate as? NewWeightMetricDelegate {
                weightDelegate.updateData(self.dataSet.weight)
            }
        case .bodyMassIndex:
            if let bmiDelegate = metricDelegate as? NewBodyMassIndexMetricDelegate {
                bmiDelegate.updateData(self.dataSet.bodyMassIndex)
            }
        case .bodyFat:
            if let bodyFatDelegate = metricDelegate as? NewBodyFatMetricDelegate {
                bodyFatDelegate.updateData(self.dataSet.bodyFat)
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            viewController.reloadData()
        })
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
