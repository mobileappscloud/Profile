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
    
    var metricColor = Theme.Color.BodyMassIndex.primary
    
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
        plot.areaBaseValue = CPTDecimalFromCGFloat(CGFloat(-60.0))
        plot.areaFill = CPTFill(gradient: fillGradient)
        
        graph.addPlot(plot, toPlotSpace: graph.defaultPlotSpace)
        self.selectedIndex = Int(0)
        
        return graph
    }
    
}

// MARK: - Metric Gauge

extension NewBodyMassIndexMetricDelegate {
    
    enum BodyMassIndexCategory: String {
        case Underweight
        case Normal
        case Overweight
        case Obese
        
        static let allValues: [BodyMassIndexCategory] = [.Underweight, .Normal, .Overweight, .Obese]
        
        /**
         Body Mass Index (BMI) range as classified by the Center for Disease Control and Prevention.
         [CDC Reference](http://www.cdc.gov/healthyweight/assessing/bmi/adult_bmi/)
         
         - returns: Body Mass Index range for a given weight category.
         */
        func range() -> (lowerBounds: Double, upperBounds: Double) {
            let range: (lowerBounds: Double, upperBounds: Double)!
            switch self {
            case .Underweight:
                range = (10.0, 18.5)
            case .Normal:
                range = (18.5, 25.0)
            case .Overweight:
                range = (25.0, 30.0)
            case .Obese:
                range = (30.0, 50.0)
            }
            return range
        }
        
        func name() -> String {
            let name: String
            switch self {
            case .Underweight:
                name = NSLocalizedString("WEIGHT_METRICS_WEIGHT_RANGE_UNDERWEIGHT_LABEL", comment: "Label for a weight which falls within an underweight range.")
            case .Normal:
                name = NSLocalizedString("WEIGHT_METRICS_WEIGHT_RANGE_NORMAL_LABEL", comment: "Label for a weight which falls within a normal range.")
            case .Overweight:
                name = NSLocalizedString("WEIGHT_METRICS_WEIGHT_RANGE_OVERWEIGHT_LABEL", comment: "Label for a weight which falls within an overweight range.")
            case .Obese:
                name = NSLocalizedString("WEIGHT_METRICS_WEIGHT_RANGE_OBESE_LABEL", comment: "Label for a weight which falls within an obese range.")
            }
            return name
        }
        
        func color() -> UIColor {
            let color: UIColor
            switch self {
            case .Underweight:
                color = Theme.Color.BodyMassIndex.Category.underweight
            case .Normal:
                color = Theme.Color.BodyMassIndex.Category.normal
            case .Overweight:
                color = Theme.Color.BodyMassIndex.Category.overweight
            case .Obese:
                color = Theme.Color.BodyMassIndex.Category.obese
            }
            return color
        }
        
        static func ranges() -> [MetricGauge.Range] {
            var ranges: [MetricGauge.Range] = []
            for category in BodyMassIndexCategory.allValues {
                let label = category.name()
                let color = category.color()
                let interval = category.range()
                let range = MetricGauge.Range(label: label, color: color, interval: interval)
                ranges.append(range)
            }
            return ranges
        }
    }
}

// MARK: - Detail Preview

extension NewBodyMassIndexMetricDelegate: MetricDetailPreviewDelegate {
    
    func updateDetailPreview(detailPreview: MetricCheckinSummaryView) {
        if !self.hasData() { return }
        
        guard let checkins = SessionController.Instance.checkins else { return }
        
        let selectedPoint = data.bodyMassIndexPoints[selectedIndex]
        guard let checkinIdentifier = selectedPoint.identifier else { return }
        
        guard let checkin = checkins.filter({ $0.checkinId == checkinIdentifier }).first else { return }
        
        let formattedDateString = Constants.displayDateFormatter.stringFromDate(checkin.dateTime)
        
        let bmi = selectedPoint.y
        let bmiString = String.localizedStringWithFormat("%.2f", bmi)
        detailPreview.configureDisplay(formattedDateString, primaryMetricValue: bmiString, primaryMetricUnit: "lb/in²", secondaryMetricValue: nil, secondaryMetricUnit: nil, boldValueColor: self.metricColor)
    }
}


// MARK: - Detail Display

extension NewBodyMassIndexMetricDelegate: MetricDetailDisplayDelegate {
    
    func configure(viewController: MetricDetailViewController) {
        viewController.title = "Body Mass Index"
        
        viewController.navigationController?.hidesBarsWhenVerticallyCompact = false
        
        let checkins = SessionController.Instance.checkins
        
        let selectedPoint = data.bodyMassIndexPoints[selectedIndex]
        guard let checkinIdentifier = selectedPoint.identifier else { return }
        
        guard let checkin = checkins.filter({ $0.checkinId == checkinIdentifier }).first else { return }
        
        updateDetailPreview(viewController.headerView)
        
        
        // Add metric gauage and check location labels
        guard let bodyMassIndex = checkin.bmi else { return }
        guard let weightCategoryString = checkin.bmiClass as? String else { return }
        guard let weightCategory = BodyMassIndexCategory(rawValue: weightCategoryString) else { return }
        let ranges = BodyMassIndexCategory.ranges()
        
        let bmiString = String.localizedStringWithFormat("%.2f", bodyMassIndex)
        viewController.configureGauge(bodyMassIndex, displayValue: bmiString, displayUnit: "lb/in²", ranges: ranges, valueName: weightCategory.name(), valueColor: weightCategory.color(), checkin: checkin)
        
        viewController.configureInfoContainer(nil, imageNamed: "metric-info-weight-copy")
    }
}

// MARK: Table View

extension NewBodyMassIndexMetricDelegate: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TableSection.Count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.bodyMassIndexPoints.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(MetricTableViewCell.cellReuseIdentifier, forIndexPath: indexPath) as! MetricTableViewCell
        
        let point = self.data.bodyMassIndexPoints[indexPath.row]
        
        let pointValue = point.y
        let pointValueString = String.localizedStringWithFormat("%.2f", pointValue)
        let pointUnit = "lb/in²"
        
        let isSelected = (indexPath.row == self.selectedIndex)
        
        configureMetricTableViewCell(cell, indexPath: indexPath, selected: isSelected, timeInterval: point.x, primaryMetricValue: pointValueString, primaryMetricUnit: pointUnit, secondaryMetricValue: nil, secondaryMetricUnit: nil)
        
        return cell
    }
}
