//
//  NewActivityMetricDelegate.swift
//  higi
//
//  Created by Remy Panicker on 1/24/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class NewActivityMetricDelegate: NSObject, NewMetricDelegate {

    enum TableSection: Int {
        case Main
        case Count
    }
    
    var selectedIndex: Int = 0
    
    var plotSymbol: CPTPlotSymbol? = nil
    var selectedPlotSymbol: CPTPlotSymbol? = nil
    var selectedAltPlotSymbol: CPTPlotSymbol? = nil
    var unselectedAltPlotSymbol: CPTPlotSymbol? = nil
    
    var tableScrollDelegate: MetricTableScrollDelegate? = nil
    var plotForwardDelegate: MetricPlotForwardDelegate? = nil    
    
    private lazy var plotHandler: NewMetricPlotDelegate = {
        let handler = NewMetricPlotDelegate()
        handler.points = self.data.activityPoints
        handler.metricDelegate = self
        return handler
    }()
    
    lazy var tableDelegate: UITableViewDelegate? = {
        let delegate = NewMetricTableDelegate()
        delegate.metricDelegate = self
        return delegate
    }()
    
    private(set) var data: DailySummaryMetricGraphPoints
    
    func updateData(data: DailySummaryMetricGraphPoints) {
        self.data = data
        self.plotHandler.points = data.activityPoints
    }
    
    init(data: DailySummaryMetricGraphPoints) {
        self.data = data
        super.init()
    }
        
    func hasData() -> Bool {
        return !data.activityPoints.isEmpty
    }
    
    var metricColor = Theme.Color.Activity.primary
    
    func graph(frame: CGRect) -> CPTXYGraph {
        let plotSymbolSize = 8.0
        let selectedPlotSymbolSize = 10.0        
        let hitMargin = 20.0
        
        let color = Theme.Color.Metrics.Plot.line
        
        let graph = CPTXYGraph(frame: frame, padding: 0.0, plotAreaFramePadding: 20.0)
        
        let symbolLineStyle = CPTMutableLineStyle(color: color, lineWidth: 2.0)
        
        let plotSymbol = CPTPlotSymbol.plotSymbol(CPTPlotSymbolTypeEllipse, fillColor: UIColor.whiteColor(), lineStyle: symbolLineStyle, size: plotSymbolSize)
        let selectedPlotSymbol = CPTPlotSymbol.plotSymbol(CPTPlotSymbolTypeEllipse, fillColor: color, lineStyle: symbolLineStyle, size: selectedPlotSymbolSize)
        
        self.plotSymbol = plotSymbol
        self.selectedPlotSymbol = selectedPlotSymbol
        
        let points = self.data.activityPoints
        
        let maxY = GraphPoint.maxY([points])
        let minY = GraphPoint.minY([points])
        
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.configure(points, maxY: maxY, minY: minY, delegate: plotHandler)
        
        let plot = HIGIScatterPlot(color: color, hitMargin: hitMargin, plotSymbol: plotSymbol, dataSource: plotHandler, delegate: plotHandler)
        
        var firstPoint: GraphPoint
        var lastPoint: GraphPoint
        
        if (points.count > 0) {
            firstPoint = points[points.count - 1]
            lastPoint = points[0]
        } else {
            firstPoint = GraphPoint(x: 0, y: 0)
            lastPoint = GraphPoint(x: 0, y: 0)
        }
        let visibleRangeX = CPTPlotRange(location_: firstPoint.x, length: lastPoint.x - firstPoint.x)
        
        // method directly modifies graph's x-axis
        let axisFromGraph = graph.axisSet.axisForCoordinate(CPTCoordinateX, atIndex: 0) as! CPTXYAxis
        axisFromGraph.configureAxisX(visibleRangeX)
        
        // exclusion range to hide first tickmark
        //        let firstRange = CPTPlotRange(location_: lowerBound - 1, length: 2) as CPTPlotRange
        let firstRange = CPTPlotRange(location_: minY - 1, length: 2) as CPTPlotRange
        let exclusionRanges = [firstRange]
        // method directly modifies graph's y-axis
        let yAxisFromGraph = graph.axisSet.axisForCoordinate(CPTCoordinateY, atIndex: 0) as! CPTXYAxis
        yAxisFromGraph.configureAxisY(plotSpace.yRange, gridLinesRange: plotSpace.xRange, labelExclusionRanges: exclusionRanges)
        
        let startingColor = Theme.Color.Metrics.Plot.gradientStart()
        let endingColor = Theme.Color.Metrics.Plot.gradientEnd()
        let fillGradient = CPTGradient(beginningColor: startingColor, endingColor: endingColor)
        // rotate the gradient so that start color is at top of y-axis and end color is at bottom of y-axis
        fillGradient.angle = 270.0
        plot.areaBaseValue = CPTDecimalFromCGFloat(CGFloat(-300.0))
        plot.areaFill = CPTFill(gradient: fillGradient)
        
        graph.addPlot(plot, toPlotSpace: graph.defaultPlotSpace)
        self.selectedIndex = Int(0)
        
        return graph
    }
}

