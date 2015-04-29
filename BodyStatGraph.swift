import Foundation

class BodyStatGraph: CPTGraphHostingView, CPTScatterPlotDataSource, CPTPlotSpaceDelegate {
    
    var points: [GraphPoint], altPoints: [GraphPoint] = [], visiblePoints: [GraphPoint] = [];
    
    var systolicPoints: [GraphPoint] = [], diastolicPoints: [GraphPoint] = [];
    
    var plot: NewCPTScatterPlot = NewCPTScatterPlot(frame: CGRectZero), altPlot: NewCPTScatterPlot = NewCPTScatterPlot(frame: CGRectZero);
    
    var selectedPointIndex = 0;
    
    var plotSymbol = CPTPlotSymbol.ellipsePlotSymbol(), selectedPlotSymbol = CPTPlotSymbol.ellipsePlotSymbol(), altPlotSymbol = CPTPlotSymbol.ellipsePlotSymbol(), selectedAltPlotSymbol = CPTPlotSymbol.ellipsePlotSymbol(), unselectedAltPlotSymbol = CPTPlotSymbol.ellipsePlotSymbol();
    
    var selectedAltPlotLineStyle = CPTMutableLineStyle(), unselectedAltPlotLineStyle = CPTMutableLineStyle();
    
    var lastSelectedAltPlotIndex = -1;
    
    let pointsToShow = 30;
    
    var graph: CPTXYGraph!;
    
    let unselectedColor = Utility.colorFromHexString("#b4a6c2");
    
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
        graph = CPTXYGraph(frame: self.bounds);
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
    }
    
    func setupForBodyStat(type: BodyStatsType, isBodyFat: Bool) {
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
        unselectedLineStyle.lineColor = CPTColor(CGColor: unselectedColor.CGColor);
        
        altPlotSymbol.fill = CPTFill(color: CPTColor(CGColor: color.CGColor));
        altPlotSymbol.lineStyle = symbolLineStyle;
        altPlotSymbol.size = CGSize(width: 7.0, height: 7.0);
        
        selectedAltPlotSymbol.fill = CPTFill(color: CPTColor(CGColor: color.CGColor));
        selectedAltPlotSymbol.lineStyle = symbolLineStyle;
        selectedAltPlotSymbol.size = CGSize(width: 7.0, height: 7.0);
        
        unselectedAltPlotSymbol.fill = CPTFill(color: CPTColor(CGColor: unselectedColor.CGColor));
        unselectedAltPlotSymbol.lineStyle = unselectedLineStyle;
        unselectedAltPlotSymbol.size = CGSize(width: 7.0, height: 7.0);

        var lineStyle = CPTMutableLineStyle();
        lineStyle.lineColor = CPTColor(CGColor: color.CGColor);
        lineStyle.lineWidth = 1;
        selectedAltPlotLineStyle = lineStyle;
        
        var noLineStyle = CPTMutableLineStyle();
        noLineStyle.lineWidth = 0;
        
        unselectedAltPlotLineStyle.lineColor = CPTColor(CGColor: unselectedColor.CGColor);
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
                altPoints.append(systolicPoints[index]);
                altPoints.append(diastolicPoints[index]);
            }
            
            if (points.count > pointsToShow) {
                if (index > points.count - 1 - pointsToShow) {
                    visiblePoints.append(point);
                }
            } else {
                visiblePoints.append(point);
            }

        }
        altPlot = NewCPTScatterPlot(frame: CGRectZero);
        altPlot.interpolation = CPTScatterPlotInterpolationLinear;
        altPlot.plotSymbolMarginForHitDetection = CGFloat(hitMargin);
        altPlot.dataSource = self;
        altPlot.delegate = self;
        altPlot.setAreaBaseDecimalValue(0);
        altPlot.plotSymbol = altPlotSymbol;
        altPlot.dataLineStyle = noLineStyle;
        graph.addPlot(altPlot, toPlotSpace: graph.defaultPlotSpace);
        
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

        let lowerBound = isBodyFat ? 10 : roundToLowest(minY, roundTo: 20);
        let upperBound = isBodyFat ? 50 : roundToHighest(maxY, roundTo: 20);
        plotSpace.xRange = NewCPTPlotRange(location: firstPoint.x - xRange * 0.2, length: xRange * 1.3);
        plotSpace.yRange = NewCPTPlotRange(location: lowerBound, length: upperBound - lowerBound);
        
        plotSpace.globalXRange = plotSpace.xRange;
        plotSpace.globalYRange = plotSpace.yRange;
        plotSpace.delegate = self;
        
        plot = NewCPTScatterPlot(frame: CGRectZero);
        plot.interpolation = CPTScatterPlotInterpolationCurved;
        plot.setAreaBaseDecimalValue(0);
        
        plot.plotSymbolMarginForHitDetection = CGFloat(hitMargin);
        plot.dataSource = self;
        plot.delegate = self;
        
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
        yAxis.gridLinesRange = NewCPTPlotRange(location: firstPoint.x - xRange * 0.15, length: xRange * 1.3);
        yAxis.axisConstraints = CPTConstraints(lowerOffset: 0);
        if (type == BodyStatsType.Weight && isBodyFat) {
            yAxis.preferredNumberOfMajorTicks = UInt(Int((upperBound - lowerBound) / 10)) + 1;
        } else {
            yAxis.preferredNumberOfMajorTicks = UInt(Int((upperBound - lowerBound) / 20)) + 1;
        }
        yAxis.labelingPolicy = CPTAxisLabelingPolicyEqualDivisions;
        let numberFormatter = NSNumberFormatter();
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle;
        numberFormatter.maximumFractionDigits = 0;
        yAxis.labelFormatter = numberFormatter;
        yAxis.tickDirection = CPTSignPositive;
        yAxis.labelOffset = 0;

        if (isBodyFat) {
            let rangeTops = [50, 30, 25, 18];
            
            for index in 0...rangeTops.count - 1 {
                let top = rangeTops[index]
                let point = getScreenPoint(self, xPoint: CGFloat(points[0].x), yPoint: CGFloat(top));
                let width = UIScreen.mainScreen().bounds.size.width;
                let nextVal = index < rangeTops.count - 1 ? rangeTops[index + 1] : 0;
                let height = top - nextVal;
                
                let range = UIView(frame: CGRect(x: CGFloat(point.x), y: CGFloat(nextVal), width: CGFloat(width), height: CGFloat(height)));
                let a = range.frame;
                if (index % 2 == 1) {
                    range.backgroundColor = UIColor.lightGrayColor();
                }
                addSubview(range);
            }
        }
