//
//  BpGraph.swift
//  higi
//
//  Created by Dan Harms on 6/24/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class BpGraphHostingView: BaseCustomGraphHostingView {
    
    var points2: [GraphPoint];
    
    var diastolicPlot: NewCPTScatterPlot;
    
    init(frame: CGRect, systolicPoints: [GraphPoint], diastolicPoints: [GraphPoint], isPortrait: Bool) {
        points2 = diastolicPoints;
        points2.append(GraphPoint(x: Double(NSDate().timeIntervalSince1970), y: points2.last!.y));
        diastolicPlot = NewCPTScatterPlot(frame: CGRectZero);
        super.init(frame: frame, points: systolicPoints, isPortrait: isPortrait);
    }
    
    required init(coder aDecoder: NSCoder!) {
        fatalError("NSCoding not supported");
    }
    
    override func numberForPlot(plot: CPTPlot?, field fieldEnum: UInt, recordIndex idx: UInt) -> NSNumber {
        if (plot == diastolicPlot) {
            var point = points2[Int(idx)];
            if (fieldEnum == 0) {
                return NSNumber(double: point.x);
            } else {
                return NSNumber(double: point.y);
            }
        } else {
            return super.numberForPlot(plot, field: fieldEnum, recordIndex: idx);
        }
    }
    
    override func setupWithDefaults() {
        
        var max = 0.0;
        var min = 9999999.9;
        
        for index in 0..<points.count {
            var point = points[index];
            var point2 = points2[index];
            if (point.y > max) {
                max = point.y;
            }
            if (point2.y < min) {
                min = point2.y;
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
        self.allowPinchScaling = !isPortrait;
        
        graph.paddingLeft = 0;
        graph.paddingTop = 0;
        graph.paddingRight = 0;
        graph.paddingBottom = 0;
        graph.plotAreaFrame.paddingTop = 20;
        graph.plotAreaFrame.paddingBottom = 10;
        
        
        var plotSpace = self.hostedGraph.defaultPlotSpace as! CPTXYPlotSpace;
        plotSpace.allowsUserInteraction = true;
        plotSpace.xRange = NewCPTPlotRange(location: firstPoint.x - 1, length: lastPoint.x - firstPoint.x + 2);
        plotSpace.yRange = NewCPTPlotRange(location: min - yRange * 0.4, length: yRange * 2.2);
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
        
        var graphFill = CPTFill(color: CPTColor(componentRed: 1, green: 1, blue: 1, alpha: 0.14));
        
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
        
        diastolicPlot.interpolation = CPTScatterPlotInterpolationCurved;
        diastolicPlot.setAreaBaseDecimalValue(0);
        diastolicPlot.dataSource = self;
        diastolicPlot.delegate = self;
        
        if (!isPortrait) {
            diastolicPlot.plotSymbol = plotSymbol;
        }
        diastolicPlot.dataLineStyle = lineStyle;
        diastolicPlot.areaFill = graphFill;
        
        self.hostedGraph.addPlot(diastolicPlot, toPlotSpace: self.hostedGraph.defaultPlotSpace);
        (self.hostedGraph.plotAtIndex(0) as! CPTScatterPlot).areaFill = graphFill;
        
        plotSpace.yRange = NewCPTPlotRange(location: min - yRange * 0.1, length: yRange * 2.0);
        plotSpace.globalYRange = plotSpace.yRange;
        
        ((self.hostedGraph as! CPTXYGraph).axisSet.axisForCoordinate(CPTCoordinateY, atIndex: 0) as! CPTXYAxis).visibleRange = plotSpace.yRange;
        plotSpace.delegate = self;
    }
    override func plotSpace(space: CPTPlotSpace?, willChangePlotRangeTo: CPTPlotRange?, forCoordinate: CPTCoordinate) -> CPTPlotRange {
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
        var average2 = 0.0, highest2 = 0.0, lowest2 = 9999999.0;
        if (low > -1) {
            for index in low...high {
                var point = points[index];
                var point2 = points2[index];
                average += point.y;
                if (point.y > highest) {
                    highest = point.y;
                }
                if (point.y < lowest) {
                    lowest = point.y;
                }
                average2 += point2.y;
                if (point2.y > highest2) {
                    highest2 = point2.y;
                }
                if (point2.y < lowest2) {
                    lowest2 = point2.y;
                }
            }
        }
        var trend = "";
        if (average > 0) {
            average /= Double(high + 1 - low);
            average2 /= Double(high + 1 - low);
            trend = "\(Int(average + 0.5))/\(Int(average2 + 0.5)) Average  |  \(Int(highest))/\(Int(highest2)) Highest  |  \(Int(lowest))/\(Int(lowest2)) Lowest";
        }
        var graphView = self.superview!.superview as! GraphView;
        graphView.updateTrend(trend);
        return range;
    }
    
}