// MARK: - Detail Preview

extension NewActivityMetricDelegate {
    
    func activitySummary(forGraphPoint graphPoint: GraphPoint) -> HigiActivitySummary? {
        let activities = SessionController.Instance.activities
        guard let activityIdentifier = graphPoint.identifier else { return nil }
        guard let activitySummary = activities[activityIdentifier] else { return nil }
        return activitySummary
        
    }
    
    func activitySummary(forGraphPointAtIndex index: Int) -> HigiActivitySummary? {
        let graphPoint = data.activityPoints[index]
        return activitySummary(forGraphPoint: graphPoint)
    }
}

extension NewActivityMetricDelegate: MetricDetailPreviewDelegate {
    
    func updateDetailPreview(detailPreview: MetricCheckinSummaryView) {
        if !self.hasData() { return }
        
        let graphPoint = data.activityPoints[selectedIndex]
        guard let activitySummary = activitySummary(forGraphPoint: graphPoint) else { return }
        
        guard let dateString = graphPoint.identifier,
            let activityDate = Constants.dateFormatter.dateFromString(dateString) else { return }
        
        let formattedDateString = Constants.displayDateFormatter.stringFromDate(activityDate)
        
        detailPreview.configureDisplay(formattedDateString, primaryMetricValue: String(activitySummary.totalPoints), primaryMetricUnit: "Points", secondaryMetricValue: nil, secondaryMetricUnit: nil, boldValueColor: self.metricColor)
    }
}

// MARK: - Detail Display

extension NewActivityMetricDelegate: MetricDetailDisplayDelegate {
    
