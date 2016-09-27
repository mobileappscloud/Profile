//
//  NewPulseMetricDelegate.swift
//  higi
//
//  Created by Remy Panicker on 1/24/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class NewPulseMetricDelegate: NSObject, NewMetricDelegate {

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
        handler.points = self.data.pulsePoints
        handler.metricDelegate = self
        return handler
    }()
    
    lazy var tableDelegate: UITableViewDelegate? = {
        let delegate = NewMetricTableDelegate()
        delegate.metricDelegate = self
        return delegate
    }()
    
    private(set) var data: PulseMetricGraphPoints
    
    func updateData(data: PulseMetricGraphPoints) {
        self.data = data
        self.plotHandler.points = data.pulsePoints
    }
    
    init(data: PulseMetricGraphPoints) {
        self.data = data
        super.init()
    }
    
    func hasData() -> Bool {
        return !data.pulsePoints.isEmpty
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
        
        let points = self.data.pulsePoints
        
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
        let xAxisFromGraph = graph.axisSet.axisForCoordinate(CPTCoordinateX, atIndex: 0) as! CPTXYAxis
        xAxisFromGraph.configureAxisX(visibleRangeX)
        
        // exclusion range to hide first tickmark
        let lowerBound = plotSpace.yRange.locationDouble
        let length = lowerBound < 0 ? abs(lowerBound) : 2
        let firstRange = CPTPlotRange(location_: lowerBound, length: length) as CPTPlotRange
        let exclusionRanges = [firstRange]
        // method directly modifies graph's y-axis
        let yAxis = graph.axisSet.axisForCoordinate(CPTCoordinateY, atIndex: 0) as! CPTXYAxis
        yAxis.configureAxisY(plotSpace.yRange, gridLinesRange: plotSpace.yRange, labelExclusionRanges: exclusionRanges)
        
        
        
//        
//        // Add limit band range overlays
//        let lowRange = CPTPlotRange(location_: 0.0, length: 60.0)
//        let lowLimitBand = CPTLimitBand(range: lowRange, fill: CPTFill(color: CPTColor.whiteColor()))
//        yAxis.addBackgroundLimitBand(lowLimitBand)
//        
//        let normalRange = CPTPlotRange(location_: 60.0, length: 100.0)
//        let reallyLightGray = UIColor(white: 0.95, alpha: 1.0)
//        let normalLimitBand = CPTLimitBand(range: normalRange, fill: CPTFill(color: CPTColor(CGColor: reallyLightGray.CGColor)))
//        yAxis.addBackgroundLimitBand(normalLimitBand)
//        
//        let highRange = CPTPlotRange(location_: 100.0, length: 120.0)
//        let highLimitBand = CPTLimitBand(range: highRange, fill: CPTFill(color: CPTColor.whiteColor()))
//        yAxis.addBackgroundLimitBand(highLimitBand)
        
        


//        let layer = CPTLayer(frame: graph.plotAreaFrame.frame)
//        graph.addSublayer(layer)
//        let layerAnnotation = CPTLayerAnnotation(anchorLayer: layer)
        
    
//        let layerAnnotation = CPTLayerAnnotation(anchorLayer: graph)
//        let textLayer = CPTTextLayer(text: "Normal")
////        let plotSpaceAnnotation = CPTPlotSpaceAnnotation(plotSpace: plotSpace, anchorPlotPoint: [lastPoint.x, 80.0])
//        layerAnnotation.contentLayer = textLayer
//        var point = graph.getScreenPoint(lastPoint.x, y: lastPoint.y)
//        print(point)
//        let screenSize = UIScreen.mainScreen().bounds.size
//        if point.x > screenSize.width {
//            point.x = screenSize.width - 70.0
//        }
//        if point.y > screenSize.height {
//            point.y = screenSize.height - 20.0
//        }
//        layerAnnotation.displacement = CGPoint(x: point.x, y: -point.y)
//        graph.addAnnotation(layerAnnotation)
        
        
        
        
        
        
        let data = self.data.pulsePoints
        if let first = data.last, let last = data.first {
            let firstValue = first.x
            let lastValue = last.x
            let length = lastValue - firstValue
            
            yAxis.gridLinesRange = CPTPlotRange(location_: firstValue - length, length: length * 3)
        }
        
        // Graph fill color
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

extension NewPulseMetricDelegate: MetricDetailPreviewDelegate {
    
    func updateDetailPreview(detailPreview: MetricCheckinSummaryView) {
        if !self.hasData() { return }
        
        let selectedPoint = data.pulsePoints[selectedIndex]
        guard let activity = activity(forGraphPoint: selectedPoint) else { return }
        
        let formattedDateString = NSDateFormatter.longStyleDateFormatter.stringFromDate(activity.dateUTC)
        
        let pulse = Int(selectedPoint.y)
        detailPreview.configureDisplay(formattedDateString, primaryMetricValue: "\(pulse)", primaryMetricUnit: "bpm", secondaryMetricValue: nil, secondaryMetricUnit: nil)
    }
}


// MARK: - Detail Display

extension NewPulseMetricDelegate: MetricDetailDisplayDelegate {
    
    func configure(viewController: MetricDetailViewController) {
        viewController.title = "Pulse"
        
        viewController.navigationController?.hidesBarsWhenVerticallyCompact = false
        
        let selectedPoint = data.pulsePoints[selectedIndex]
        guard let activity = activity(forGraphPoint: selectedPoint) else { return }
        
        updateDetailPreview(viewController.headerView)
        
        // Add metric gauage and check location labels
        
        guard let pulse = activity.metadata.pulse else { return }
        guard let pulseClass = activity.metadata.pulseClass else { return }
        let ranges = Activity.Metric.Pulse.Class.ranges()
        let valueName = pulseClass.name()
        let valueColor = pulseClass.color()
    
        viewController.configureGauge(Double(pulse), displayValue: "\(pulse)", displayUnit: "bpm", ranges: ranges, valueName: valueName, valueColor: valueColor, activity: activity)
        
        viewController.configureInfoContainer(nil, imageNamed: "metric-info-pulse-copy")
    }
}

// MARK: Table View

extension NewPulseMetricDelegate: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TableSection._count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.pulsePoints.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(MetricTableViewCell.cellReuseIdentifier, forIndexPath: indexPath) as! MetricTableViewCell
        
        let point = self.data.pulsePoints[indexPath.row]
        
        let pointValue = Int(point.y)
        let pointValueString = String(pointValue)
        let pointUnit = "bpm"
        
        let isSelected = (indexPath.row == self.selectedIndex)
        
        configureMetricTableViewCell(cell, indexPath: indexPath, selected: isSelected, timeInterval: point.x, primaryMetricValue: pointValueString, primaryMetricUnit: pointUnit, secondaryMetricValue: nil, secondaryMetricUnit: nil)
        
        return cell
    }
}
