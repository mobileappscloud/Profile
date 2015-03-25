import Foundation

class BodyStatGraph: CPTGraphHostingView, CPTScatterPlotDataSource, CPTPlotSpaceDelegate {
    
    var points: [GraphPoint];
    var altPoints: Array<Array<GraphPoint>> = Array<Array<GraphPoint>>();
    var altPlots: [Int:NewCPTScatterPlot] = [:];
    var systolicPoints: [GraphPoint] = [];
    var diastolicPoints: [GraphPoint] = [];
    var plot: NewCPTScatterPlot = NewCPTScatterPlot(frame: CGRectZero);
    var altPointsIndex = 0;
    var selectedPointIndex = -1;
    var selectedAltPointIndex = -1;
    var plotSymbol = CPTPlotSymbol.ellipsePlotSymbol();
    var selectedPlotSymbol = CPTPlotSymbol.ellipsePlotSymbol();
    var altPlotSymbol = CPTPlotSymbol.ellipsePlotSymbol();
    var selectedAltPlotSymbol = CPTPlotSymbol.ellipsePlotSymbol();
    var unselectedAltPlotSymbol = CPTPlotSymbol.ellipsePlotSymbol();
    var selectedAltPlotLineStyle = CPTMutableLineStyle();
    var unselectedAltPlotLineStyle = CPTMutableLineStyle();
    
    init(frame: CGRect, points: [GraphPoint]) {
        self.points = points;
        self.points.append(GraphPoint(x: Double(NSDate().timeIntervalSince1970), y: points.last!.y));
        super.init(frame: frame);
    }
    
