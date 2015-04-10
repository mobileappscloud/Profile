//
//  CustomerGraphHostingView.swift
//  higi
//
//  Created by Dan Harms on 6/24/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class BaseCustomGraphHostingView: CPTGraphHostingView, CPTScatterPlotDataSource, CPTPlotSpaceDelegate, CPTScatterPlotDelegate {
    
    let MONTH_1 = 0, MONTH_3 = 1, MONTH_6 = 2, ALL = 3;
    
    var points: [GraphPoint];
    
    var isPortrait: Bool;
    
    init(frame: CGRect, points: [GraphPoint], isPortrait: Bool) {
        self.points = points;
        self.points.append(GraphPoint(x: Double(NSDate().timeIntervalSince1970), y: points.last!.y));
        self.isPortrait = isPortrait;
        super.init(frame: frame);
        //setupWithDefaults();
    }
    
    required init(coder aDecoder: NSCoder?) {
        fatalError("NSCoding not supported");
    }
    
    func setupWithDefaults() {
        
        var graph = CPTXYGraph(frame: self.bounds);
        self.hostedGraph = graph;
        self.allowPinchScaling = !isPortrait;
        
        graph.paddingLeft = 0;
        graph.paddingTop = 0;
        graph.paddingRight = 0;
        graph.paddingBottom = 0;
        graph.plotAreaFrame.paddingTop = 20;
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
        
        var plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace;
        plotSpace.allowsUserInteraction = true;
        plotSpace.xRange = NewCPTPlotRange(location: firstPoint.x - 1, length: lastPoint.x - firstPoint.x + 2);
        plotSpace.yRange = NewCPTPlotRange(location: min - yRange * 0.25, length: yRange * 2.0);
        plotSpace.globalXRange = plotSpace.xRange;
        plotSpace.globalYRange = plotSpace.yRange;
        plotSpace.delegate = self;
        
        var plot = NewCPTScatterPlot(frame: CGRectZero);
        plot.interpolation = CPTScatterPlotInterpolationCurved;
        plot.areaFill = CPTFill(color: CPTColor(componentRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.5));
        plot.setAreaBaseDecimalValue(0);
        var hitMargin = 0;
        if (!isPortrait) {
            hitMargin = 5;
        }
        plot.plotSymbolMarginForHitDetection = CGFloat(hitMargin);
        plot.dataSource = self;
        plot.delegate = self;
        
        var lineStyle = CPTMutableLineStyle();
        lineStyle.lineColor = CPTColor.whiteColor();
        lineStyle.lineWidth = 1;
        
        var noLineStyle = CPTMutableLineStyle();
        noLineStyle.lineWidth = 0;
        
        var symbolLineStyle = CPTMutableLineStyle();
        symbolLineStyle.lineColor = CPTColor.whiteColor();
        symbolLineStyle.lineWidth = 2;
        
        var plotSymbol = CPTPlotSymbol.ellipsePlotSymbol();
        plotSymbol.lineStyle = symbolLineStyle;
        plotSymbol.size = CGSize(width: 5.0, height: 5.0);
        
        var graphFill = CPTFill(color: CPTColor(componentRed: 1, green: 1, blue: 1, alpha: 0.25));
        
        if (!isPortrait) {
            plot.plotSymbol = plotSymbol;
        }
        plot.dataLineStyle = lineStyle;
        plot.areaFill = graphFill;
        
        graph.addPlot(plot, toPlotSpace: graph.defaultPlotSpace);
        graph.plotAreaFrame.borderLineStyle = nil;
        
        var axisTextStyle = CPTMutableTextStyle();
        axisTextStyle.color = CPTColor.whiteColor();
        axisTextStyle.fontSize = 8;
        
        var gridLineStyle = CPTMutableLineStyle();
        gridLineStyle.lineColor = CPTColor(componentRed: 1, green: 1, blue: 1, alpha: 0.3);
        
        var xAxis = graph.axisSet.axisForCoordinate(CPTCoordinateX, atIndex: 0) as! CPTXYAxis;
        xAxis.labelTextStyle = axisTextStyle;
        xAxis.majorTickLineStyle = nil;
        xAxis.minorTickLineStyle = nil;
        xAxis.visibleRange = plotSpace.xRange;
        xAxis.gridLinesRange = plotSpace.yRange;
        xAxis.axisConstraints = CPTConstraints(lowerOffset: 0);
        xAxis.labelingPolicy = CPTAxisLabelingPolicyEqualDivisions;
        if (isPortrait) {
            xAxis.preferredNumberOfMajorTicks = 5;
            xAxis.axisLineStyle = noLineStyle;
            xAxis.labelOffset = -10;
        } else {
            xAxis.preferredNumberOfMajorTicks = 10;
            xAxis.majorGridLineStyle = gridLineStyle;
            xAxis.axisLineStyle = lineStyle;
            xAxis.labelOffset = 0;
        }
        
        xAxis.tickDirection = CPTSignPositive;
        var dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "MM/dd/yy";
        xAxis.labelFormatter = CustomFormatter(dateFormatter: dateFormatter);
        
        var yAxis = graph.axisSet.axisForCoordinate(CPTCoordinateY, atIndex: 0) as! CPTXYAxis;
        
        if (isPortrait) {
            yAxis.preferredNumberOfMajorTicks = 5;
            yAxis.axisLineStyle = noLineStyle;
        } else {
            yAxis.preferredNumberOfMajorTicks = 10;
            yAxis.majorGridLineStyle = gridLineStyle;
            yAxis.axisLineStyle = lineStyle;
        }
        
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
        
        setRange(ALL, delegate: nil);
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
    
    func plotSpace(space: CPTPlotSpace?, willChangePlotRangeTo: CPTPlotRange?, forCoordinate: CPTCoordinate) -> CPTPlotRange {
        var range = ConversionUtility.plotSpace(space, willChangePlotRangeTo: willChangePlotRangeTo, forCoordinate: forCoordinate);
        if (forCoordinate.value == 1) {
            return range;
        }
        var low = -1, high = -1;
        if (points.count == 0 || (range.containsDouble(points[0].x) && range.containsDouble(points[points.count - 1].x))) {
            if (!isPortrait) {
                (self.superview!.superview!.superview as! UIScrollView).scrollEnabled = true;
            }
            low = 0;
            high = points.count - 1;
        } else {
            if (!isPortrait) {
                (self.superview!.superview!.superview as! UIScrollView).scrollEnabled = false;
            }
            
            var index = 0;
            for point: GraphPoint in points {
                if (range.containsDouble(point.x)) {
                    if (low == -1) {
                        low = index;
                    }
                    high = index;
                } else if (low != -1) {
                    break;
                }
                index++;
            }
            
        }
        if (high == points.count - 1 && low != high) {
            high--;
        }
        var average = 0.0, highest = 0.0, lowest = 9999999.0;
        if (low > -1) {
            for index in low...high {
                var point = points[index];
                average += point.y;
                if (point.y > highest) {
                    highest = point.y;
                }
                if (point.y < lowest) {
                    lowest = point.y;
                }
            }
        }
        var trend = "";
        if (average > 0) {
            average /= Double(high + 1 - low);
            trend = "\(Int(average + 0.5)) Average  |  \(Int(highest)) Highest  |  \(Int(lowest)) Lowest";
        }
        var graphView = self.superview!.superview as! GraphView;
        graphView.updateTrend(trend);
        return range;
    }
    
    func plotSpace(space: CPTPlotSpace!, didChangePlotRangeForCoordinate coordinate: CPTCoordinate) {
        var graphView = self.superview!.superview as! GraphView;
        graphView.setSelectedCheckin(graphView.checkins[graphView.selected]);
    }
    
    func setRange(mode: Int, delegate: NSObject!) {
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
        var monthInSecs = 2592000.0;
        switch (mode) {
        case MONTH_1:
            newRange = NewCPTPlotRange(location: lastPoint.x - monthInSecs, length: monthInSecs);
        case MONTH_3:
            newRange = NewCPTPlotRange(location: lastPoint.x - monthInSecs * 3.0, length: monthInSecs * 3.0);
        case MONTH_6:
            newRange = NewCPTPlotRange(location: lastPoint.x - monthInSecs * 6.0, length: monthInSecs * 6.0);
        default:
            newRange = NewCPTPlotRange(location: firstPoint.x, length: lastPoint.x - firstPoint.x + 1);
        }
        //CPTAnimation.animate(plotSpace, property: "xRange", fromPlotRange: plotSpace.xRange, toPlotRange: newRange, duration: 0.1, animationCurve: CPTAnimationCurveCubicInOut, delegate: delegate);
        
        plotSpace.xRange = newRange;

    }
    
    func scatterPlot(plot: CPTScatterPlot?, plotSymbolWasSelectedAtRecordIndex idx: UInt) {
        (self.superview!.superview as! GraphView).pointClicked(Int(idx));
    }
    
}
