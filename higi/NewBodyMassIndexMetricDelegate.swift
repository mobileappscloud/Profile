//
//  NewBodyMassIndexMetricDelegate
//  higi
//
//  Created by Remy Panicker on 2/16/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class NewBodyMassIndexMetricDelegate: NSObject, NewMetricDelegate {
    
    enum TableSection: Int {
        case Main
        case _count
    }
    
    var activities: [Activity] = []
    
    var selectedIndex: Int = 0
    
    var plotSymbol: CPTPlotSymbol? = nil
    var selectedPlotSymbol: CPTPlotSymbol? = nil
    var selectedAltPlotSymbol: CPTPlotSymbol? = nil
    var unselectedAltPlotSymbol: CPTPlotSymbol? = nil
    
    var tableScrollDelegate: MetricTableScrollDelegate? = nil
    var plotForwardDelegate: MetricPlotForwardDelegate? = nil
    
    private lazy var plotHandler: NewMetricPlotDelegate = {
        let handler = NewMetricPlotDelegate()
        handler.points = self.data.bodyMassIndexPoints
        handler.metricDelegate = self
        return handler
    }()
    
    lazy var tableDelegate: UITableViewDelegate? = {
        let delegate = NewMetricTableDelegate()
        delegate.metricDelegate = self
        return delegate
    }()
    
    private(set) var data: BodyMassIndexGraphPoints
    
    func updateData(data: BodyMassIndexGraphPoints) {
        self.data = data
        self.plotHandler.points = data.bodyMassIndexPoints
    }
    
    init(data: BodyMassIndexGraphPoints) {
        self.data = data
        super.init()
    }
    
    func hasData() -> Bool {
        return !data.bodyMassIndexPoints.isEmpty
    }
    
    func graph(frame: CGRect) -> CPTXYGraph {
        let plotSymbolSize = 8.0
        let selectedPlotSymbolSize = 10.0
        let hitMargin = 20.0
        
        let color = Theme.Color.Metrics.Plot.line
        
        let graph = CPTXYGraph(frame: frame, padding: 0.0, plotAreaFramePadding: 0.0)
        
        let symbolLineStyle = CPTMutableLineStyle(color: color, lineWidth: 2.0)
        
        let plotSymbol = CPTPlotSymbol.plotSymbol(CPTPlotSymbolTypeEllipse, fillColor: UIColor.whiteColor(), lineStyle: symbolLineStyle, size: plotSymbolSize)
        let selectedPlotSymbol = CPTPlotSymbol.plotSymbol(CPTPlotSymbolTypeEllipse, fillColor: color, lineStyle: symbolLineStyle, size: selectedPlotSymbolSize)
        
        self.plotSymbol = plotSymbol
        self.selectedPlotSymbol = selectedPlotSymbol
        
        let points = self.data.bodyMassIndexPoints
        let altPoints: [GraphPoint] = []
        
        let maxY = GraphPoint.maxY([points, altPoints])
        let minY = GraphPoint.minY([points, altPoints])
        
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
        let lowerBound = plotSpace.yRange.locationDouble
        let length = lowerBound < 0 ? abs(lowerBound) : 2
        let firstRange = CPTPlotRange(location_: lowerBound, length: length) as CPTPlotRange
        let exclusionRanges = [firstRange]
        // method directly modifies graph's y-axis
        let yAxisFromGraph = graph.axisSet.axisForCoordinate(CPTCoordinateY, atIndex: 0) as! CPTXYAxis
        yAxisFromGraph.configureAxisY(plotSpace.yRange, gridLinesRange: plotSpace.xRange, labelExclusionRanges: exclusionRanges)
        
        let startingColor = Theme.Color.Metrics.Plot.gradientStart()
        let endingColor = Theme.Color.Metrics.Plot.gradientEnd()
        let fillGradient = CPTGradient(beginningColor: startingColor, endingColor: endingColor)
        // rotate the gradient so that start color is at top of y-axis and end color is at bottom of y-axis
        fillGradient.angle = 270.0
        plot.areaBaseValue = CPTDecimalFromCGFloat(CGFloat(-60.0))
        plot.areaFill = CPTFill(gradient: fillGradient)
        
        graph.addPlot(plot, toPlotSpace: graph.defaultPlotSpace)
        self.selectedIndex = Int(0)
        
        return graph
    }
    
}

