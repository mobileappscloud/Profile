//
//  MetricChildViewController.swift
//  higi
//
//  Created by Remy Panicker on 12/3/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import UIKit

private struct Storyboard {
    static let name = "MetricsPage"
    
    struct Scene {
        static let blankStateIdentifier = "MetricBlankStateViewControllerStoryboardIdentifier"
    }
    
    struct Segue {
        static let embedPlotIdentifier = "EmbedMetricPlotSegueIdentifier"
        static let embedTableViewIdentifier = "EmbedMetricTableViewSegue"
        static let embedDetailPreviewIdentifier = "EmbedDetailPreviewViewIdentifierSegue"
    }
}

final class MetricChildViewController: UIViewController {
    
    private var metricPlotViewController: MetricPlotViewController!
    @IBOutlet private var plotViewBottomConstraint: NSLayoutConstraint!
    
    private var metricTableViewController: MetricTableViewController!
    
    private var metricDetailPreviewViewController: MetricDetailPreviewViewController!
    private var metricDetailPreviewViewTopLayoutConstraint: NSLayoutConstraint?
    
    private(set) var type: MetricsType?
    
    lazy private var blankStateViewController: MetricBlankStateViewController = {
        let storyboard = UIStoryboard(name: "MetricsPage", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier(Storyboard.Scene.blankStateIdentifier) as! MetricBlankStateViewController
        return viewController
    }()
    
    // MARK: 
    
    /// Metric delegate for the child viewcontroller
    var metricDelegate: NewMetricDelegate!
    
    var viewLifecycleResponder: MetricChildViewLifecycleResponder? = nil    
    
    // MARK: -
    
    func configure(type: MetricsType) {
        self.type = type
    }
    
    func reloadData() {
        if metricDelegate.hasData() {
            dismissBlankStateView()
            
            if let metricPlotViewController = self.metricPlotViewController {
                metricPlotViewController.graphHostingView.hostedGraph.reloadData()
            }
            if let metricTableViewController = self.metricTableViewController {
                metricTableViewController.tableView.reloadData()
            }
            if let metricDetailPreviewViewController = self.metricDetailPreviewViewController {
                metricDelegate.updateDetailPreview(metricDetailPreviewViewController.headerView)
            }
        } else {
            showBlankStateView()
        }
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.metricDetailPreviewViewTopLayoutConstraint = NSLayoutConstraint(item: self.metricDetailPreviewViewController.view, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        self.view.addConstraint(self.metricDetailPreviewViewTopLayoutConstraint!)
        updateDetailPreviewTopLayoutConstraintForSizeClass()
        
        configureInteractiveDetailPreviewView()
        
        self.metricDetailPreviewViewController.view.layer.borderWidth = 1.0
        self.metricDetailPreviewViewController.view.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        metricDelegate.updateDetailPreview(self.metricDetailPreviewViewController.headerView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let dataSource = metricPlotViewController.delegate where !dataSource.hasData() {
            showBlankStateView()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.viewLifecycleResponder?.metricChildViewController(self, didAppearAnimated: animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case Storyboard.Segue.embedPlotIdentifier:
            let metricPlotViewController = segue.destinationViewController as! MetricPlotViewController
            self.metricPlotViewController = metricPlotViewController
            self.configureGraphInteractivity()
            metricPlotViewController.delegate = self.metricDelegate
            self.metricDelegate.plotForwardDelegate = self
            
        case Storyboard.Segue.embedTableViewIdentifier:
            let metricTableViewController = segue.destinationViewController as! MetricTableViewController
            self.metricTableViewController = metricTableViewController
            metricTableViewController.tableDataSource = self.metricDelegate
            metricTableViewController.tableViewDelegate = self.metricDelegate.tableDelegate
            metricTableViewController.tableViewConfigurator = self.metricDelegate
            self.metricDelegate.tableScrollDelegate = self
            
        case Storyboard.Segue.embedDetailPreviewIdentifier:
            let metricDetailPreviewViewController = segue.destinationViewController as! MetricDetailPreviewViewController
            self.metricDetailPreviewViewController = metricDetailPreviewViewController
            
        default:
            break
        }
    }
}

// MARK: - Update Constraints

extension MetricChildViewController {
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        configureGraphInteractivity()
        
        updateDetailPreviewTopLayoutConstraintForSizeClass()
    }
    
    private func updateDetailPreviewTopLayoutConstraintForSizeClass() {
        guard let detailView = self.metricDetailPreviewViewController else { return }
        
        let headerHeight: CGFloat = (self.traitCollection.verticalSizeClass == .Compact) ? -detailView.headerViewHeightConstraint.constant : 0.0
        
        self.plotViewBottomConstraint?.constant = headerHeight
        self.metricDetailPreviewViewTopLayoutConstraint?.constant = headerHeight
    }
}

// MARK: - Detail Preview

extension MetricChildViewController {
    
    private func configureInteractiveDetailPreviewView() {
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(MetricChildViewController.didTapDetailPreview(_:)))
        
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = .Up
        swipe.addTarget(self, action: #selector(MetricChildViewController.didSwipeDetailPreview(_:)))
        
        self.metricDetailPreviewViewController.headerView.gestureRecognizers = [tap, swipe]
    }
    
    func didSwipeDetailPreview(swipeGestureRecognizer: UISwipeGestureRecognizer) {
        presentDetailView()
    }
    
    func didTapDetailPreview(tapGestureRecognizer: UITapGestureRecognizer) {
        presentDetailView()
    }
    
    private func presentDetailView() {
        let storyboard = UIStoryboard(name: "MetricDetail", bundle: nil)
        guard let detail = storyboard.instantiateInitialViewController() as? MetricDetailViewController else { return }
        
        let nav = UINavigationController(rootViewController: detail)
        let closeButton = UIBarButtonItem(image: UIImage(named: "close-button"), style: .Plain, target: self, action: #selector(MetricChildViewController.didTapDetailCloseButton))
        detail.navigationItem.rightBarButtonItem = closeButton
        self.navigationController?.presentViewController(nav, animated: true, completion: nil)
        
        // Awful workaround because viewcontroller's view and subviews are not instantiated yet, so this dummy call is made to ensure the properties we need are initialized prior to configuration
        let _ = detail.view
        
        self.metricDelegate.configure(detail)
    }
    
    func didTapDetailCloseButton() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - Blank State

extension MetricChildViewController {
    
    private func showBlankStateView() {
        var text: String? = nil
        switch self.type! {
        case .DailySummary:
            text = NSLocalizedString("ACTIVITY_METRICS_VIEW_BLANK_STATE_TEXT", comment: "Text to display if a user does not have any higi points.")
        case .BloodPressure:
            text = NSLocalizedString("BLOOD_PRESSURE_METRICS_VIEW_BLANK_STATE_TEXT", comment: "Text to display on blood pressure metrics view when there is no blood pressure data to display.")
        case .Pulse:
            text = NSLocalizedString("PULSE_METRICS_VIEW_BLANK_STATE_TEXT", comment: "Text to display on pulse metrics view if there is no pulse data to display.")
        case .Weight:
            text = NSLocalizedString("WEIGHT_METRICS_VIEW_BLANK_STATE_TEXT", comment: "Text to display on the weight metrics view if there are no weight readings to display.")
        case .BodyMassIndex:
            text = NSLocalizedString("BODY_MASS_INDEX_METRICS_VIEW_BLANK_STATE_TEXT", comment: "Text to display on the body mass index metrics view if there are no BMI readings to display.")
        case .BodyFat:
            text = NSLocalizedString("BODY_FAT_METRICS_VIEW_BLANK_STATE_TEXT", comment: "Text to display on the body fat metrics view if there are no body fat readings to display.")
        }
        
        self.blankStateViewController.configure(text,
            firstActionHandler: {
                self.navigateToStationFinder()
            },
            secondActionHandler: {
                self.navigateToConnectDevice()
        })
        
        self.view.addSubview(blankStateViewController.view, pinToEdges: true)
    }
    
    private func dismissBlankStateView() {
        self.blankStateViewController.view.removeFromSuperview()
    }
}

// MARK: - Helper

extension MetricChildViewController {
    
    private func navigateToStationFinder() {
        FindStationViewController.navigateToStationLocator(nil)
    }
    
    private func navigateToConnectDevice() {
        guard let mainTabBarController = Utility.mainTabBarController() else { return }
        
        let settingsNavController = mainTabBarController.settingsModalViewController() as! UINavigationController
        
        let connectDeviceViewController = ConnectDeviceViewController(nibName: "ConnectDeviceView", bundle: nil)
        dispatch_async(dispatch_get_main_queue(), {
            // Make sure there are no views presented over the tab bar controller
            mainTabBarController.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
            
            mainTabBarController.presentViewController(settingsNavController, animated: false, completion: nil)
            settingsNavController.pushViewController(connectDeviceViewController, animated: false)
        })
    }
}

// MARK: - Plot

extension MetricChildViewController {
    
    private func configureGraphInteractivity() {
        guard let viewController = self.metricPlotViewController,
            let graphHostingView = viewController.graphHostingView,
            let graph = graphHostingView.hostedGraph else { return }
        guard let allPlotSpaces = graph.allPlotSpaces() as? [CPTPlotSpace] else { return }
        
        var graphInteractionEnabled = false
        if self.traitCollection.verticalSizeClass == .Compact {
            graphInteractionEnabled = true
        }
        
        for plot in allPlotSpaces {
            plot.allowsUserInteraction = graphInteractionEnabled
        }
    }
}

// MARK: - Plot Protocol

protocol MetricPlotForwardDelegate {
    
    func graphHostingView(plot: CPTScatterPlot, selectedPointAtIndex index: Int)
}

extension MetricChildViewController: MetricPlotForwardDelegate {
    
    func graphHostingView(plot: CPTScatterPlot, selectedPointAtIndex index: Int) {
        metricDelegate.updateDetailPreview(self.metricDetailPreviewViewController.headerView)
        
        guard let tableView = self.metricTableViewController.tableView else { return }
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        tableView.beginUpdates()
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)
        tableView.reloadData()
        tableView.endUpdates()
    }
}

// MARK: - Table Coordinator

extension MetricChildViewController: MetricTableScrollDelegate {
    
    func tableViewDidScroll(tableView: UITableView, delegate: NewMetricDelegate) {
        metricDelegate.updateDetailPreview(self.metricDetailPreviewViewController.headerView)        
        
        guard let graphHostingView = self.metricPlotViewController.graphHostingView else { return }
        guard let plot = graphHostingView.hostedGraph.allPlots().first as? CPTPlot else { return }

        // reload plot so that we can update the 'selected' graph point
        for graphPlot in plot.graph!.allPlots() {
            graphPlot.reloadData()
        }
        
        // fetch visible cells
        let visibleCells = tableView.visibleCells
        let minimumCellCount = 3
        if visibleCells.count < minimumCellCount { return }
        guard let topCell = visibleCells.first, let lastCell = visibleCells.last else { return }
        
        // top cell is the middle point on graph
        // bottom cell is right-most visible point on graph
        guard let topVisibleTableCellIndexPath = tableView.indexPathForCell(topCell),
            let bottomVisibleTableCellIndexPath = tableView.indexPathForCell(lastCell) else {
            return
        }
    
        // Get data source -- this is also a dumb implementation
        var points: [GraphPoint] = []
        switch self.type! {
        case .DailySummary:
            points = (delegate as! NewActivityMetricDelegate).data.activityPoints
        case .BloodPressure:
            points = (delegate as! NewBloodPressureMetricDelegate).data.systolicPoints
        case .Pulse:
            points = (delegate as! NewPulseMetricDelegate).data.pulsePoints
        case .Weight:
            points = (delegate as! NewWeightMetricDelegate).data.weightPoints
        case .BodyMassIndex:
            points = (delegate as! NewBodyMassIndexMetricDelegate).data.bodyMassIndexPoints
        case .BodyFat:
            points = (delegate as! NewBodyFatMetricDelegate).data.bodyFatPoints
        }
        
        // calculate how many cells are visible
        // move {visible cell count} indices over to determine index for left-most point
        
        // this should always be a valid index since it is the index of the first visible table cell
        let middleIndex = topVisibleTableCellIndexPath.row
        // this should always be a valid index since it is the index of the last visible table cell
        let rightIndex = min(bottomVisibleTableCellIndexPath.row, points.count-1)
        let buffer = rightIndex - middleIndex
        // this could potentially be negative, so make sure we don't get a negative value (out of bounds)
        let leftIndex = max(0, middleIndex - buffer)
        
        
        // fetch right, middle, and left-most visible points on graph
        let firstPoint = points[rightIndex]
//        let midPoint = points[middleIndex]
        let lastPoint = points[leftIndex]
        
        var margin: Double = (lastPoint.x - firstPoint.x) * 0.1
        if (margin == 0) {
            margin = 2 * 86400 // x days
        }
        
//        let locationTimeInterval = firstPoint.x - margin
//        let lengthTimeInterval = (lastPoint.x - firstPoint.x) + margin * 2
//        let endRange = locationTimeInterval + lengthTimeInterval
        
        
        // update the visible range of plot points
        let xRange = CPTPlotRange(location_: firstPoint.x - margin * 2 , length: lastPoint.x - firstPoint.x + margin * 4)
        plot.plotSpace.setPlotRange(xRange, forCoordinate: CPTCoordinateX)
    }
}

extension MetricChildViewController: DailySummaryPresentationDelegate {
    
    func presentDailySummaryViewController(viewController: DailySummaryViewController) {
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(MetricChildViewController.dailySummaryDidTapDone(_:)))
        let nav = UINavigationController(rootViewController: viewController)
        self.navigationController?.presentViewController(nav, animated: true, completion: nil)
    }
    
    func dailySummaryDidTapDone(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - View Lifecycle Protocol

protocol MetricChildViewLifecycleResponder {
    
    func metricChildViewController(viewController: MetricChildViewController, didAppearAnimated animated: Bool)
}
