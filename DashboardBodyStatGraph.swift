import Foundation

class DashboardBodyStatGraph: CPTGraphHostingView, CPTScatterPlotDataSource, CPTPlotSpaceDelegate {
    
    var points: [GraphPoint];
    var systolicPoints: [GraphPoint] = [];
    var diastolicPoints: [GraphPoint] = [];
    var plot: NewCPTScatterPlot;
    var diastolicPlot: NewCPTScatterPlot?;
    var systolicPlot: NewCPTScatterPlot?;
    
    init(frame: CGRect, points: [GraphPoint]) {
        self.points = points;
        self.points.append(GraphPoint(x: Double(NSDate().timeIntervalSince1970), y: points.last!.y));
        self.diastolicPoints = [];
        self.systolicPoints = [];
        self.plot = NewCPTScatterPlot(frame: CGRectZero);
        self.diastolicPlot = nil;
        self.systolicPlot = nil;
        super.init(frame: frame);
    }
    
    init(frame: CGRect, points: [GraphPoint], diastolicPoints: [GraphPoint], systolicPoints: [GraphPoint]) {
        self.points = points;
        self.diastolicPoints = diastolicPoints;
        self.systolicPoints = systolicPoints;
        self.diastolicPoints.append(GraphPoint(x: Double(NSDate().timeIntervalSince1970), y: points.last!.y));
        self.systolicPoints.append(GraphPoint(x: Double(NSDate().timeIntervalSince1970), y: points.last!.y));
        self.points.append(GraphPoint(x: Double(NSDate().timeIntervalSince1970), y: points.last!.y));
        self.plot = NewCPTScatterPlot(frame: CGRectZero);
        self.diastolicPlot = NewCPTScatterPlot(frame: CGRectZero);
        self.systolicPlot = NewCPTScatterPlot(frame: CGRectZero);
        
        super.init(frame: frame);
    }
    
    required init(coder aDecoder: NSCoder?) {
        fatalError("NSCoding not supported");
    }
    
    func setupForDashboard() {
        
        var graph = CPTXYGraph(frame: self.bounds);
        self.hostedGraph = graph;
        self.allowPinchScaling = false;
        
        graph.paddingLeft = 10;
        graph.paddingTop = 0;
        graph.paddingRight = 0;
        graph.paddingBottom = 0;
        graph.plotAreaFrame.paddingBottom = 10;
        
        var max = 0.0;
        var min = 9999999.9;
        
        for point in points {
            if (point.y > max) {
                max = point.y;
            }
            if (point.y < min) {
                min = point.y;
            }
        }
        
        var firstPoint, lastPoint: GraphPoint;
        
        if (points.count > 0) {
            firstPoint = points[0];
            lastPoint = points[points.count - 1];
        } else {
            firstPoint = GraphPoint(x: 0, y: 0);
            lastPoint = GraphPoint(x: 0, y: 0);
        }
        
        var yRange = max - min;
        if (yRange == 0) {
            yRange++;
        }
        
        var plotSpace = graph.defaultPlotSpace as CPTXYPlotSpace;
        plotSpace.allowsUserInteraction = true;
        plotSpace.xRange = NewCPTPlotRange(location: firstPoint.x - 1, length: lastPoint.x - firstPoint.x + 2);
        plotSpace.yRange = NewCPTPlotRange(location: min - yRange * 0.25, length: yRange * 1.5);
        plotSpace.globalXRange = plotSpace.xRange;
        plotSpace.globalYRange = plotSpace.yRange;
        plotSpace.delegate = self;
        
        plot = NewCPTScatterPlot(frame: CGRectZero);
        plot.interpolation = CPTScatterPlotInterpolationCurved;

        var hitMargin = 0;
        
        plot.plotSymbolMarginForHitDetection = CGFloat(hitMargin);
        plot.dataSource = self;
        plot.delegate = self;
        
        var lineStyle = CPTMutableLineStyle();
        lineStyle.lineColor = CPTColor.whiteColor();
        lineStyle.lineWidth = 1;
        
        plot.dataLineStyle = lineStyle;
        
        graph.addPlot(plot, toPlotSpace: graph.defaultPlotSpace);
        
        var xAxis = graph.axisSet.axisForCoordinate(CPTCoordinateX, atIndex: 0) as CPTXYAxis;
        xAxis.visibleRange = plotSpace.xRange;
        xAxis.gridLinesRange = plotSpace.yRange;
        xAxis.axisConstraints = CPTConstraints(lowerOffset: 0);
        xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
        xAxis.tickDirection = CPTSignPositive;
        xAxis.hidden = true;
        
        var yAxis = graph.axisSet.axisForCoordinate(CPTCoordinateY, atIndex: 0) as CPTXYAxis;
        yAxis.visibleRange = plotSpace.yRange;
        yAxis.gridLinesRange = plotSpace.xRange;
        yAxis.axisConstraints = CPTConstraints(lowerOffset: 0);
        yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
        yAxis.hidden = true;
        
        setRange();
    }
    