// MARK: - Detail Preview

extension NewBodyMassIndexMetricDelegate: MetricDetailPreviewDelegate {
    
    func updateDetailPreview(detailPreview: MetricCheckinSummaryView) {
        if !self.hasData() { return }
        
        let selectedPoint = data.bodyMassIndexPoints[selectedIndex]
        guard let activity = activity(forGraphPoint: selectedPoint) else { return }
        
        let formattedDateString = NSDateFormatter.longStyleDateFormatter.stringFromDate(activity.dateUTC)
        
        let bmi = selectedPoint.y
        let bmiString = String.localizedStringWithFormat("%.2f", bmi)
        let unit = NSLocalizedString("METRICS_BODY_MASS_INDEX_UNIT_LABEL", comment: "Label for body mass index.")
        detailPreview.configureDisplay(formattedDateString, primaryMetricValue: bmiString, primaryMetricUnit: unit, secondaryMetricValue: nil, secondaryMetricUnit: nil)
    }
}


// MARK: - Detail Display

extension NewBodyMassIndexMetricDelegate: MetricDetailDisplayDelegate {
    
    func configure(viewController: MetricDetailViewController) {
        viewController.title = NSLocalizedString("METRIC_DETAIL_BODY_MASS_INDEX_TITLE", comment: "Title for metric detail view for body mass index.")
        
        viewController.navigationController?.hidesBarsWhenVerticallyCompact = false
        
        let selectedPoint = data.bodyMassIndexPoints[selectedIndex]
        guard let activity = activity(forGraphPoint: selectedPoint) else { return }
        
        updateDetailPreview(viewController.headerView)
        
        // Add metric gauage and check location labels
        guard let bodyMassIndex = activity.metadata.bodyMassIndex else { return }
        guard let bodyMassIndexClass = activity.metadata.bodyMassIndexClass else { return }
        let ranges = Activity.Metric.BodyMassIndex.Class.ranges()
        let displayUnit = NSLocalizedString("METRICS_BODY_MASS_INDEX_UNIT_LABEL", comment: "Label for body mass index.")
        
        let bmiString = String.localizedStringWithFormat("%.2f", bodyMassIndex)
        viewController.configureGauge(bodyMassIndex, displayValue: bmiString, displayUnit: displayUnit, ranges: ranges, valueName: bodyMassIndexClass.name(), valueColor: bodyMassIndexClass.color(), activity: activity)
        
        viewController.configureInfoContainer(nil, imageNamed: "metric-info-weight-copy")
    }
}

// MARK: Table View

extension NewBodyMassIndexMetricDelegate: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TableSection._count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.bodyMassIndexPoints.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(MetricTableViewCell.cellReuseIdentifier, forIndexPath: indexPath) as! MetricTableViewCell
        
        let point = self.data.bodyMassIndexPoints[indexPath.row]
        
        let pointValue = point.y
        let pointValueString = String.localizedStringWithFormat("%.2f", pointValue)
        let pointUnit = NSLocalizedString("METRICS_BODY_MASS_INDEX_UNIT_LABEL", comment: "Label for body mass index.")
        
        let isSelected = (indexPath.row == self.selectedIndex)
        
        configureMetricTableViewCell(cell, indexPath: indexPath, selected: isSelected, timeInterval: point.x, primaryMetricValue: pointValueString, primaryMetricUnit: pointUnit, secondaryMetricValue: nil, secondaryMetricUnit: nil)
        
        return cell
    }
}
