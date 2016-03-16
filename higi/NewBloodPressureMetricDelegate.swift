//
//  NewBloodPressureMetricDelegate.swift
//  higi
//
//  Created by Remy Panicker on 1/24/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class NewBloodPressureMetricDelegate: NSObject, NewMetricDelegate {

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
    
    private(set) var data: BloodPressureMetricGraphPoints
    
    private lazy var diastolicPlotHandler: NewMetricPlotDelegate = {
        let handler = NewMetricPlotDelegate()
        handler.points = self.data.diastolicPoints
        handler.metricDelegate = self
        return handler
    }()
    
    private lazy var systolicPlotHandler: NewMetricPlotDelegate = {
        let handler = NewMetricPlotDelegate()
        handler.points = self.data.systolicPoints
        handler.metricDelegate = self
        return handler
    }()
    
    func updateData(data: BloodPressureMetricGraphPoints) {
        self.data = data
        self.systolicPlotHandler.points = data.systolicPoints
        self.diastolicPlotHandler.points = data.diastolicPoints
    }
    
    lazy var tableDelegate: UITableViewDelegate? = {
        let delegate = NewMetricTableDelegate()
        delegate.metricDelegate = self
        return delegate
    }()
    
    init(data: BloodPressureMetricGraphPoints) {
        self.data = data
        super.init()
    }
    
    func hasData() -> Bool {
        return !data.diastolicPoints.isEmpty && !data.systolicPoints.isEmpty
    }
    
    var metricColor = Theme.Color.BloodPressure.primary
    
    func graph(frame: CGRect) -> CPTXYGraph {
        let plotSymbolSize = 8.0
        let selectedPlotSymbolSize = 10.0        
        let hitMargin = 20.0
        
        let color = Theme.Color.Metrics.Plot.line
        let altColor = Theme.Color.BloodPressure.secondary
        
        let graph = CPTXYGraph(frame: frame, padding: 0.0, plotAreaFramePadding: 20.0)
        
        let symbolLineStyle = CPTMutableLineStyle(color: color, lineWidth: 2.0)
        let altSymbolLineStyle = CPTMutableLineStyle(color: altColor, lineWidth: 2.0)
        
        let plotSymbol = CPTPlotSymbol.plotSymbol(CPTPlotSymbolTypeEllipse, fillColor: UIColor.whiteColor(), lineStyle: symbolLineStyle, size: plotSymbolSize)
        let selectedPlotSymbol = CPTPlotSymbol.plotSymbol(CPTPlotSymbolTypeEllipse, fillColor: color, lineStyle: symbolLineStyle, size: selectedPlotSymbolSize)
        
        let altSymbol = CPTPlotSymbol.plotSymbol(CPTPlotSymbolTypeEllipse, fillColor: UIColor.whiteColor(), lineStyle: altSymbolLineStyle, size: plotSymbolSize)
        let selectedAltSymbol = CPTPlotSymbol.plotSymbol(CPTPlotSymbolTypeEllipse, fillColor: altColor, lineStyle: altSymbolLineStyle, size: selectedPlotSymbolSize)
        
        self.plotSymbol = plotSymbol
        self.selectedPlotSymbol = selectedPlotSymbol
        self.unselectedAltPlotSymbol = altSymbol
        self.selectedAltPlotSymbol = selectedAltSymbol
        
        let points = self.data.systolicPoints
        let altPoints = self.data.diastolicPoints
        
        let maxY = GraphPoint.maxY([points, altPoints])
        let minY = GraphPoint.minY([points, altPoints])
        
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.configure(points, maxY: maxY, minY: minY, delegate: systolicPlotHandler)
        
        let plot = HIGIScatterPlot(color: color, hitMargin: hitMargin, plotSymbol: plotSymbol, dataSource: systolicPlotHandler, delegate: systolicPlotHandler)
        plot.identifier = "systolicPlotIdentifier"
        
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
        let firstRange = CPTPlotRange(location_: plotSpace.yRange.locationDouble - 1, length: 2) as CPTPlotRange
        let exclusionRanges = [firstRange]
        // method directly modifies graph's y-axis
        let yAxisFromGraph = graph.axisSet.axisForCoordinate(CPTCoordinateY, atIndex: 0) as! CPTXYAxis
        yAxisFromGraph.configureAxisY(plotSpace.yRange, gridLinesRange: plotSpace.xRange, labelExclusionRanges: exclusionRanges)
        
        let startingColor = CPTColor(componentRed: 58.0/255.0, green: 206.0/255.0, blue: 199.0/255.0, alpha: 0.2)
        let endingColor = CPTColor(componentRed: 58.0/255.0, green: 206.0/255.0, blue: 199.0/255.0, alpha: 0.05)
        let fillGradient = CPTGradient(beginningColor: startingColor, endingColor: endingColor)
        // rotate the gradient so that start color is at top of y-axis and end color is at bottom of y-axis
        fillGradient.angle = 270.0
        plot.areaBaseValue = CPTDecimalFromCGFloat(CGFloat(-60.0))
        plot.areaFill = CPTFill(gradient: fillGradient)
        
        graph.addPlot(plot, toPlotSpace: graph.defaultPlotSpace)
        self.selectedIndex = Int(0)
        
        
        if (altPoints.count > 1) {
            
            let altPlot = HIGIScatterPlot(secondaryPlotWithPoints: altPoints, color: altColor, hitMargin: hitMargin, dataSource: diastolicPlotHandler, delegate: diastolicPlotHandler)
            altPlot.identifier = "diastolicPlotIdentifier"
            
            //add alt plot here so that it's drawn behind main plot
            graph.addPlot(altPlot, toPlotSpace: graph.defaultPlotSpace)
            
            let startingColor = CPTColor(componentRed: 51.0/255.0, green: 155.0/255.0, blue: 148.0/255.0, alpha: 0.2)
            let endingColor = CPTColor(componentRed: 51.0/255.0, green: 155.0/255.0, blue: 148.0/255.0, alpha: 0.05)
            let fillGradient = CPTGradient(beginningColor: startingColor, endingColor: endingColor)
            // rotate the gradient so that start color is at top of y-axis and end color is at bottom of y-axis
            fillGradient.angle = 270.0
            altPlot.areaBaseValue = CPTDecimalFromCGFloat(CGFloat(-60.0))
            altPlot.areaFill = CPTFill(gradient: fillGradient)
        }
        
        return graph
    }
}