    func setupForBodyStat(color: UIColor) {
        var max = 0.0;
        var min = 9999999.9;
        
        for index in 0..<points.count {
            var point = points[index];
            if (diastolicPoints.count > 0) {
                var point2 = diastolicPoints[index];
                if (point2.y < min) {
                    min = point2.y;
                }
            } else {
                if (point.y < min) {
                    min = point.y;
                }
            }
            if (systolicPoints.count > 0) {
                var point2 = systolicPoints[index];
                if (point2.y > max) {
                    max = point2.y;
                }
            } else {
                if (point.y > max) {
                    max = point.y;
                }
            }
            
        }
        
        var yRange = max - min;
        
        var firstPoint, lastPoint: GraphPoint;
        
        if (points.count > 0) {
            firstPoint = points[0];
            lastPoint = points[points.count - 1];
        } else {
            firstPoint = GraphPoint(x: 0, y: 0);
            lastPoint = GraphPoint(x: 0, y: 0);
        }
        
        var graph = CPTXYGraph(frame: self.bounds);
        self.hostedGraph = graph;
        self.allowPinchScaling = true;
        
        graph.paddingLeft = 0;
        graph.paddingTop = 0;
        graph.paddingRight = 0;
        graph.paddingBottom = 0;
        graph.plotAreaFrame.paddingTop = 20;
        
        var plotSpace = self.hostedGraph.defaultPlotSpace as CPTXYPlotSpace;
        plotSpace.allowsUserInteraction = true;
        plotSpace.xRange = NewCPTPlotRange(location: firstPoint.x - 1, length: lastPoint.x - firstPoint.x + 2);
        plotSpace.yRange = NewCPTPlotRange(location: min - yRange * 0.4, length: yRange * 2.2);
        plotSpace.globalXRange = plotSpace.xRange;
        plotSpace.globalYRange = plotSpace.yRange;
        plotSpace.delegate = self;
        
        plot = NewCPTScatterPlot(frame: CGRectZero);
        plot.interpolation = CPTScatterPlotInterpolationLinear;
        plot.areaFill = CPTFill(color: CPTColor(componentRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.5));
        plot.setAreaBaseDecimalValue(0);
        
        var hitMargin = 5;
        
        plot.plotSymbolMarginForHitDetection = CGFloat(hitMargin);
        plot.dataSource = self;
        plot.delegate = self;
        
        var lineStyle = CPTMutableLineStyle();
        
        lineStyle.lineColor = CPTColor(CGColor: color.CGColor);
        lineStyle.lineWidth = 1;
        
        var noLineStyle = CPTMutableLineStyle();
        noLineStyle.lineWidth = 0;
        
        var symbolLineStyle = CPTMutableLineStyle();
        symbolLineStyle.lineColor = CPTColor(CGColor: color.CGColor);
        symbolLineStyle.lineWidth = 2;
        
        var plotSymbol = CPTPlotSymbol.ellipsePlotSymbol();
        plotSymbol.fill = CPTFill(color: CPTColor.whiteColor());
        plotSymbol.lineStyle = symbolLineStyle;
        plotSymbol.size = CGSize(width: 7.0, height: 7.0);
        plot.plotSymbol = plotSymbol;
        plot.dataLineStyle = lineStyle;
        
        graph.addPlot(plot, toPlotSpace: graph.defaultPlotSpace);
        graph.plotAreaFrame.borderLineStyle = nil;
        
        var axisTextStyle = CPTMutableTextStyle();
        axisTextStyle.color = CPTColor.grayColor();
        axisTextStyle.fontSize = 8;
        
        var gridLineStyle = CPTMutableLineStyle();
        gridLineStyle.lineColor = CPTColor(componentRed: 1, green: 1, blue: 1, alpha: 0.3);
        
        var xAxis = graph.axisSet.axisForCoordinate(CPTCoordinateX, atIndex: 0) as CPTXYAxis;
        xAxis.labelTextStyle = axisTextStyle;
        xAxis.majorTickLineStyle = nil;
        xAxis.minorTickLineStyle = nil;
        xAxis.visibleRange = plotSpace.xRange;
        xAxis.gridLinesRange = plotSpace.yRange;
        xAxis.axisConstraints = CPTConstraints(lowerOffset: 0);
        xAxis.labelingPolicy = CPTAxisLabelingPolicyEqualDivisions;

        xAxis.preferredNumberOfMajorTicks = 10;
        xAxis.majorGridLineStyle = gridLineStyle;
        xAxis.axisLineStyle = lineStyle;
        xAxis.labelOffset = 0;
        
        xAxis.tickDirection = CPTSignPositive;
        var dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "MMM dd";
        xAxis.labelFormatter = CustomFormatter(dateFormatter: dateFormatter);
        
        var yAxis = graph.axisSet.axisForCoordinate(CPTCoordinateY, atIndex: 0) as CPTXYAxis;
        
        yAxis.preferredNumberOfMajorTicks = 10;
        yAxis.majorGridLineStyle = gridLineStyle;
        yAxis.axisLineStyle = lineStyle;
        
        yAxis.labelTextStyle = axisTextStyle;
        yAxis.labelOffset = CGFloat(20);
        yAxis.majorTickLineStyle = nil;
        yAxis.minorTickLineStyle = nil;
        yAxis.visibleRange = plotSpace.yRange;
        yAxis.gridLinesRange = plotSpace.xRange;
        yAxis.axisConstraints = CPTConstraints(lowerOffset: 0);
        yAxis.labelingPolicy = CPTAxisLabelingPolicyEqualDivisions;
        
        yAxis.tickDirection = CPTSignPositive;
        yAxis.labelOffset = 0;
        
        var altPlotSymbol = CPTPlotSymbol.ellipsePlotSymbol();
        altPlotSymbol.fill = CPTFill(color: CPTColor(CGColor: color.CGColor));
        altPlotSymbol.lineStyle = symbolLineStyle;
        altPlotSymbol.size = CGSize(width: 7.0, height: 7.0);
        diastolicPlot!.plotSymbol = altPlotSymbol;

        diastolicPlot = NewCPTScatterPlot(frame: CGRectZero);
        diastolicPlot!.interpolation = CPTScatterPlotInterpolationLinear;
        diastolicPlot!.plotSymbolMarginForHitDetection = CGFloat(hitMargin);
        diastolicPlot!.dataSource = self;
        diastolicPlot!.delegate = self;
        diastolicPlot!.setAreaBaseDecimalValue(0);
        diastolicPlot!.plotSymbol = altPlotSymbol;
        diastolicPlot!.dataLineStyle = noLineStyle;
        
        systolicPlot = NewCPTScatterPlot(frame: CGRectZero);
        systolicPlot!.interpolation = CPTScatterPlotInterpolationLinear;
        systolicPlot!.setAreaBaseDecimalValue(0);
        systolicPlot!.plotSymbolMarginForHitDetection = CGFloat(hitMargin);
        systolicPlot!.dataSource = self;
        systolicPlot!.delegate = self;
        systolicPlot!.plotSymbol = altPlotSymbol;
        systolicPlot!.dataLineStyle = noLineStyle;

        graph.addPlot(diastolicPlot, toPlotSpace: graph.defaultPlotSpace);
        graph.addPlot(systolicPlot, toPlotSpace: graph.defaultPlotSpace);
        
        plotSpace.yRange = NewCPTPlotRange(location: min - yRange * 0.25, length: yRange * 2.0);
        plotSpace.globalYRange = plotSpace.yRange;
        
        ((self.hostedGraph as CPTXYGraph).axisSet.axisForCoordinate(CPTCoordinateY, atIndex: 0) as CPTXYAxis).visibleRange = plotSpace.yRange;
        plotSpace.delegate = self;

        setRange();
    }
    
    
    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt {
        if (plot.isEqual(self.plot)) {
            return UInt(points.count);
        } else if(plot.isEqual(self.diastolicPlot)) {
            return UInt(diastolicPoints.count);
        } else if (plot.isEqual(self.systolicPlot)) {
            return UInt(systolicPoints.count);
        } else {
            return 0;
        }
    }
    
