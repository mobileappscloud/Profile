import Foundation

class BaseGraphHostingView: CPTGraphHostingView, CPTScatterPlotDataSource, CPTPlotSpaceDelegate, CPTScatterPlotDelegate {
    
    var points: [GraphPoint];
    
    var plot: NewCPTScatterPlot!;
    
    var graph: CPTXYGraph!;
    
    var lastSelectedAltPlotIndex = -1, selectedPointIndex = -1;
    
    init(frame: CGRect, points: [GraphPoint]) {
        self.points = points;
        self.points.append(GraphPoint(x: Double(NSDate().timeIntervalSince1970), y: points.last!.y));
        super.init(frame: frame);
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupWithDefaults() {
        var maxY = 0.0, minY = DBL_MAX, plotSymbolSize = 7.0;
        let hitMargin = 5, pointsToShow = 30;
        
        graph = CPTXYGraph(frame: self.bounds);
        self.hostedGraph = graph;
        graph.paddingLeft = 0;
        graph.paddingTop = 0;
        graph.paddingRight = 0;
        graph.paddingBottom = 0;
        
        self.allowPinchScaling = true;
        graph.plotAreaFrame.paddingTop = 20;
        graph.plotAreaFrame.borderLineStyle = nil;
        
        var visiblePoints: [GraphPoint] = [];
        for point in points {
            if (point.y > maxY) {
                maxY = point.y;
            }
            if (point.y < minY) {
                minY = point.y;
            }
        }
//        for point in altPoints {
//            if (point.y > maxY) {
//                maxY = point.y;
//            }
//            if (point.y < minY) {
//                minY = point.y;
//            }
//        }
        
//        if (altPoints.count > 0) {
//            altPlot = NewCPTScatterPlot(frame: CGRectZero);
//            altPlot.interpolation = CPTScatterPlotInterpolationLinear;
//            altPlot.plotSymbolMarginForHitDetection = CGFloat(hitMargin);
//            altPlot.dataSource = self;
//            altPlot.delegate = self;
//            altPlot.setAreaBaseDecimalValue(0);
//            var noLineStyle = CPTMutableLineStyle();
//            noLineStyle.lineWidth = 0;
//            altPlot.dataLineStyle = noLineStyle;
//            //add alt plot here so that it's drawn behind main plot
//            graph.addPlot(altPlot, toPlotSpace: graph.defaultPlotSpace);
//        }
        var firstPoint, lastPoint: GraphPoint;
        if (visiblePoints.count > 0) {
            firstPoint = visiblePoints[0];
            lastPoint = visiblePoints[visiblePoints.count - 1];
        } else {
            firstPoint = GraphPoint(x: 0, y: 0);
            lastPoint = GraphPoint(x: 0, y: 0);
            minY = 0;
        }
        //        var tickInterval = roundToHighest(maxY - minY, roundTo: 10);
        var tickInterval = 20.0;
        let lowerBound = roundToLowest(round(minY) - (maxY - minY) * 0.25, roundTo: tickInterval);
        let yRange = roundToHighest((maxY - minY) * 1.5, roundTo: tickInterval);
        var xRange = lastPoint.x - firstPoint.x != 0 ? lastPoint.x - firstPoint.x : 1;
        var plotSpace = self.hostedGraph.defaultPlotSpace as! CPTXYPlotSpace;
        plotSpace.xRange = NewCPTPlotRange(location: firstPoint.x - xRange * 0.2, length: xRange * 1.3);
        plotSpace.yRange = NewCPTPlotRange(location: lowerBound, length: yRange);
        //        plotSpace.yRange = NewCPTPlotRange(location: round(minY) - (maxY - minY) * 0.25, length: (maxY - minY) * 1.5);
        plotSpace.globalXRange = plotSpace.xRange;
        plotSpace.globalYRange = plotSpace.yRange;
        plotSpace.delegate = self;
        
        plot = NewCPTScatterPlot(frame: CGRectZero);
        plot.interpolation = CPTScatterPlotInterpolationCurved;
        plot.setAreaBaseDecimalValue(0);
        plot.plotSymbolMarginForHitDetection = CGFloat(hitMargin);
        plot.dataSource = self;
        plot.delegate = self;
//        plot.plotSymbol = plotSymbol;
        var lineStyle = CPTMutableLineStyle();
        lineStyle.lineWidth = 1;
        plot.dataLineStyle = lineStyle;
        
        var axisTextStyle = CPTMutableTextStyle();
        axisTextStyle.color = CPTColor.grayColor();
        axisTextStyle.fontSize = 8;
        
        var xAxis = graph.axisSet.axisForCoordinate(CPTCoordinateX, atIndex: 0) as! CPTXYAxis;
        xAxis.labelTextStyle = axisTextStyle;
        xAxis.majorTickLineStyle = nil;
        xAxis.minorTickLineStyle = nil;
        xAxis.visibleRange = plotSpace.xRange;
        xAxis.axisConstraints = CPTConstraints(lowerOffset: 0);
        xAxis.labelingPolicy = CPTAxisLabelingPolicyEqualDivisions;
        xAxis.preferredNumberOfMajorTicks = 10;
        xAxis.axisLineStyle = lineStyle;
        xAxis.labelOffset = 0;
        xAxis.tickDirection = CPTSignPositive;
        var dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "MMM dd";
        xAxis.labelFormatter = CustomFormatter(dateFormatter: dateFormatter);
        
        var yAxis = graph.axisSet.axisForCoordinate(CPTCoordinateY, atIndex: 0) as! CPTXYAxis;
        yAxis.axisLineStyle = lineStyle;
        yAxis.labelTextStyle = axisTextStyle;
        yAxis.labelOffset = CGFloat(20);
        yAxis.majorTickLineStyle = nil;
        yAxis.minorTickLineStyle = nil;
        yAxis.visibleRange = plotSpace.yRange;
        yAxis.gridLinesRange = plotSpace.xRange;
        yAxis.axisConstraints = CPTConstraints(lowerOffset: 0);
        yAxis.labelingPolicy = CPTAxisLabelingPolicyEqualDivisions;
        let numberFormatter = NSNumberFormatter();
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle;
        numberFormatter.maximumFractionDigits = 0;
        yAxis.labelFormatter = numberFormatter;
        yAxis.tickDirection = CPTSignPositive;
        yAxis.labelOffset = 0;
        
        //        yAxis.preferredNumberOfMajorTicks = UInt(Int((yRange) / tickInterval)) + 1;
        yAxis.preferredNumberOfMajorTicks = 5;
        graph.addPlot(plot, toPlotSpace: graph.defaultPlotSpace);
        
        checkinSelected(plot, idx: points.count - 1, first: true);
    }
    
    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt {
        return UInt(points.count);
    }
    
    func numberForPlot(plot: CPTPlot?, field fieldEnum: UInt, recordIndex idx: UInt) -> NSNumber {
        var point = points[Int(idx)];
        if (fieldEnum == 0) {
            return NSNumber(double: point.x);
        } else {
            return NSNumber(double: point.y);
        }
    }
    
    func checkinSelected(plot: CPTScatterPlot!, idx: Int, first: Bool) {
        if (plot.isEqual(self.plot)) {
            selectedPointIndex = idx;
        } else {
            selectedPointIndex = Int(idx / 2);
        }
//        if (!first) {
//            var viewController = self.superview!.superview!.superview as! MetricCard?;
//            viewController!.setSelected(selectedPointIndex);
//        }
//        if (altPoints.count > 0) {
//            altPlot.reloadData();
//        }
        self.plot.reloadData();
    }
    
    func roundToLowest(number: Double, roundTo: Double) -> Double {
        return Double(Int(number / roundTo) * Int(roundTo));
    }
    
    func roundToHighest(number: Double, roundTo: Double) -> Double {
        return roundTo * Double(Int(ceil(number / roundTo)));
    }

}