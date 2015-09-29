import Foundation

class MetricGraph: CPTGraphHostingView, CPTScatterPlotDelegate, CPTScatterPlotDataSource, CPTPlotSpaceDelegate {
    
    var points: [GraphPoint], altPoints: [GraphPoint] = [];
    
    var plot, altPlot: NewCPTScatterPlot!;
    
    var plotSymbol, selectedPlotSymbol, selectedAltPlotSymbol, unselectedAltPlotSymbol:CPTPlotSymbol!;
    
    var lastSelectedAltPlotIndex = -1, selectedPointIndex = -1;
    
    var graph: CPTXYGraph!;
    
    var shouldShowAltSymbol = false;
    
    init(frame: CGRect, points: [GraphPoint]) {
        self.points = points;
        super.init(frame: frame);
    }

    init(frame: CGRect, points: [GraphPoint], altPoints: [GraphPoint]) {
        self.points = points;
        self.altPoints = altPoints;
        super.init(frame: frame);
    }

    required init?(coder aDecoder: NSCoder?) {
        fatalError("NSCoding not supported");
    }
    
    func setup(frame: CGRect, points: [GraphPoint]) {
        self.points = points;
        self.frame = frame;
    }
    
    func setupForDashboard(type: MetricsType) {
        let color = type.getColor();
        var maxY = 0.0, minY = DBL_MAX, maxX = 0.0, minX = DBL_MAX;
        graph = CPTXYGraph(frame: self.bounds);
        self.hostedGraph = graph;
        graph.paddingLeft = 0;
        graph.paddingTop = 0;
        graph.paddingRight = 0;
        graph.paddingBottom = 0;
        graph.plotAreaFrame.paddingBottom = 10;
        if points.count > 0 {
            for point in points {
                if (point.y > maxY) {
                    maxY = point.y;
                }
                if (point.y < minY) {
                    minY = round(point.y);
                }
                if (point.x > maxX) {
                    maxX = point.x;
                }
                if (point.x < minX) {
                    minX = round(point.x);
                }
            }
        } else {
            minX = 0;
            minY = 0;
        }
        let yRange = maxY - minY > 1 ? maxY - minY : 1;
        let xRange = maxX - minX > 1 ? maxX - minX : 1;
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace;
        plotSpace.xRange = NewCPTPlotRange(location: max(round(minX) - xRange * 0.05, 0), length: xRange * 1.05);
        plotSpace.yRange = NewCPTPlotRange(location: round(minY) - yRange * 0.25, length: yRange * 1.5);
        plotSpace.globalXRange = plotSpace.xRange;
        plotSpace.globalYRange = plotSpace.yRange;
        plotSpace.delegate = self;
        
        plot = NewCPTScatterPlot(frame: CGRectZero);
        plot.interpolation = CPTScatterPlotInterpolationCurved;
        if (points.count > 1) {
            plotSymbol = CPTPlotSymbol.ellipsePlotSymbol();
            plotSymbol.size = CGSize(width: 0, height: 0);
        } else {
            let plotSymbolSize = 7.0;
            let symbolLineStyle = CPTMutableLineStyle();
            symbolLineStyle.lineColor = CPTColor(CGColor: color.CGColor);
            symbolLineStyle.lineWidth = 2;
            plotSymbol = CPTPlotSymbol.ellipsePlotSymbol();
            plotSymbol.fill = CPTFill(color: CPTColor(CGColor: color.CGColor));
            plotSymbol.lineStyle = symbolLineStyle;
            plotSymbol.size = CGSize(width: plotSymbolSize, height: plotSymbolSize);
        }
        plot.plotSymbol = plotSymbol;
        plot.plotSymbolMarginForHitDetection = CGFloat(0);
        plot.dataSource = self;
        plot.delegate = self;
        let lineStyle = CPTMutableLineStyle();
        lineStyle.lineColor = CPTColor(CGColor: color.CGColor);
        lineStyle.lineWidth = 2;
        plot.dataLineStyle = lineStyle;
        
        let xAxis = graph.axisSet.axisForCoordinate(CPTCoordinateX, atIndex: 0) as! CPTXYAxis;
        xAxis.visibleRange = plotSpace.xRange;
        xAxis.gridLinesRange = plotSpace.yRange;
        xAxis.axisConstraints = CPTConstraints(lowerOffset: 0);
        xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
        let xAxisLineStyle = CPTMutableLineStyle();
        xAxisLineStyle.lineColor = CPTColor(CGColor: UIColor.lightGrayColor().CGColor);
        xAxisLineStyle.lineWidth = 1;
        xAxis.axisLineStyle = xAxisLineStyle;
        
        let yAxis = graph.axisSet.axisForCoordinate(CPTCoordinateY, atIndex: 0) as! CPTXYAxis;
        yAxis.visibleRange = plotSpace.yRange;
        yAxis.gridLinesRange = plotSpace.xRange;
        yAxis.axisConstraints = CPTConstraints(lowerOffset: 0);
        yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
        let yAxisLineStyle = CPTMutableLineStyle();
        yAxisLineStyle.lineColor = CPTColor(CGColor: UIColor.lightGrayColor().CGColor);
        yAxisLineStyle.lineWidth = 2;
        yAxis.axisLineStyle = yAxisLineStyle;
        
        graph.addPlot(plot, toPlotSpace: graph.defaultPlotSpace);
    }
    