    func numberForPlot(plot: CPTPlot!, field fieldEnum: Int, recordIndex idx: Int) -> NSNumber! {
        var point:GraphPoint;
        if (plot.isEqual(self.plot)) {
            point = points[idx];
        } else if(plot.isEqual(self.diastolicPlot)) {
            point = diastolicPoints[idx];
        } else if (plot.isEqual(self.systolicPlot)) {
            point = systolicPoints[idx];
        } else {
            return 0;
        }

        if (fieldEnum == 0) {
            return NSNumber(double: point.x);
        } else {
            return NSNumber(double: point.y);
        }
    }
    
    func setRange() {
        var firstPoint, lastPoint: GraphPoint;
        
        if (points.count > 0) {
            firstPoint = points[0];
            lastPoint = points[points.count - 1];
        } else {
            firstPoint = GraphPoint(x: 0, y: 0);
            lastPoint = GraphPoint(x: 0, y: 0);
        }
        var plotSpace = self.hostedGraph.defaultPlotSpace as CPTXYPlotSpace;
        var newRange: NewCPTPlotRange;

        newRange = NewCPTPlotRange(location: firstPoint.x, length: lastPoint.x - firstPoint.x + 1);

        plotSpace.xRange = newRange;
        
    }
    
    func scatterPlot(plot: CPTScatterPlot!, plotSymbolWasSelectedAtRecordIndex idx: Int) {
        (self.superview!.superview as GraphView).pointClicked(idx);
    }
    
}
