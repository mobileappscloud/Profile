//
//  NewBodyFatMetricDelegate.swift
//  higi
//
//  Created by Remy Panicker on 2/15/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

import Foundation

final class NewBodyFatMetricDelegate: NSObject, NewMetricDelegate {
    
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
        handler.points = self.data.fatWeightPoints
        handler.metricDelegate = self
        return handler
    }()
    
    lazy var tableDelegate: UITableViewDelegate? = {
        let delegate = NewMetricTableDelegate()
        delegate.metricDelegate = self
        return delegate
    }()
    
    private(set) var data: BodyFatMetricGraphPoints
    
    func updateData(data: BodyFatMetricGraphPoints) {
        self.data = data
        self.plotHandler.points = data.fatWeightPoints
    }
    
    init(data: BodyFatMetricGraphPoints) {
        self.data = data
        super.init()
    }
    
    func hasData() -> Bool {
        return !data.bodyFatPoints.isEmpty
    }
    
    var metricColor = Theme.Color.Weight.primary
    
    func graph(frame: CGRect) -> CPTXYGraph {
        let plotSymbolSize = 8.0
        let selectedPlotSymbolSize = 10.0
        let hitMargin = 20.0
        
        let color = Theme.Color.Metrics.Plot.line
        
        let graph = CPTXYGraph(frame: frame, padding: 0.0, plotAreaFramePadding: 20.0)
        
        let symbolLineStyle = CPTMutableLineStyle(color: color, lineWidth: 2.0)
        
        let plotSymbol = CPTPlotSymbol.plotSymbol(CPTPlotSymbolTypeEllipse, fillColor: UIColor.whiteColor(), lineStyle: symbolLineStyle, size: plotSymbolSize)
        let selectedPlotSymbol = CPTPlotSymbol.plotSymbol(CPTPlotSymbolTypeEllipse, fillColor: color, lineStyle: symbolLineStyle, size: selectedPlotSymbolSize)
        
        let selectedAltPlotSymbol = CPTPlotSymbol.plotSymbol(CPTPlotSymbolTypeDash, fillColor: color, lineStyle: symbolLineStyle, size: plotSymbolSize)
        let unselectedAltPlotSymbol = CPTPlotSymbol.plotSymbol(CPTPlotSymbolTypeDash, fillColor: color, lineStyle: symbolLineStyle, size: plotSymbolSize)
        
        let unselectedAltPlotLineStyle = CPTMutableLineStyle()
        unselectedAltPlotLineStyle.lineWidth = 1
        unselectedAltPlotSymbol.lineStyle = unselectedAltPlotLineStyle
        
        self.plotSymbol = plotSymbol
        self.selectedPlotSymbol = selectedPlotSymbol
        self.selectedAltPlotSymbol = selectedAltPlotSymbol
        self.unselectedAltPlotSymbol = unselectedAltPlotSymbol
        
        let points = self.data.fatWeightPoints
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

// MARK: - Metric Gauge

extension NewBodyFatMetricDelegate {
    
    private enum BodyFatCategory: String {
        case Healthy
        case Acceptable
        case AtRisk = "At risk"
        
        static let allValues = [Healthy, Acceptable, AtRisk]
        
        func range(biologicalSex: BiologicalSex) -> (lowerBounds: Double, upperBounds: Double) {
            let range: (lowerBounds: Double, upperBounds: Double)
            let isMale = biologicalSex == .Male
            switch self {
            case .Healthy:
                range = isMale ? (5, 18) : (10, 25)
            case .Acceptable:
                range = isMale ? (18, 25) : (25, 32)
            case .AtRisk:
                range = isMale ? (25, 40) : (32, 45)
            }
            return range
        }

        func name() -> String {
            let name: String
            switch self {
            case .Healthy:
                name = NSLocalizedString("WEIGHT_METRICS_WEIGHT_RANGE_HEALTHY_LABEL", comment: "Label for a weight which falls within a healthy range.")
            case .Acceptable:
                name = NSLocalizedString("WEIGHT_METRICS_WEIGHT_RANGE_ACCEPTABLE_LABEL", comment: "Label for a weight which falls within an acceptable range.")
            case .AtRisk:
                name = NSLocalizedString("WEIGHT_METRICS_WEIGHT_RANGE_AT_RISK_LABEL", comment: "Label for a weight which falls within an at-risk range.")
            }
            return name
        }
        
        func color() -> UIColor {
            let color: UIColor
            switch self {
            case .Healthy:
                color = Theme.Color.BodyFat.Category.healthy
            case .Acceptable:
                color = Theme.Color.BodyFat.Category.acceptable
            case .AtRisk:
                color = Theme.Color.BodyFat.Category.atRisk
            }
            return color
        }
        
        static func ranges(biologicalSex: BiologicalSex) -> [MetricGauge.Range] {
            var ranges: [MetricGauge.Range] = []
            for category in BodyFatCategory.allValues {
                let label = category.name()
                let color = category.color()
                let interval = category.range(biologicalSex)
                let range = MetricGauge.Range(label: label, color: color, interval: interval)
                ranges.append(range)
            }
            return ranges
        }
    }
}

// MARK: - Detail Preview

extension NewBodyFatMetricDelegate: MetricDetailPreviewDelegate {
    
    func updateDetailPreview(detailPreview: MetricCheckinSummaryView) {
        if !self.hasData() { return }
        
        guard let checkins = SessionController.Instance.checkins else { return }
        
        let selectedPoint = data.bodyFatPoints[selectedIndex]
        guard let checkinIdentifier = selectedPoint.identifier else { return }
        
        guard let checkin = checkins.filter({ $0.checkinId == checkinIdentifier }).first else { return }
        
        let formattedDateString = Utility.longStyleDateFormatter.stringFromDate(checkin.dateTime)
        
        let fatRatio = selectedPoint.y
        let fatRatioDisplay = String.localizedStringWithFormat("%.2f", fatRatio)
        
        let pointValueString = "\(fatRatioDisplay) %"
        let pointUnit = "body fat"
        
        let secondPoint = self.data.fatWeightPoints[selectedIndex]
        let secondaryValue = secondPoint.y
        let secondaryValueString = String.localizedStringWithFormat("%.2f", secondaryValue)
        let secondaryUnit = NSLocalizedString("GENERAL_PURPOSE_UNIT_LABEL_ABBR_WEIGHT_POUNDS", comment: "General purpose abbreviated label for the english units of weight measurement, pounds.")
        
        detailPreview.configureDisplay(formattedDateString, primaryMetricValue: secondaryValueString, primaryMetricUnit: secondaryUnit, secondaryMetricValue: pointValueString, secondaryMetricUnit: pointUnit, boldValueColor: self.metricColor)
    }
}


// MARK: - Detail Display

extension NewBodyFatMetricDelegate: MetricDetailDisplayDelegate {
    
    func configure(viewController: MetricDetailViewController) {
        viewController.title = "Body Fat"
        
        viewController.navigationController?.hidesBarsWhenVerticallyCompact = false
        
        let checkins = SessionController.Instance.checkins
        
        let selectedPoint = data.bodyFatPoints[selectedIndex]
        guard let checkinIdentifier = selectedPoint.identifier else { return }
        
        guard let checkin = checkins.filter({ $0.checkinId == checkinIdentifier }).first else { return }
        
        updateDetailPreview(viewController.headerView)
        
        
        // Add metric gauage and check location labels
        guard let fatRatio = checkin.fatRatio else { return }
        guard let bodyFatCategoryString = checkin.fatClass as? String else { return }
        guard let bodyFatCategory = BodyFatCategory(rawValue: bodyFatCategoryString) else { return }
        let biologicalSex = SessionData.Instance.user.biologicalSex
        let ranges = BodyFatCategory.ranges(biologicalSex)
        
        let fatRatioDisplay = String.localizedStringWithFormat("%.2f", fatRatio)
        viewController.configureGauge(fatRatio, displayValue: "\(fatRatioDisplay)", displayUnit: "% body fat", ranges: ranges, valueName: bodyFatCategory.name(), valueColor: bodyFatCategory.color(), checkin: checkin)

        
        
        viewController.configureInfoContainer(nil, imageNamed: "metric-info-body-fat-copy")
    }
}

// MARK: Table View

extension NewBodyFatMetricDelegate: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TableSection.Count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.bodyFatPoints.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(MetricTableViewCell.cellReuseIdentifier, forIndexPath: indexPath) as! MetricTableViewCell
        
        let point = self.data.bodyFatPoints[indexPath.row]
        
        let pointValue = point.y
        let pointValueString = "\(String.localizedStringWithFormat("%.2f", pointValue)) %"
        let pointUnit = "body fat"
        
        let isSelected = (indexPath.row == self.selectedIndex)
        
        let secondPoint = self.data.fatWeightPoints[indexPath.row]
        let secondaryValue = secondPoint.y
        let secondaryValueString = String.localizedStringWithFormat("%.2f", secondaryValue)
        let secondaryUnit = NSLocalizedString("GENERAL_PURPOSE_UNIT_LABEL_ABBR_WEIGHT_POUNDS", comment: "General purpose abbreviated label for the english units of weight measurement, pounds.")
        
        configureMetricTableViewCell(cell, indexPath: indexPath, selected: isSelected, timeInterval: point.x, primaryMetricValue: secondaryValueString, primaryMetricUnit: secondaryUnit, secondaryMetricValue: pointValueString, secondaryMetricUnit: pointUnit)
        
        return cell
    }
}