    func setupForMetric(color: UIColor, secondaryColor: UIColor?) {
        if (points.count == 0) {
            return;
        }
        var maxY = 0.0, minY = DBL_MAX, plotSymbolSize = 8.0;
        let hitMargin = 20, pointsToShow = 30;
        
        graph = CPTXYGraph(frame: self.bounds);
        self.hostedGraph = graph;
        graph.paddingLeft = 0;
        graph.paddingTop = 0;
        graph.paddingRight = 0;
        graph.paddingBottom = 0;
        self.allowPinchScaling = true;
        graph.plotAreaFrame.paddingTop = 20;
        graph.plotAreaFrame.paddingRight = 20;
        graph.plotAreaFrame.paddingLeft = 20;
        graph.plotAreaFrame.borderLineStyle = nil;
        graph.plotAreaFrame.borderWidth = 0;
        graph.borderWidth = 0;
        graph.borderLineStyle = nil;
        plotSymbol = CPTPlotSymbol.ellipsePlotSymbol();
        plotSymbol.fill = CPTFill(color: CPTColor.whiteColor());
        let symbolLineStyle = CPTMutableLineStyle();
        symbolLineStyle.lineColor = CPTColor(CGColor: color.CGColor);
        symbolLineStyle.lineWidth = 2;
        
        let altSymbolLineStyle = CPTMutableLineStyle();
        altSymbolLineStyle.lineColor = CPTColor(CGColor: color.CGColor);
        altSymbolLineStyle.lineWidth = 2;
        
        plotSymbol.lineStyle = symbolLineStyle;
        plotSymbol.size = CGSize(width: plotSymbolSize, height: plotSymbolSize);
        
        selectedPlotSymbol = CPTPlotSymbol.ellipsePlotSymbol();
        selectedPlotSymbol.fill = CPTFill(color: CPTColor(CGColor: color.CGColor));
        selectedPlotSymbol.lineStyle = symbolLineStyle;
        selectedPlotSymbol.size = CGSize(width: plotSymbolSize, height: plotSymbolSize);
        
        selectedAltPlotSymbol = CPTPlotSymbol.dashPlotSymbol();
        selectedAltPlotSymbol.fill = CPTFill(color: CPTColor(CGColor: color.CGColor));
        selectedAltPlotSymbol.lineStyle = symbolLineStyle;
        selectedAltPlotSymbol.size = CGSize(width: plotSymbolSize, height: plotSymbolSize);
        
        unselectedAltPlotSymbol = CPTPlotSymbol.dashPlotSymbol();
        unselectedAltPlotSymbol.size = CGSize(width: plotSymbolSize, height: plotSymbolSize);
        let unselectedAltPlotLineStyle = CPTMutableLineStyle();
        if secondaryColor != nil {
            unselectedAltPlotLineStyle.lineColor = CPTColor(CGColor: secondaryColor!.CGColor);
            unselectedAltPlotSymbol.fill = CPTFill(color: CPTColor(CGColor: secondaryColor!.CGColor));
            altSymbolLineStyle.lineColor = CPTColor(CGColor: secondaryColor!.CGColor);
        }
        unselectedAltPlotLineStyle.lineWidth = 1;
        unselectedAltPlotSymbol.lineStyle = unselectedAltPlotLineStyle;
        for index in 0..<altPoints.count {
            let point2 = altPoints[index];
            if (point2.y < minY) {
                minY = point2.y;
            }
            if (point2.y > maxY) {
                maxY = point2.y;
            }
        }
        for index in 0..<points.count {
            let point = points[index];
            if (point.y < minY) {
                minY = point.y;
            }
            if (point.y > maxY) {
                maxY = point.y;
            }
        }
        if (altPoints.count > 1) {
            altPlot = NewCPTScatterPlot(frame: CGRectZero);
            if (altPoints[0].x == altPoints[1].x) {
                altPlot.interpolation = CPTScatterPlotInterpolationLinear;
                altPlot.dataLineStyle = unselectedAltPlotLineStyle;
                altPlot.delegate = self;
                shouldShowAltSymbol = true;
            } else if (altPoints[0].y == altPoints[1].y) {
                altPlot.interpolation = CPTScatterPlotInterpolationCurved;
                let dottedLineStyle = CPTMutableLineStyle();
                dottedLineStyle.lineColor = CPTColor(CGColor: Utility.colorFromHexString("#EEEEEE").CGColor);
                dottedLineStyle.lineWidth = 2.0;
                dottedLineStyle.dashPattern = [2];
                altPlot.dataLineStyle = dottedLineStyle;
                altPlot.plotSymbol = nil;
                altPlot.delegate = self;
                shouldShowAltSymbol = false;
            } else {
                altPlot.interpolation = CPTScatterPlotInterpolationCurved;
                let noSymbol = CPTPlotSymbol.ellipsePlotSymbol();
                noSymbol.size = CGSize(width: 0, height: 0);
                altPlot.plotSymbol = noSymbol;
                altPlot.dataLineStyle = altSymbolLineStyle;
                shouldShowAltSymbol = false;
            }
            altPlot.plotSymbolMarginForHitDetection = CGFloat(hitMargin);
            altPlot.dataSource = self;
            altPlot.setAreaBaseDecimalValue(0);
            //add alt plot here so that it's drawn behind main plot
            graph.addPlot(altPlot, toPlotSpace: graph.defaultPlotSpace);
        }
        var firstPoint, lastPoint: GraphPoint;
        if (points.count > 0) {
            firstPoint = points[points.count - 1];
            lastPoint = points[0];
        } else {
            firstPoint = GraphPoint(x: 0, y: 0);
            lastPoint = GraphPoint(x: 0, y: 0);
            minY = 0;
        }
        let tickInterval = 10.0;

        let yRange = maxY - minY > 0 ? maxY - minY : tickInterval;
        let lowerBound = roundToLowest(minY - (yRange * 0.4), roundTo: tickInterval);
        var distance = roundToHighest(yRange * 1.8, roundTo: tickInterval);
        if lowerBound + distance < maxY {
            distance = maxY - lowerBound + tickInterval;
        }
        var visibleMin = firstPoint;
        if (points.count > 30) {
            visibleMin = points[30];
        }
        var marginX:Double = (lastPoint.x - visibleMin.x) * 0.1;
        if (marginX == 0) {
            marginX = 4 * 86400;
        }
        let plotSpace = self.hostedGraph.defaultPlotSpace as! CPTXYPlotSpace;
        plotSpace.xRange = NewCPTPlotRange(location: visibleMin.x - marginX, length: lastPoint.x - visibleMin.x + marginX * 2);
        plotSpace.yRange = NewCPTPlotRange(location: lowerBound, length: distance);
        plotSpace.globalXRange = NewCPTPlotRange(location: firstPoint.x - marginX, length: lastPoint.x - firstPoint.x + marginX * 2);
        plotSpace.globalYRange = plotSpace.yRange;
        plotSpace.delegate = self;
        plotSpace.allowsUserInteraction = true;

        plot = NewCPTScatterPlot(frame: CGRectZero);
        plot.interpolation = CPTScatterPlotInterpolationCurved;
        plot.setAreaBaseDecimalValue(0);
        plot.plotSymbolMarginForHitDetection = CGFloat(hitMargin);
        plot.dataSource = self;
        plot.delegate = self;
        plot.plotSymbol = plotSymbol;
        let lineStyle = CPTMutableLineStyle();
        lineStyle.lineColor = CPTColor(CGColor: color.CGColor);
        lineStyle.lineWidth = 2;
        plot.dataLineStyle = lineStyle;
        
        let axisTextStyle = CPTMutableTextStyle();
        axisTextStyle.color = CPTColor.grayColor();
        axisTextStyle.fontSize = 8;
        
        let xAxis = graph.axisSet.axisForCoordinate(CPTCoordinateX, atIndex: 0) as! CPTXYAxis;
        xAxis.labelTextStyle = axisTextStyle;
        xAxis.majorTickLineStyle = nil;
        xAxis.minorTickLineStyle = nil;
        xAxis.visibleRange = NewCPTPlotRange(location: firstPoint.x, length: lastPoint.x - firstPoint.x);
        xAxis.axisConstraints = CPTConstraints(lowerOffset: 0);
        xAxis.labelingPolicy = CPTAxisLabelingPolicyEqualDivisions;
        xAxis.preferredNumberOfMajorTicks = 5;
        xAxis.axisLineStyle = nil;
        xAxis.labelOffset = 0;
        xAxis.tickDirection = CPTSignPositive;
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "MM/dd/YY";
        xAxis.labelFormatter = CustomFormatter(dateFormatter: dateFormatter);
        
        let yAxis = graph.axisSet.axisForCoordinate(CPTCoordinateY, atIndex: 0) as! CPTXYAxis;
        yAxis.axisLineStyle = nil;
        yAxis.labelTextStyle = axisTextStyle;
        yAxis.labelOffset = CGFloat(20);
        yAxis.majorTickLineStyle = nil;
        yAxis.minorTickLineStyle = nil;
        yAxis.visibleRange = plotSpace.yRange;
        yAxis.gridLinesRange = plotSpace.xRange;
        yAxis.axisConstraints = CPTConstraints(lowerOffset: -20);
        yAxis.labelingPolicy = CPTAxisLabelingPolicyEqualDivisions;
        let numberFormatter = NSNumberFormatter();
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle;
        numberFormatter.maximumFractionDigits = 0;
        yAxis.labelFormatter = numberFormatter;
        yAxis.tickDirection = CPTSignPositive;
        yAxis.labelOffset = 0;
        yAxis.preferredNumberOfMajorTicks = 5;
        //hide first tick mark
        yAxis.labelExclusionRanges = [NewCPTPlotRange(location: lowerBound - 1, length: 2)];
        graph.addPlot(plot, toPlotSpace: graph.defaultPlotSpace);
        
        checkinSelected(plot, idx: 0, first: true);
    }
    
