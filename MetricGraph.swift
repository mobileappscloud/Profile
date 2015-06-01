import Foundation

class MetricGraph: CPTGraphHostingView, CPTScatterPlotDelegate, CPTScatterPlotDataSource, CPTPlotSpaceDelegate {
    
    var points: [GraphPoint], altPoints: [GraphPoint] = [], systolicPoints: [GraphPoint] = [], diastolicPoints: [GraphPoint] = [];
    
    var plot, altPlot: NewCPTScatterPlot!;
    
    var plotSymbol, selectedPlotSymbol, altPlotSymbol, selectedAltPlotSymbol, unselectedAltPlotSymbol:CPTPlotSymbol!;
    
    var lastSelectedAltPlotIndex = -1, selectedPointIndex = -1;
    
    var graph: CPTXYGraph!;
    
    var altPlotLinesAdded = false;
    
    init(frame: CGRect, points: [GraphPoint]) {
        self.points = points;
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
    
    func setupGraph(type: MetricsType, dashboard: Bool) {
        let color = Utility.colorFromMetricType(type);
    }
    
    func initGraph() {
        graph = CPTXYGraph(frame: self.bounds);
        self.hostedGraph = graph;
        graph.paddingLeft = 0;
        graph.paddingTop = 0;
        graph.paddingRight = 0;
        graph.paddingBottom = 0;
    }
    
    func setupForDashboard(type: MetricsType) {
        if (points.count < 1) {
            return;
        } else {
            let color = Utility.colorFromMetricType(type);
            var maxY = 0.0, minY = DBL_MAX, maxX = 0.0, minX = DBL_MAX;
            initGraph();
            graph.plotAreaFrame.paddingBottom = 10;
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
                    let a = point.x;
                    minX = round(point.x);
                }
            }

            var yRange = maxY - minY > 1 ? maxY - minY : 1;
            var xRange = maxX - minX > 1 ? maxX - minX : 1;

            var plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace;
            plotSpace.xRange = NewCPTPlotRange(location: max(round(minX) - xRange * 0.05, 0), length: xRange * 1.05);
            plotSpace.yRange = NewCPTPlotRange(location: round(minY) - yRange * 0.25, length: yRange * 1.5);
            plotSpace.globalXRange = plotSpace.xRange;
            plotSpace.globalYRange = plotSpace.yRange;
            plotSpace.delegate = self;
            
            plot = NewCPTScatterPlot(frame: CGRectZero);
            plot.interpolation = CPTScatterPlotInterpolationCurved;
            plotSymbol = CPTPlotSymbol.ellipsePlotSymbol();
            plotSymbol.size = CGSize(width: 0, height: 0);
            plot.plotSymbol = plotSymbol;
            plot.plotSymbolMarginForHitDetection = CGFloat(0);
            plot.dataSource = self;
            plot.delegate = self;
            var lineStyle = CPTMutableLineStyle();
            lineStyle.lineColor = CPTColor(CGColor: color.CGColor);
            lineStyle.lineWidth = 2;
            plot.dataLineStyle = lineStyle;
            plotSymbol.size = CGSize(width: 0, height: 0);
            plot.plotSymbol = plotSymbol;
            
            var xAxis = graph.axisSet.axisForCoordinate(CPTCoordinateX, atIndex: 0) as! CPTXYAxis;
            xAxis.visibleRange = plotSpace.xRange;
            xAxis.gridLinesRange = plotSpace.yRange;
            xAxis.axisConstraints = CPTConstraints(lowerOffset: 0);
            xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
            var xAxisLineStyle = CPTMutableLineStyle();
            xAxisLineStyle.lineColor = CPTColor(CGColor: UIColor.lightGrayColor().CGColor);
            xAxisLineStyle.lineWidth = 1;
            xAxis.axisLineStyle = xAxisLineStyle;
            
            var yAxis = graph.axisSet.axisForCoordinate(CPTCoordinateY, atIndex: 0) as! CPTXYAxis;
            yAxis.visibleRange = plotSpace.yRange;
            yAxis.gridLinesRange = plotSpace.xRange;
            yAxis.axisConstraints = CPTConstraints(lowerOffset: 0);
            yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
            var yAxisLineStyle = CPTMutableLineStyle();
            yAxisLineStyle.lineColor = CPTColor(CGColor: UIColor.lightGrayColor().CGColor);
            yAxisLineStyle.lineWidth = 2;
            yAxis.axisLineStyle = yAxisLineStyle;
            
            graph.addPlot(plot, toPlotSpace: graph.defaultPlotSpace);
        }
    }
    
    func setupForMetric(type: MetricsType, isBodyFat: Bool) {
        let color = Utility.colorFromMetricType(type), unselectedColor = Utility.colorFromHexString("#b4a6c2");
        var maxY = 0.0, minY = DBL_MAX, plotSymbolSize = 7.0;
        let hitMargin = 5, pointsToShow = 30;
        
        initGraph();
        self.allowPinchScaling = true;
        graph.plotAreaFrame.paddingTop = 20;
        graph.plotAreaFrame.borderLineStyle = nil;

        plotSymbol = CPTPlotSymbol.ellipsePlotSymbol();
        plotSymbol.fill = CPTFill(color: CPTColor.whiteColor());
        var symbolLineStyle = CPTMutableLineStyle();
        symbolLineStyle.lineColor = CPTColor(CGColor: color.CGColor);
        symbolLineStyle.lineWidth = 2;
        plotSymbol.lineStyle = symbolLineStyle;
        plotSymbol.size = CGSize(width: plotSymbolSize, height: plotSymbolSize);
        
        selectedPlotSymbol = CPTPlotSymbol.ellipsePlotSymbol();
        selectedPlotSymbol.fill = CPTFill(color: CPTColor(CGColor: color.CGColor));
        selectedPlotSymbol.lineStyle = symbolLineStyle;
        selectedPlotSymbol.size = CGSize(width: plotSymbolSize, height: plotSymbolSize);
        
        altPlotSymbol = CPTPlotSymbol.ellipsePlotSymbol();
        altPlotSymbol.fill = CPTFill(color: CPTColor(CGColor: color.CGColor));
        altPlotSymbol.lineStyle = symbolLineStyle;
        altPlotSymbol.size = CGSize(width: plotSymbolSize, height: plotSymbolSize);
        
        selectedAltPlotSymbol = CPTPlotSymbol.ellipsePlotSymbol();
        selectedAltPlotSymbol.fill = CPTFill(color: CPTColor(CGColor: color.CGColor));
        selectedAltPlotSymbol.lineStyle = symbolLineStyle;
        selectedAltPlotSymbol.size = CGSize(width: plotSymbolSize, height: plotSymbolSize);
        
        unselectedAltPlotSymbol = CPTPlotSymbol.ellipsePlotSymbol();
        unselectedAltPlotSymbol.fill = CPTFill(color: CPTColor(CGColor: unselectedColor.CGColor));
        unselectedAltPlotSymbol.size = CGSize(width: plotSymbolSize, height: plotSymbolSize);
        var unselectedAltPlotLineStyle = CPTMutableLineStyle();
        unselectedAltPlotLineStyle.lineColor = CPTColor(CGColor: unselectedColor.CGColor);
        unselectedAltPlotLineStyle.lineWidth = 1;
        unselectedAltPlotSymbol.lineStyle = unselectedAltPlotLineStyle;
        
        var visiblePoints: [GraphPoint] = [];
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
            if (diastolicPoints.count > 0 && diastolicPoints.count > index && systolicPoints.count > 0 && systolicPoints.count > index) {
                altPoints.append(systolicPoints[index]);
                altPoints.append(diastolicPoints[index]);
                
                let systolicPoint = systolicPoints[index];
                let diastolicPoint = diastolicPoints[index];
                let screenSystolicPoint = getScreenPoint(self, xPoint: CGFloat(systolicPoint.x), yPoint: CGFloat(systolicPoint.y));
                let screenDiastolicPoint = getScreenPoint(self, xPoint: CGFloat(diastolicPoint.x), yPoint: CGFloat(diastolicPoint.y));

                let view = UIView(frame: CGRect(x: screenSystolicPoint.x - 0.5, y: self.frame.size.height - CGFloat(screenSystolicPoint.y) - 24, width: 1, height: CGFloat(screenSystolicPoint.y - screenDiastolicPoint.y)));
                view.backgroundColor = plotSymbol.lineStyle.lineColor.uiColor;
                addSubview(view);
            }
            if (points.count > pointsToShow) {
                if (index > points.count - 1 - pointsToShow) {
                    visiblePoints.append(point);
                }
            } else {
                visiblePoints.append(point);
            }
        }
        if (diastolicPoints.count > 0) {
            altPlot = NewCPTScatterPlot(frame: CGRectZero);
            altPlot.interpolation = CPTScatterPlotInterpolationLinear;
            altPlot.plotSymbolMarginForHitDetection = CGFloat(hitMargin);
            altPlot.dataSource = self;
            altPlot.delegate = self;
            altPlot.setAreaBaseDecimalValue(0);
            altPlot.plotSymbol = altPlotSymbol;
            var noLineStyle = CPTMutableLineStyle();
            noLineStyle.lineWidth = 0;
            altPlot.dataLineStyle = noLineStyle;
            //add alt plot here so that it's drawn behind main plot
            graph.addPlot(altPlot, toPlotSpace: graph.defaultPlotSpace);
        }
        var firstPoint, lastPoint: GraphPoint;
        if (visiblePoints.count > 0) {
            firstPoint = visiblePoints[0];
            lastPoint = visiblePoints[visiblePoints.count - 1];
        } else {
            firstPoint = GraphPoint(x: 0, y: 0);
            lastPoint = GraphPoint(x: 0, y: 0);
            minY = 0;
        }
        let lowerBound = isBodyFat ? 10 : roundToLowest(minY - 1, roundTo: 20);
        let upperBound = isBodyFat ? 50 : roundToHighest(maxY + 1, roundTo: 20);
        var xRange = lastPoint.x - firstPoint.x != 0 ? lastPoint.x - firstPoint.x : 1;
        var plotSpace = self.hostedGraph.defaultPlotSpace as! CPTXYPlotSpace;
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
        plot.plotSymbol = plotSymbol;
        var lineStyle = CPTMutableLineStyle();
        lineStyle.lineColor = CPTColor(CGColor: color.CGColor);
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
        if (isBodyFat) {
            yAxis.preferredNumberOfMajorTicks = UInt(Int((upperBound - lowerBound) / 10)) + 1;
        } else {
            yAxis.preferredNumberOfMajorTicks = UInt(Int((upperBound - lowerBound) / 20)) + 1;
        }
        
        graph.addPlot(plot, toPlotSpace: graph.defaultPlotSpace);
        
        checkinSelected(plot, idx: points.count - 1, first: true);
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event);
        let i = 0;
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
    
    func scatterPlot(plot: CPTScatterPlot!, plotSymbolWasSelectedAtRecordIndex idx: UInt) {
        checkinSelected(plot, idx: Int(idx), first: false);
    }
    
    func checkinSelected(plot: CPTScatterPlot!, idx: Int, first: Bool) {
        if (plot.isEqual(self.plot)) {
            selectedPointIndex = idx;
        } else {
            selectedPointIndex = Int(idx / 2);
        }
        if (!first) {
            var viewController = self.superview!.superview!.superview as! MetricCard?;
            viewController!.setSelected(selectedPointIndex);
        }
        if (diastolicPoints.count > 0) {
            altPlot.reloadData();
        }
        self.plot.reloadData();
    }
    
    func getScreenPoint(graph: MetricGraph, xPoint: CGFloat, yPoint: CGFloat)-> CGPoint {
        var xRange = (graph.hostedGraph.defaultPlotSpace as! CPTXYPlotSpace).xRange;
        var yRange = (graph.hostedGraph.defaultPlotSpace as! CPTXYPlotSpace).yRange;
        var frame = graph.frame;
        var x = ((xPoint - CGFloat(xRange.locationDouble)) / CGFloat(xRange.lengthDouble)) * frame.size.width;
        var y = (1.0 - ((yPoint - CGFloat(yRange.locationDouble)) / CGFloat(yRange.lengthDouble))) * (frame.size.height - 30);
        return CGPoint(x: x, y: y);
    }
    
    func symbolForScatterPlot(plot: CPTScatterPlot!, recordIndex idx: UInt) -> CPTPlotSymbol! {
        if (plot.isEqual(self.plot)) {
            return selectedPointIndex == Int(idx) ? selectedPlotSymbol : plotSymbol;
        } else {
            if (idx % 2 == 1) {
                if (Int(idx) == ((selectedPointIndex * 2) + 1)) {
                    return selectedAltPlotSymbol;
                }
            } else {
                if (altPoints.count > 0 && !altPlotLinesAdded) {
                    let systolicPoint = altPoints[Int(idx)];
                    let diastolicPoint = altPoints[Int(idx) + 1];
                    let screenSystolicPoint = getScreenPoint(self, xPoint: CGFloat(systolicPoint.x), yPoint: CGFloat(systolicPoint.y));
                    let screenDiastolicPoint = getScreenPoint(self, xPoint: CGFloat(diastolicPoint.x), yPoint: CGFloat(diastolicPoint.y));

                    let view = UIView(frame: CGRect(x: screenSystolicPoint.x - 0.5, y: self.frame.size.height - CGFloat(screenSystolicPoint.y) - 24, width: 1, height: CGFloat(screenSystolicPoint.y - screenDiastolicPoint.y)));
                    view.backgroundColor = plotSymbol.lineStyle.lineColor.uiColor;
                    addSubview(view);
                    if (Int(idx) == altPoints.count - 2) {
                        altPlotLinesAdded = true;
                    }
                }
                if (Int(idx) == (selectedPointIndex * 2)) {
                    return selectedAltPlotSymbol;
                }
            }
            return unselectedAltPlotSymbol;
        }
    }

    
    func selectPlotFromPoint(point: CGPoint) {
        let index = Int(plot.dataIndexFromInteractionPoint(point));
        checkinSelected(plot as CPTScatterPlot!, idx: index, first: false);
    }
    
//    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
//        let index = Int(plot.dataIndexFromInteractionPoint(point));
//        checkinSelected(plot as CPTScatterPlot!, idx: index - 1, first: false);
//        return true;
//    }
    
//    func plotSpace(space: CPTPlotSpace!, didChangePlotRangeForCoordinate coordinate: CPTCoordinate) {
//        var graphView = self.superview!.superview as! MetricGraph;
//        graphView.setSelectedCheckin(graphView.checkins[graphView.selected]);
//        checkinSelected(plot as CPTScatterPlot!, idx: index - 1);
//    }

}
