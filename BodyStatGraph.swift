import Foundation

class BodyStatGraph: CPTGraphHostingView, CPTScatterPlotDataSource, CPTPlotSpaceDelegate {
    
    var points: [GraphPoint], visiblePoints: [GraphPoint] = [];
    
    var altPoints: Array<Array<GraphPoint>> = Array<Array<GraphPoint>>();
    
    var altPlots: [Int:NewCPTScatterPlot] = [:];
    
    var systolicPoints: [GraphPoint] = [], diastolicPoints: [GraphPoint] = [];
    
    var plot: NewCPTScatterPlot = NewCPTScatterPlot(frame: CGRectZero);
    
    var selectedPointIndex = -1;
    
    var plotSymbol = CPTPlotSymbol.ellipsePlotSymbol(), selectedPlotSymbol = CPTPlotSymbol.ellipsePlotSymbol(), altPlotSymbol = CPTPlotSymbol.ellipsePlotSymbol(), selectedAltPlotSymbol = CPTPlotSymbol.ellipsePlotSymbol(), unselectedAltPlotSymbol = CPTPlotSymbol.ellipsePlotSymbol();
    
    var selectedAltPlotLineStyle = CPTMutableLineStyle(), unselectedAltPlotLineStyle = CPTMutableLineStyle();
    
    var lastSelectedAltPlotIndex = -1;
    
    let pointsToShow = 30;
    
    init(frame: CGRect, points: [GraphPoint]) {
        self.points = points;
        self.points.append(GraphPoint(x: Double(NSDate().timeIntervalSince1970), y: points.last!.y));
        super.init(frame: frame);
    }
    
    init(frame: CGRect, points: [GraphPoint], diastolicPoints: [GraphPoint], systolicPoints: [GraphPoint]) {
        self.points = points;
        self.diastolicPoints = diastolicPoints;
        self.systolicPoints = systolicPoints;
        super.init(frame: frame);
    }
    
    required init(coder aDecoder: NSCoder?) {
        fatalError("NSCoding not supported");
    }
    
    func setupForDashboard(type: BodyStatsType) {
        let color = Utility.colorFromBodyStatType(type);
        var graph = CPTXYGraph(frame: self.bounds);
        self.hostedGraph = graph;
        
        graph.paddingLeft = 0;
        graph.paddingTop = 0;
        graph.paddingRight = 0;
        graph.paddingBottom = 0;
        graph.plotAreaFrame.paddingBottom = 10;
        
        var maxY = 0.0;
        var minY = DBL_MAX;
        var maxX = 0.0;
        var minX = DBL_MAX;
        
        var index = 0;
        for point in points {
            if (point.y > maxY) {
                maxY = point.y;
            }
            if (point.y < minY) {
                minY = point.y;
            }
            if (point.x > maxX) {
                maxX = point.x;
            }
            if (point.x < minX) {
                minX = point.x;
            }
            if (points.count > pointsToShow) {
                if (index > points.count - 1 - pointsToShow) {
                    visiblePoints.append(point);
                }
            } else {
                visiblePoints.append(point);
            }
            index++;
        }
        
        var firstPoint, lastPoint: GraphPoint;
        
        if (visiblePoints.count > 0) {
            firstPoint = visiblePoints[0];
            lastPoint = visiblePoints[visiblePoints.count - 1];
        } else {
            firstPoint = GraphPoint(x: 0, y: 0);
            lastPoint = GraphPoint(x: 0, y: 0);
        }
        
        var yRange = maxY - minY;
        if (yRange == 0) {
            yRange++;
        }

        var xRange = maxX - minX;
        if (xRange == 0) {
            xRange++;
        }

        var plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace;
        plotSpace.xRange = NewCPTPlotRange(location: minX - xRange * 0.05, length: xRange * 1.05);
        plotSpace.yRange = NewCPTPlotRange(location: minY - yRange * 0.25, length: yRange * 1.5);
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
        lineStyle.lineColor = CPTColor(CGColor: color.CGColor);
        lineStyle.lineWidth = 2;
        
        plot.dataLineStyle = lineStyle;
        
        graph.addPlot(plot, toPlotSpace: graph.defaultPlotSpace);
        
        var axisLineStyle = CPTMutableLineStyle();
        axisLineStyle.lineColor = CPTColor(CGColor: UIColor.lightGrayColor().CGColor);
        axisLineStyle.lineWidth = 2;
        
        var xAxisLineStyle = CPTMutableLineStyle();
        xAxisLineStyle.lineColor = CPTColor(CGColor: UIColor.lightGrayColor().CGColor);
        xAxisLineStyle.lineWidth = 1;
        
        var xAxis = graph.axisSet.axisForCoordinate(CPTCoordinateX, atIndex: 0) as! CPTXYAxis;
        xAxis.visibleRange = plotSpace.xRange;
        xAxis.gridLinesRange = plotSpace.yRange;
        xAxis.axisConstraints = CPTConstraints(lowerOffset: 0);
        xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
        xAxis.tickDirection = CPTSignPositive;
        xAxis.axisLineStyle = xAxisLineStyle;
        
        var yAxis = graph.axisSet.axisForCoordinate(CPTCoordinateY, atIndex: 0) as! CPTXYAxis;
        yAxis.visibleRange = plotSpace.yRange;
        yAxis.gridLinesRange = plotSpace.xRange;
        yAxis.axisConstraints = CPTConstraints(lowerOffset: 0);
        yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
        yAxis.axisLineStyle = axisLineStyle;
        
//        setRange();
    }
    