extension NewBloodPressureMetricDelegate {
    
    private enum BloodPressureReading {
        case Systolic
        case Diastolic
     
        enum BloodPressureCategory: String {
            // Raw values are here for backward compatibility :-\
            case Healthy = "Normal"
            case AtRisk = "At risk"
            case High
            
            static let allValues: [BloodPressureCategory] = [.Healthy, .AtRisk, .High]
            
            func name() -> String {
                var name: String!
                switch self {
                case .Healthy:
                    name = NSLocalizedString("BLOOD_PRESSURE_RANGE_NORMAL_TITLE", comment: "Title for blood pressure within a normal range.")
                case .AtRisk:
                    name = NSLocalizedString("BLOOD_PRESSURE_RANGE_AT_RISK_TITLE", comment: "Title for blood pressure within an at-risk range.")
                case .High:
                    name = NSLocalizedString("BLOOD_PRESSURE_RANGE_HIGH_TITLE", comment: "Title for blood pressure within a high range.")
                }
                return name
            }
            
            func color() -> UIColor {
                var color: UIColor!
                switch self {
                case .Healthy:
                    color = Theme.Color.BloodPressure.Category.healthy
                case .AtRisk:
                    color = Theme.Color.BloodPressure.Category.atRisk
                case .High:
                    color = Theme.Color.BloodPressure.Category.high
                }
                return color
            }
        }
        
        func range(category: BloodPressureCategory) -> (lowerBounds: Double, upperBounds: Double) {
            let range: (lowerBounds: Double, upperBounds: Double)
            switch self {
            case .Systolic:
                switch category {
                case .Healthy:
                    range = (90, 120)
                case .AtRisk:
                    range = (120, 140)
                case .High:
                    range = (140, 200)
                }
            case .Diastolic:
                switch category {
                case .Healthy:
                    range = (60, 80)
                case .AtRisk:
                    range = (80, 90)
                case .High:
                    range = (90, 120)
                }
            }
            return range
        }
        
        private func categories() -> [BloodPressureCategory] {
            return BloodPressureCategory.allValues
        }
        
        func ranges() -> [MetricGauge.Range] {
            var ranges: [MetricGauge.Range] = []
            for category in categories() {
                let name = category.name()
                let color = category.color()
                let interval = self.range(category)
                let range = MetricGauge.Range(label: name, color: color, interval: interval)
                ranges.append(range)
            }
            return ranges
        }
    }
}