    func roundToLowest(number: Double, roundTo: Double) -> Double {
        return Double(Int(number / roundTo) * Int(roundTo));
    }
    
    func roundToHighest(number: Double, roundTo: Double) -> Double {
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
    
    func symbolFromXValue(xValue: Double) {
        var minDifference = DBL_MAX;
        var i = 0;
        for point in points {
            let difference = abs(xValue - point.x)
            if difference < minDifference {
                minDifference = difference;
                selectedPointIndex = i;
            }
            i++;
        }
        self.plot.reloadData();
    }
    
    func scatterPlot(plot: CPTScatterPlot!, plotSymbolWasSelectedAtRecordIndex idx: UInt) {
        checkinSelected(plot, idx: Int(idx), first: false);
    }
    
    func checkinSelected(plot: CPTScatterPlot!, idx: Int, first: Bool) {
        if (idx < 0) {
            return;
        }
                
        var point:GraphPoint!;
        if (plot.isEqual(self.plot)) {
            selectedPointIndex = idx;
            point = points[idx];
        } else {
            selectedPointIndex = Int(idx / 2);
            point = altPoints[idx];
            altPlot.reloadData();
        }
        
        if (!first) {
            let viewController = self.superview!.superview!.superview as! MetricCard?;
            viewController!.setSelected(NSDate(timeIntervalSince1970: point.x));
        }
        
        self.plot.reloadData();
        if (altPoints.count > 0) {
            self.altPlot.reloadData();
        }
    }
    
    func getScreenPoint(xPoint: CGFloat, yPoint: CGFloat)-> CGPoint {
        let xRange = (self.hostedGraph.defaultPlotSpace as! CPTXYPlotSpace).xRange;
        let yRange = (self.hostedGraph.defaultPlotSpace as! CPTXYPlotSpace).yRange;
        let frame = graph.frame;
        var location = yRange.locationDouble;
        var length = yRange.lengthDouble;
        let x = ((xPoint - CGFloat(xRange.locationDouble)) / CGFloat(xRange.lengthDouble)) * frame.size.width;
        let y = (1.0 - ((yPoint - CGFloat(yRange.locationDouble)) / CGFloat(yRange.lengthDouble))) * (frame.size.height - 20);
        return CGPoint(x: x, y: y);
    }
    
    func symbolForScatterPlot(plot: CPTScatterPlot!, recordIndex idx: UInt) -> CPTPlotSymbol! {
        if (plot.isEqual(self.plot)) {
            if selectedPointIndex == Int(idx) {
                return selectedPlotSymbol;
            } else {
                return plotSymbol;
            }
        } else {
            if (shouldShowAltSymbol) {
                if (idx % 2 == 1) {
                    if (Int(idx) == ((selectedPointIndex * 2) + 1)) {
                        return selectedAltPlotSymbol;
                    }
                } else if (Int(idx) == (selectedPointIndex * 2)) {
                    return selectedAltPlotSymbol;
                }
            } else {
                let noSymbol = CPTPlotSymbol.ellipsePlotSymbol();
                noSymbol.size = CGSize(width: 0, height: 0);
                return noSymbol;
            }
            return unselectedAltPlotSymbol;
        }
    }
    
    func plotSpace(space: CPTPlotSpace!, willChangePlotRangeTo newRange: CPTPlotRange!, forCoordinate coordinate: CPTCoordinate) -> CPTPlotRange! {
        if (coordinate.rawValue == 1) {
            return (space as! CPTXYPlotSpace).yRange;
        }
        return newRange;
    }
    
    func selectPlotFromPoint(point: CGPoint) {
        let index = Int(plot.dataIndexFromInteractionPoint(point));
        checkinSelected(plot as CPTScatterPlot!, idx: index, first: false);
    }
}