    func setupForBodyStat(type: BodyStatsType) {
        let color = Utility.colorFromBodyStatType(type);
        var maxY = 0.0;
        var minY = DBL_MAX;
        
        var maxX = 0.0;
        var minX = DBL_MAX;
        let hitMargin = 5;
        
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
        
        unselectedAltPlotLineStyle.lineColor = CPTColor(CGColor: (color.colorWithAlphaComponent(0.3)).CGColor);
//        unselectedAltPlotLineStyle.lineColor = CPTColor(CGColor: UIColor.blackColor().CGColor);
        unselectedAltPlotLineStyle.lineWidth = 1;
        
        for index in 0..<points.count {
            var point = points[index];
            if (diastolicPoints.count > 0 && diastolicPoints.count > index) {
                var point2 = diastolicPoints[index];
                if (point2.y < minY) {
                    minY = point2.y;
                }
            } else {
                if (point.y < minY) {
                    minY = point.y;
                }
            }
            if (systolicPoints.count > 0 && systolicPoints.count > index) {
                var point2 = systolicPoints[index];
                if (point2.y > maxY) {
                    maxY = point2.y;
                }
            } else {
                if (point.y > maxY) {
                    maxY = point.y;
                }
            }
            
            if (point.x > maxX) {
                maxX = point.x;
            }
            if (point.x < minX) {
                minX = point.x;
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
                altPlot.name = "\(index)";
                graph.addPlot(altPlot, toPlotSpace: graph.defaultPlotSpace);
                
                altPoints.append([systolicPoints[index], diastolicPoints[index]]);
            }
            
            if (points.count > pointsToShow) {
                if (index > points.count - 1 - pointsToShow) {
                    visiblePoints.append(point);
                }
            } else {
                visiblePoints.append(point);
            }

        }
        
        var yRange = maxY - minY;
        
        var firstPoint, lastPoint: GraphPoint;
        
        if (visiblePoints.count > 0) {
            firstPoint = visiblePoints[0];
            lastPoint = visiblePoints[visiblePoints.count - 1];
        } else {
            firstPoint = GraphPoint(x: 0, y: 0);
            lastPoint = GraphPoint(x: 0, y: 0);
        }
        
        var plotSpace = self.hostedGraph.defaultPlotSpace as! CPTXYPlotSpace;
        plotSpace.allowsUserInteraction = true;
        
        var xRange = lastPoint.x - firstPoint.x;
        if (xRange == 0) {
            xRange++;
        }

        let lowerBound = roundToLowest(minY, roundTo: 20);
        let upperBound = roundToHighest(maxY, roundTo: 20);
        plotSpace.xRange = NewCPTPlotRange(location: firstPoint.x - xRange * 0.2, length: xRange * 1.3);
        if (type == BodyStatsType.BloodPressure) {
            plotSpace.yRange = NewCPTPlotRange(location: lowerBound, length: upperBound - lowerBound);
        } else if (type == BodyStatsType.Weight) {
            plotSpace.yRange = NewCPTPlotRange(location: minY - yRange * 0.4, length: yRange * 2.2);
        } else {
            plotSpace.yRange = NewCPTPlotRange(location: minY - yRange * 0.4, length: yRange * 2.2);
        }
        
        plotSpace.globalXRange = plotSpace.xRange;
        plotSpace.globalYRange = plotSpace.yRange;
        plotSpace.delegate = self;
        
        plot = NewCPTScatterPlot(frame: CGRectZero);
        plot.interpolation = CPTScatterPlotInterpolationCurved;
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
        gridLineStyle.lineColor = CPTColor(componentRed: 0, green: 0, blue: 0, alpha: 0.1);
        
        var xAxis = graph.axisSet.axisForCoordinate(CPTCoordinateX, atIndex: 0) as! CPTXYAxis;
        xAxis.labelTextStyle = axisTextStyle;
        xAxis.majorTickLineStyle = nil;
        xAxis.minorTickLineStyle = nil;
        xAxis.visibleRange = plotSpace.xRange;
        xAxis.gridLinesRange = plotSpace.yRange;
        xAxis.axisConstraints = CPTConstraints(lowerOffset: 0);
        xAxis.labelingPolicy = CPTAxisLabelingPolicyEqualDivisions;

        xAxis.preferredNumberOfMajorTicks = 10;
//        xAxis.majorGridLineStyle = gridLineStyle;
        xAxis.axisLineStyle = lineStyle;
        xAxis.labelOffset = 0;
        
        xAxis.tickDirection = CPTSignPositive;
        var dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "MMM dd";
        xAxis.labelFormatter = CustomFormatter(dateFormatter: dateFormatter);
        
        var yAxis = graph.axisSet.axisForCoordinate(CPTCoordinateY, atIndex: 0) as! CPTXYAxis;
        
        yAxis.majorGridLineStyle = gridLineStyle;
        yAxis.axisLineStyle = lineStyle;
        yAxis.labelTextStyle = axisTextStyle;
        yAxis.labelOffset = CGFloat(20);
        yAxis.majorTickLineStyle = nil;
        yAxis.minorTickLineStyle = nil;
        yAxis.visibleRange = plotSpace.yRange;
        yAxis.gridLinesRange = NewCPTPlotRange(location: firstPoint.x - xRange * 0.15, length: xRange * 1.3);
        yAxis.axisConstraints = CPTConstraints(lowerOffset: 0);
        if (type == BodyStatsType.BloodPressure) {
            yAxis.preferredNumberOfMajorTicks = UInt(Int((upperBound - lowerBound) / 20)) + 1;
        }
        yAxis.labelingPolicy = CPTAxisLabelingPolicyEqualDivisions;
        let numberFormatter = NSNumberFormatter();
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle;
        numberFormatter.maximumFractionDigits = 0;
        yAxis.labelFormatter = numberFormatter;
        yAxis.tickDirection = CPTSignPositive;
        yAxis.labelOffset = 0;
//        let padding = Double(UIScreen.mainScreen().bounds.size.width * 0.1);
//        plotSpace.xRange = NewCPTPlotRange(location: points[0].x - padding, length: points[points.count - 1].x - points[0].x + 1 + padding * 2);
//        plotSpace.yRange = NewCPTPlotRange(location: min - yRange * 0.25, length: yRange * 2.0);
//        
//        plotSpace.globalXRange = plotSpace.xRange;
//        plotSpace.globalYRange = plotSpace.yRange;
//
//        ((self.hostedGraph as! CPTXYGraph).axisSet.axisForCoordinate(CPTCoordinateX, atIndex: 0) as! CPTXYAxis).visibleRange = plotSpace.xRange;
//        ((self.hostedGraph as! CPTXYGraph).axisSet.axisForCoordinate(CPTCoordinateY, atIndex: 0) as! CPTXYAxis).visibleRange = plotSpace.yRange;
//        plotSpace.delegate = self;
//
//        //added after alt plots so that it is drawn on top
        graph.addPlot(plot, toPlotSpace: graph.defaultPlotSpace);
//
//        setRange();
        
        checkinSelected(plot, idx: points.count - 1, first: true);
    }