    init(frame: CGRect, points: [GraphPoint], diastolicPoints: [GraphPoint], systolicPoints: [GraphPoint]) {
        self.points = points;
        self.diastolicPoints = diastolicPoints;
        self.systolicPoints = systolicPoints;
        //        self.points.append(GraphPoint(x: Double(NSDate().timeIntervalSince1970), y: points.last!.y));
        //        self.diastolicPoints.append(GraphPoint(x: Double(NSDate().timeIntervalSince1970), y: points.last!.y));
        //        self.systolicPoints.append(GraphPoint(x: Double(NSDate().timeIntervalSince1970), y: points.last!.y));

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

        plotSymbol.size = CGSize(width: 0, height: 0);
        
        plot.plotSymbol = plotSymbol;
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
        var hitMargin = 5;
        
        var graph = CPTXYGraph(frame: self.bounds);
        self.hostedGraph = graph;
        self.allowPinchScaling = true;
        
        graph.paddingLeft = 0;
        graph.paddingTop = 0;
        graph.paddingRight = 0;
        graph.paddingBottom = 0;
        graph.plotAreaFrame.paddingTop = 20;
        
        var symbolLineStyle = CPTMutableLineStyle();
        symbolLineStyle.lineColor = CPTColor(CGColor: color.CGColor);
        symbolLineStyle.lineWidth = 2;
        
        var unselectedLineStyle = CPTMutableLineStyle();
        unselectedLineStyle.lineColor = CPTColor(CGColor: (color.colorWithAlphaComponent(0.3)).CGColor);
        
        altPlotSymbol.fill = CPTFill(color: CPTColor(CGColor: color.CGColor));
        altPlotSymbol.lineStyle = symbolLineStyle;
        altPlotSymbol.size = CGSize(width: 7.0, height: 7.0);
        
        selectedAltPlotSymbol.fill = CPTFill(color: CPTColor(CGColor: color.CGColor));
        selectedAltPlotSymbol.lineStyle = symbolLineStyle;
        selectedAltPlotSymbol.size = CGSize(width: 7.0, height: 7.0);
        
        unselectedAltPlotSymbol.fill = CPTFill(color: CPTColor(CGColor: (color.colorWithAlphaComponent(0.3)).CGColor));
        unselectedAltPlotSymbol.lineStyle = unselectedLineStyle;
        unselectedAltPlotSymbol.size = CGSize(width: 7.0, height: 7.0);

        var lineStyle = CPTMutableLineStyle();
        lineStyle.lineColor = CPTColor(CGColor: color.CGColor);
        lineStyle.lineWidth = 1;
        selectedAltPlotLineStyle = lineStyle;
        
//        unselectedAltPlotLineStyle.lineColor = CPTColor(CGColor: (color.colorWithAlphaComponent(0.3)).CGColor);
        unselectedAltPlotLineStyle.lineColor = CPTColor(CGColor: UIColor.blackColor().CGColor);
        unselectedAltPlotLineStyle.lineWidth = 1;
        
        for index in 0..<points.count {
            var point = points[index];
            if (diastolicPoints.count > 0 && diastolicPoints.count > index) {
                var point2 = diastolicPoints[index];
                if (point2.y < min) {
                    min = point2.y;
                }
            } else {
                if (point.y < min) {
                    min = point.y;
                }
            }
            if (systolicPoints.count > 0 && systolicPoints.count > index) {
                var point2 = systolicPoints[index];
                if (point2.y > max) {
                    max = point2.y;
                }
            } else {
                if (point.y > max) {
                    max = point.y;
                }
            }
            
            if (diastolicPoints.count > 0 && diastolicPoints.count > index && systolicPoints.count > 0 && systolicPoints.count > index) {
                var altPlot = NewCPTScatterPlot(frame: CGRectZero);
                altPlot.interpolation = CPTScatterPlotInterpolationLinear;
                altPlot.plotSymbolMarginForHitDetection = CGFloat(hitMargin);
                altPlot.dataSource = self;
                altPlot.delegate = self;
                altPlot.setAreaBaseDecimalValue(0);
                altPlot.plotSymbol = altPlotSymbol;
                altPlot.dataLineStyle = lineStyle;
                
                altPlots[index] = altPlot;
                
                graph.addPlot(altPlot, toPlotSpace: graph.defaultPlotSpace);
                
                altPoints.append([systolicPoints[index], diastolicPoints[index]]);
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
        
        var plotSpace = self.hostedGraph.defaultPlotSpace as CPTXYPlotSpace;
        plotSpace.allowsUserInteraction = true;
        plotSpace.xRange = NewCPTPlotRange(location: firstPoint.x - 1, length: lastPoint.x - firstPoint.x + 2);
        plotSpace.yRange = NewCPTPlotRange(location: min - yRange * 0.4, length: yRange * 2.2);
        plotSpace.globalXRange = plotSpace.xRange;
        plotSpace.globalYRange = plotSpace.yRange;
        plotSpace.delegate = self;
        
        plot = NewCPTScatterPlot(frame: CGRectZero);
        plot.interpolation = CPTScatterPlotInterpolationLinear;
        plot.setAreaBaseDecimalValue(0);
        
        plot.plotSymbolMarginForHitDetection = CGFloat(hitMargin);
        plot.dataSource = self;
        plot.delegate = self;
        
        var noLineStyle = CPTMutableLineStyle();
        noLineStyle.lineWidth = 0;
        
        plotSymbol.fill = CPTFill(color: CPTColor.whiteColor());
        plotSymbol.lineStyle = symbolLineStyle;
        plotSymbol.size = CGSize(width: 7.0, height: 7.0);
        
        selectedPlotSymbol.fill = CPTFill(color: CPTColor(CGColor: color.CGColor));
        selectedPlotSymbol.lineStyle = symbolLineStyle;
        selectedPlotSymbol.size = CGSize(width: 7.0, height: 7.0);
        
        plot.plotSymbol = plotSymbol;
        plot.dataLineStyle = lineStyle;
        
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
        yAxis.paddingRight = 20;

        //added after alt plots so that it is drawn on top
        graph.addPlot(plot, toPlotSpace: graph.defaultPlotSpace);
        
        plotSpace.yRange = NewCPTPlotRange(location: min - yRange * 0.25, length: yRange * 2.0);
        plotSpace.globalYRange = plotSpace.yRange;
        
        ((self.hostedGraph as CPTXYGraph).axisSet.axisForCoordinate(CPTCoordinateY, atIndex: 0) as CPTXYAxis).visibleRange = plotSpace.yRange;
        plotSpace.delegate = self;

        setRange();
    }

    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt {
        if (plot.isEqual(self.plot)) {
            return UInt(points.count);
        } else {
            return 2;
        }
    }

    func numberForPlot(plot: CPTPlot!, field fieldEnum: Int, recordIndex idx: Int) -> NSNumber! {
        var point:GraphPoint;
        
        if (plot.isEqual(self.plot)) {
            point = points[idx];
        } else {
            point = altPoints[altPointsIndex][idx];
            if (idx == 1 && altPoints.count - 1 > altPointsIndex) {
                altPointsIndex++;
            }
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
        var viewController = Utility.getViewController(self) as BodyStatsViewController?;
        viewController!.setSelected(idx);
        
        if (plot.isEqual(self.plot)) {
            selectedPointIndex = idx;
        } else {
            selectedPointIndex = getPlotIndex(plot);
        }
        
        self.plot.reloadData();
        altPointsIndex = 0;
        for (index, altPlot) in altPlots {
            if (!plot.isEqual(altPlot) || index == selectedPointIndex) {
                altPlot.dataLineStyle = selectedAltPlotLineStyle;
            } else {
                altPlot.dataLineStyle = unselectedAltPlotLineStyle;
            }
            altPlot.reloadData();
        }
    }
    
    func symbolForScatterPlot(plot: CPTScatterPlot!, recordIndex idx: UInt) -> CPTPlotSymbol! {
        if (plot.isEqual(self.plot)) {
            return selectedPointIndex == Int(idx) ? selectedPlotSymbol : plotSymbol;
        } else {
            if (selectedPointIndex == -1) {
                return altPlotSymbol;
            } else if (plot.isEqual(altPlots[selectedPointIndex])) {
                return selectedAltPlotSymbol;
            } else {
                return unselectedAltPlotSymbol;
            }
        }
    }
    
    func getPlotIndex(plot: CPTScatterPlot) -> Int{
        for (index, altPlot) in altPlots {
            if (plot.isEqual(altPlot)) {
                return index;
            }
        }
        return -1;
    }
    
}
