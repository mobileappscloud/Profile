//
//  ActivityGraphHostingView.swift
//  higi
//
//  Created by Dan Harms on 11/26/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class ActivityGraphHostingView: CPTGraphHostingView, CPTBarPlotDataSource {
    
    var points: [String: [Int]]!;
    var lastDevice = "";
    var totalPlotPoints:[Int] = [0,0,0,0,0,0,0];
    
    enum Mode {
        case DAY
        case WEEK
        case MONTH
    }
    
    init(frame: CGRect, points: [String: [Int]]) {
        super.init(frame: frame);
        self.points = points;
    }
    
    required init(coder aDecoder: NSCoder?) {
        fatalError("NSCoding not supported");
    }
    
    func setupGraph(mode: Mode) {
        var graph = CPTXYGraph(frame: self.bounds);
        self.hostedGraph = graph;
        self.allowPinchScaling = false;
        
        graph.paddingLeft = -10;
        graph.paddingTop = 0;
        graph.paddingRight = 0;
        graph.paddingBottom = -20;
        
        graph.plotAreaFrame.paddingLeft = 40;
        graph.plotAreaFrame.paddingTop = 5;
        graph.plotAreaFrame.paddingBottom = 20;
        
        var axes = graph.axisSet as CPTXYAxisSet;
        
        var xAxis = axes.xAxis;
        xAxis.majorTickLength = 0;
        xAxis.minorTicksPerInterval = 0;
        xAxis.axisConstraints = CPTConstraints.constraintWithLowerOffset(0.0);
        var formatter = NSNumberFormatter();
        formatter.generatesDecimalNumbers = false;
        xAxis.labelFormatter = formatter;
        
        var yAxis = axes.yAxis;
        yAxis.minorTicksPerInterval = 0;
        yAxis.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
        yAxis.axisConstraints = CPTConstraints.constraintWithLowerOffset(0.0);
        yAxis.labelFormatter = formatter;
        
        var plotSpace = graph.defaultPlotSpace as CPTXYPlotSpace;
        plotSpace.allowsUserInteraction = false;

        var labelIndex = 0;
        var dateLabels:[CPTAxisLabel] = [];
        //NOTE this doesn't work because of the missing tickLocation property
        let dates = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
        for day in dates {
            var label = CPTAxisLabel(text: day, textStyle: xAxis.labelTextStyle);
            //label.tickLocation = CGFloat(labelIndex);
            label.offset = xAxis.labelOffset + xAxis.majorTickLength;
            dateLabels.append(label);
            
            labelIndex++;
        }
        xAxis.axisLabels = NSSet(array: dateLabels);
        
        var maxPlotPoints = 10;
        var firstPlot = true;
        var plotIndex = 0;
        for (device, pointArray) in points {
            var plot = CPTBarPlot(frame: CGRectZero);
            plot.fill = CPTFill(color: getDeviceColor(device));
            plot.barWidthScale = 1;
            
            plot.barBasesVary = !firstPlot;
            firstPlot = false;
            
            plot.dataSource = self;
            plot.name = device;
            
            graph.addPlot(plot, toPlotSpace: plotSpace);

            for index in 0...pointArray.count - 1 {
                var pointValue = pointArray[index];
                if (pointValue > maxPlotPoints) {
                    maxPlotPoints = pointValue;
                }
                totalPlotPoints[index] = totalPlotPoints[index] + pointValue;
            }
            plotIndex++;
            lastDevice = device;
        }
        plotSpace.xRange = NewCPTPlotRange(location: -1, length: 8);
        plotSpace.yRange = NewCPTPlotRange(location: 0, length: Double(maxPlotPoints) * 1.5);
        plotSpace.globalXRange = plotSpace.xRange;
        plotSpace.globalYRange = plotSpace.yRange;
    }
    
    func getDeviceColor(device: String) ->CPTColor {
        var color:UIColor;
        let deviceName = device.lowercaseString;

        if (deviceName == "jawbone") {
            color = UIColor.redColor();
        } else if (deviceName == "higi") {
            color = UIColor.whiteColor();
        } else if (deviceName == "moves") {
            color = UIColor.greenColor();
        } else {
            color = UIColor.blueColor();
        }
        return CPTColor(CGColor: color.CGColor);
    }
    
    func doubleForPlot(plot: CPTPlot!, field fieldEnum: UInt, recordIndex idx: UInt) -> Double {
        let a = idx;
        let b = fieldEnum;
        let pat = plot;
        
        let index = Int(idx);
        var plotValue = 0;
        if (fieldEnum == 0) {
            plotValue = Int(idx);
        } else {
            var offset = 0;
            var barPlot = plot as CPTBarPlot;
            if (barPlot.barBasesVary) {
                for (device, pointArray) in points {
                    var arr = pointArray;
                    if (plot.name.isEqual(device)) {
                        break;
                    } else {
                        let val = pointArray[Int(idx)]
                        offset += pointArray[Int(idx)];
                    }
                }
            }
            if (fieldEnum == 1) {
                if let pointsArray = points[plot.name] as [Int]! {
                    plotValue = pointsArray[Int(idx)] + offset;
                }
            } else {
                plotValue = offset;
            }
        }
        //masterPlots[index] = plotValue;
        return Double(plotValue);
    }
    
    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt {
        return 7;
    }

    func dataLabelForPlot(plot: CPTPlot!, recordIndex idx: UInt) -> CPTLayer! {
        let device = plot.name;
        //only make label for last index
        if (device == lastDevice) {
            var labelValue = 0;
            if let pointsArray = points[plot.name] as [Int]! {
                labelValue = totalPlotPoints[Int(idx)];
            }
            var label = CPTTextLayer(text: String(labelValue));
            plot.labelOffset = 0;
            return label;
        } else {
            return nil;
        }
    }

}