    func roundToLowest(number: Double, roundTo: Double) -> Double {
        return Double(Int(number / roundTo) * Int(roundTo));
    }
    
    func roundToHighest(number: Double, roundTo: Double) -> Double {
        return roundTo * Double(Int(round(number / roundTo)));
    }
    
    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt {
        if (plot.isEqual(self.plot)) {
            return UInt(points.count);
        } else {
            return 2;
        }
    }

    func numberForPlot(plot: CPTPlot!, field fieldEnum: UInt, recordIndex idx: UInt) -> NSNumber! {
        var point:GraphPoint;
        
        if (plot.isEqual(self.plot)) {
            point = points[Int(idx)];
            if (fieldEnum == 0) {
                return NSNumber(double: point.x);
            } else {
                return NSNumber(double: point.y);
            }
        } else {
            let altIndex = plot.name.toInt();
            if let altIndex = plot.name.toInt() {
                point = altPoints[altIndex][Int(idx)];
                if (fieldEnum == 0) {
                    return NSNumber(double: point.x);
                } else {
                    return NSNumber(double: point.y);
                }
            }
        }
        return nil;
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
        var plotSpace = self.hostedGraph.defaultPlotSpace as! CPTXYPlotSpace;
        var newRange: NewCPTPlotRange;

        let padding = Double(UIScreen.mainScreen().bounds.size.width * 0.1);
        
        newRange = NewCPTPlotRange(location: (padding + firstPoint.x), length: lastPoint.x - firstPoint.x + 1);

        plotSpace.xRange = newRange;
        
    }
    
    func scatterPlot(plot: CPTScatterPlot!, plotSymbolWasSelectedAtRecordIndex idx: Int) {
        checkinSelected(plot, idx: idx, first: false);
    }
    
    func checkinSelected(plot: CPTScatterPlot!, idx: Int, first: Bool) {
        if (!first) {
            var viewController = self.superview!.superview!.superview as! BodyStatCard?;
            viewController!.setSelected(idx);
        }
        if (plot.isEqual(self.plot)) {
            selectedPointIndex = idx;
        } else {
            selectedPointIndex = plot.name.toInt()!;
        }

        altPlots[selectedPointIndex]?.dataLineStyle = selectedAltPlotLineStyle;
        altPlots[selectedPointIndex]?.reloadData();
        altPlots[lastSelectedAltPlotIndex]?.dataLineStyle = unselectedAltPlotLineStyle;
        altPlots[lastSelectedAltPlotIndex]?.reloadData();
        lastSelectedAltPlotIndex = selectedPointIndex;

        self.plot.reloadData();
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

    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let index = Int(plot.dataIndexFromInteractionPoint(point));
        checkinSelected(plot as CPTScatterPlot!, idx: index - 1, first: false);
        return true;
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true;
    }
}