// MARK: - Detail Preview

extension NewBloodPressureMetricDelegate: MetricDetailPreviewDelegate {
    
    func updateDetailPreview(detailPreview: MetricCheckinSummaryView) {
        if !self.hasData() { return }
        
        guard let checkins = SessionController.Instance.checkins else { return }
        
        let selectedPoint = data.systolicPoints[selectedIndex]
        let altSelectedPoint = data.diastolicPoints[selectedIndex]
        guard let checkinIdentifier = selectedPoint.identifier else { return }
        
        guard let checkin = checkins.filter({ $0.checkinId == checkinIdentifier }).first else { return }
        
        let formattedDateString = Constants.displayDateFormatter.stringFromDate(checkin.dateTime)
        
        let systolicValue = Int(selectedPoint.y)
        let diastolicValue = Int(altSelectedPoint.y)
        let unit = NSLocalizedString("GENERAL_PURPOSE_UNIT_LABEL_ABBR_MILLIMETERS_OF_MERCURY", comment: "General purpose abbreviated label for the units of millimeter of mercury.")
        detailPreview.configureDisplay(formattedDateString, primaryMetricValue: "\(systolicValue)/\(diastolicValue)", primaryMetricUnit: unit, secondaryMetricValue: nil, secondaryMetricUnit: nil, boldValueColor: self.metricColor)
    }
}


// MARK: - Detail Display

extension NewBloodPressureMetricDelegate: MetricDetailDisplayDelegate {
    
    func configure(viewController: MetricDetailViewController) {
        viewController.title = "Blood Pressure"

        viewController.navigationController?.hidesBarsWhenVerticallyCompact = false
        
        let checkins = SessionController.Instance.checkins
        
        let selectedPoint = data.systolicPoints[selectedIndex]
        let altSelectedPoint = data.diastolicPoints[selectedIndex]
        guard let checkinIdentifier = selectedPoint.identifier else { return }
        guard let checkin = checkins.filter({ $0.checkinId == checkinIdentifier }).first else { return }

        updateDetailPreview(viewController.headerView)
        
        // Add metric gauage and check location labels

        guard let bpCategoryString = checkin.bpClass as? String else { return }
        guard let bpCategory = BloodPressureReading.BloodPressureCategory(rawValue: bpCategoryString) else { return }
        let reading = BloodPressureReading.Diastolic
        let ranges = reading.ranges()
        let valueName = bpCategory.name()
        let valueColor = bpCategory.color()
        let unit = NSLocalizedString("GENERAL_PURPOSE_UNIT_LABEL_ABBR_MILLIMETERS_OF_MERCURY", comment: "General purpose abbreviated label for the units of millimeter of mercury.")
        
        viewController.configureGauge(altSelectedPoint.y, displayValue: "\(Int(selectedPoint.y))/\(Int(altSelectedPoint.y))", displayUnit: unit, ranges: ranges, valueName: valueName, valueColor: valueColor, checkin: checkin)

        viewController.configureInfoContainer(nil, imageNamed: "metric-info-blood-pressure-copy")
    }
}

// MARK: Table View

extension NewBloodPressureMetricDelegate: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TableSection.Count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.systolicPoints.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(MetricTableViewCell.cellReuseIdentifier, forIndexPath: indexPath) as! MetricTableViewCell
        
        let systolicPoint = self.data.systolicPoints[indexPath.row]
        let diastolicPoint = self.data.diastolicPoints[indexPath.row]
        
        let systolic = Int(systolicPoint.y)
        let diastolic = Int(diastolicPoint.y)
        
        let metricValue = "\(systolic)/\(diastolic)"
        let metricUnit = NSLocalizedString("GENERAL_PURPOSE_UNIT_LABEL_ABBR_MILLIMETERS_OF_MERCURY", comment: "General purpose abbreviated label for the units of millimeter of mercury.")
        
        let isSelected = (indexPath.row == self.selectedIndex)
        
        configureMetricTableViewCell(cell, indexPath: indexPath, selected: isSelected, timeInterval: diastolicPoint.x, primaryMetricValue: metricValue, primaryMetricUnit: metricUnit, secondaryMetricValue: nil, secondaryMetricUnit: nil)
        
        return cell
    }
}