    func configure(viewController: MetricDetailViewController) {
        viewController.title = "Activity"

        viewController.navigationController?.hidesBarsWhenVerticallyCompact = false
        
        let activitiesDict = SessionController.Instance.activities
        
        let selectedPoint = data.activityPoints[selectedIndex]
        guard let activityIdentifier = selectedPoint.identifier else { return }
        
        guard let activityTuple = activitiesDict[activityIdentifier] else { return }
        
        updateDetailPreview(viewController.headerView)
        
        var activities = activityTuple.activities
        activities.sortInPlace(SummaryViewUtility.sortByPoints)
        
        viewController.configureMeter(activityTuple)
        viewController.configureGraphicContainerTapGesture({
            let dailySummary = DailySummaryViewController(nibName: "DailySummaryView", bundle: nil)
            let date = activities.first?.startTime ?? NSDate()
            dailySummary.dateString = Constants.dateFormatter.stringFromDate(date)
            dispatch_async(dispatch_get_main_queue(), {
                viewController.navigationController?.pushViewController(dailySummary, animated: true)
            })
        })
        
        var activityKeys: [String] = [];
        var activitiesByType:[String: (Int, [HigiActivity])] = [:]
 
        var activitiesByDevice: [String: Int] = [:];
        for activity in activities {
            let type = activity.type.getString();
            if let (total, activityList) = activitiesByType[type] {
                if let devicePoints = activitiesByDevice[String(activity.device.name)] {
                    var previousActivities = activityList;
                    previousActivities.append(activity);
                    var points = total;
                    var newDevicePoints = devicePoints;
                    if (activity.points > 0 && activity.errorDescription == nil) {
                        points += activity.points!;
                        newDevicePoints += activity.points!;
                    }
                    activitiesByType[type] = (points, previousActivities);
                    activitiesByDevice[String(activity.device.name)] = newDevicePoints;
                } else {
                    var previousActivities = activityList;
                    previousActivities.append(activity);
                    var points = total;
                    if (activity.points > 0 && activity.errorDescription == nil) {
                        points += activity.points!;
                    }
                    activitiesByType[type] = (points, previousActivities);
                    activitiesByDevice[String(activity.device.name)] = activity.points!;
                }
            } else {
                var points = 0;
                if (activity.points > 0 && activity.errorDescription == nil) {
                    points += activity.points!;
                }
                activitiesByType[type] = (points, [activity]);
                activityKeys.append(type);
                activitiesByDevice[String(activity.device.name)] = points;
            }
        }
        
        let startFrame = viewController.view.bounds
        let containerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: startFrame.width, height: startFrame.height))
        
        var previousSubview: UIView? = nil
        
        for key in activityKeys {
            let (total, activityList) = activitiesByType[key]!;
            let category = ActivityCategory.categoryFromString(key);
            let color = category.getColor();
            let categoryPoints = total
            
            let detailRow = ActivityDetailView(frame: startFrame)
            let unit = NSLocalizedString("GENERAL_PURPOSE_UNIT_LABEL_ABBR_POINTS", comment: "General purpose abbreviated label for points.")
            detailRow.configure(category.getString(), value: "\(categoryPoints)", unit: unit, emphasizeActivityAndValue: true, emphasisColor: color)
            
            containerView.addSubview(detailRow)
            detailRow.translatesAutoresizingMaskIntoConstraints = false
            containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[detailRow]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["detailRow" : detailRow]))
            if previousSubview == nil {
                containerView.addConstraint(NSLayoutConstraint(item: detailRow, attribute: .Top, relatedBy: .Equal, toItem: containerView, attribute: .Top, multiplier: 1.0, constant: 5.0))
            } else {
                containerView.addConstraint(NSLayoutConstraint(item: detailRow, attribute: .Top, relatedBy: .Equal, toItem: previousSubview, attribute: .Bottom, multiplier: 1.0, constant: 22.0))
            }
            containerView.setNeedsUpdateConstraints()
            
            previousSubview = detailRow
            
            var seenDevices: [String: Bool] = [:];
            for subActivity in activityList {
                let deviceName = String(subActivity.device.name);
                if (subActivity.points > 0 || (key != ActivityCategory.Health.getString() && subActivity.errorDescription == nil)) {
                    if seenDevices[deviceName] == nil {
                        
                        let activityPoints = subActivity.points
                        
                        let subActivityRow = ActivityDetailView(frame: startFrame)
                        let unit = NSLocalizedString("GENERAL_PURPOSE_UNIT_LABEL_ABBR_POINTS", comment: "General purpose abbreviated label for points.")
                        subActivityRow.configure(deviceName, value: "\(activityPoints)", unit: unit, emphasizeActivityAndValue: false, emphasisColor: color)
                        
                        containerView.addSubview(subActivityRow)
                        subActivityRow.translatesAutoresizingMaskIntoConstraints = false
                        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[subActivityRow]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subActivityRow" : subActivityRow]))
                        containerView.addConstraint(NSLayoutConstraint(item: subActivityRow, attribute: .Top, relatedBy: .Equal, toItem: previousSubview, attribute: .Bottom, multiplier: 1.0, constant: 20.0))
                        containerView.setNeedsUpdateConstraints()
                        
                        previousSubview = subActivityRow
    
                        seenDevices[deviceName] = true;
                    }
                }
            }
        }
        
        containerView.addConstraint(NSLayoutConstraint(item: containerView, attribute: .Bottom, relatedBy: .Equal, toItem: previousSubview, attribute: .Bottom, multiplier: 1.0, constant: 30.0))
        
        viewController.configureInfoContainer(containerView, imageNamed: "metric-info-activity-copy")
    }
}

// MARK: - Table View

extension NewActivityMetricDelegate: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TableSection.Count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.activityPoints.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(MetricTableViewCell.cellReuseIdentifier, forIndexPath: indexPath) as! MetricTableViewCell
        
        let point = self.data.activityPoints[indexPath.row]
        
        let pointValue = Int(point.y)
        let pointValueString = String(pointValue)
        let pointUnit = NSLocalizedString("GENERAL_PURPOSE_UNIT_LABEL_ABBR_POINTS", comment: "General purpose abbreviated label for points.")
        
        let isSelected = (indexPath.row == self.selectedIndex)
        
        configureMetricTableViewCell(cell, indexPath: indexPath, selected: isSelected, timeInterval: point.x, primaryMetricValue: pointValueString, primaryMetricUnit: pointUnit, secondaryMetricValue: nil, secondaryMetricUnit: nil)
        
        return cell
    }
}