//        //added after alt plots so that it is drawn on top
        graph.addPlot(plot, toPlotSpace: graph.defaultPlotSpace);
        
        checkinSelected(plot, idx: points.count - 1, first: true);
    }

    func roundToLowest(number: Double, roundTo: Double) -> Double {
        return Double(Int(number / roundTo) * Int(roundTo));
    }
    
    func roundToHighest(number: Double, roundTo: Double) -> Double {
        let a = Int(ceil(number / roundTo));
        let b = Double(a);
        return roundTo * Double(Int(ceil(number / roundTo)));
    }
    
    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt {
        if (plot.isEqual(self.plot)) {
            return UInt(points.count);
        } else {
            return UInt(altPoints.count);
        }
    }

    func numberForPlot(plot: CPTPlot!, field fieldEnum: UInt, recordIndex idx: UInt) -> NSNumber! {
        var point:GraphPoint;
        
        if (plot.isEqual(self.plot)) {
            point = points[Int(idx)];
        } else {
            point = altPoints[Int(idx)];
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
        if (plot.isEqual(self.plot)) {
            selectedPointIndex = idx;
        } else {
            selectedPointIndex = Int(idx / 2);
        }

        if (!first) {
            var viewController = self.superview!.superview as! BodyStatCard?;
            viewController!.setSelected(selectedPointIndex);
        }
        
        altPlot.reloadData();
        self.plot.reloadData();
    }
    
    func getScreenPoint(graph: BodyStatGraph, xPoint: CGFloat, yPoint: CGFloat)-> CGPoint {
        var xRange = (graph.hostedGraph.defaultPlotSpace as! CPTXYPlotSpace).xRange;
        var yRange = (graph.hostedGraph.defaultPlotSpace as! CPTXYPlotSpace).yRange;
        var frame = graph.frame;
        let p = CGFloat(yRange.locationDouble);
        var x = ((xPoint - CGFloat(xRange.locationDouble)) / CGFloat(xRange.lengthDouble)) * frame.size.width;
        var y = (1.0 - ((yPoint - CGFloat(yRange.locationDouble)) / CGFloat(yRange.lengthDouble))) * (frame.size.height - 30);
        return CGPoint(x: x, y: y);
    }
    
    func symbolForScatterPlot(plot: CPTScatterPlot!, recordIndex idx: UInt) -> CPTPlotSymbol! {
        if (plot.isEqual(self.plot)) {
            return selectedPointIndex == Int(idx) ? selectedPlotSymbol : plotSymbol;
        } else {
            let point = altPoints[Int(idx)];
            let screenPoint = getScreenPoint(self, xPoint: CGFloat(point.x), yPoint: CGFloat(point.y));
            
            if (idx % 2 == 1) {
                
                
                if (Int(idx) == ((selectedPointIndex * 2) + 1)) {
                    return selectedAltPlotSymbol;
                }
            } else {
                let view = UIView(frame: CGRect(x: screenPoint.x - 0.5, y: screenPoint.y, width: 1, height: CGFloat(point.y - altPoints[Int(idx + 1)].y)));
                view.backgroundColor = unselectedColor;
                addSubview(view);
                
                if (Int(idx) == (selectedPointIndex * 2)) {
                    return selectedAltPlotSymbol;
                }
            }
            return unselectedAltPlotSymbol;
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
