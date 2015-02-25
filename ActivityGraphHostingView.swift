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
        
        //not sure why, but graph was cutting off axes
        graph.plotAreaFrame.paddingLeft = 40;
        graph.plotAreaFrame.paddingTop = 5;
        graph.plotAreaFrame.paddingBottom = 40;
        
        var formatter = NSNumberFormatter();
        formatter.generatesDecimalNumbers = false;
        
        var labelStyle = CPTMutableTextStyle();
        labelStyle.fontSize = 10;
        
        var axes = graph.axisSet as CPTXYAxisSet;
        var xAxis = axes.xAxis;
        var yAxis = axes.yAxis;
        
        xAxis.majorTickLength = 0;
        xAxis.minorTicksPerInterval = 0;
        xAxis.axisConstraints = CPTConstraints.constraintWithLowerOffset(0.0);
        xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
        xAxis.labelFormatter = formatter;
        xAxis.labelTextStyle = labelStyle;
        
        yAxis.minorTicksPerInterval = 0;
        yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
        yAxis.axisConstraints = CPTConstraints.constraintWithLowerOffset(5);
        yAxis.labelFormatter = formatter;
        yAxis.labelTextStyle = labelStyle;
        var plotSpace = graph.defaultPlotSpace as CPTXYPlotSpace;
        plotSpace.allowsUserInteraction = false;

        var dateLabels:[NewCPTAxisLabel] = [];

        let dates:[String] = populateDates(mode);
        let date = NSDate();
        for index in 0...6 {
            var label = NewCPTAxisLabel(text: dates[index], textStyle: xAxis.labelTextStyle);
            label.setTickIndex(Double(index));
            label.offset = xAxis.labelOffset + xAxis.majorTickLength;
            dateLabels.append(label);
        }
        xAxis.axisLabels = NSSet(array: dateLabels);
        
        var maxPlotPoints = 10;
        var firstPlot = true;
        var plotIndex = 0;
        for device in Constants.getDevicePriority {
            if (points.indexForKey(device) != nil) {
                let pointArray = points[device]!;
                var plot = CPTBarPlot(frame: CGRectZero);
                plot.lineStyle = nil;
                plot.cornerRadius = 5;
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
                    //we need this to know the value that the data label shows
                    var newVal = totalPlotPoints[index] + pointValue;
                    totalPlotPoints[index] = newVal;
                    if (newVal > maxPlotPoints) {
                        maxPlotPoints = newVal;
                    }
                }
                plotIndex++;
                lastDevice = device;
            }
        }
        
        var yAxisLabels:NewCPTAxisLabel;
        
        var yLabelValue = getNearestYLabel(maxPlotPoints);
        var label = NewCPTAxisLabel(text: String(yLabelValue), textStyle: xAxis.labelTextStyle);
        label.setTickIndex(Double(yLabelValue));
        dateLabels.append(label);
        yAxis.axisLabels = NSSet(array: [label]);

        plotSpace.xRange = NewCPTPlotRange(location: -1, length: 8);
        var a  = Double(maxPlotPoints) * 1.5;
        plotSpace.yRange = NewCPTPlotRange(location: 0, length: Double(maxPlotPoints) * 1.5);
        plotSpace.globalXRange = plotSpace.xRange;
        plotSpace.globalYRange = plotSpace.yRange;
    }
    
    func setUpAxes(labelStyle: CPTMutableTextStyle, xAxis: CPTAxis, yAxis: CPTAxis) {
        
    }
    
    func getNearestYLabel(points: Int) -> Int {
        var nearestValue = 0;
        if (points < 10) {
            nearestValue = 10;
        } else if (points < 100) {
            nearestValue = Int(points % 10) * 10;
        } else if (points < 500) {
            nearestValue = Int(points / 100) * 100;
        } else {
            nearestValue = Int(points / 500) * 500;
        }
        return nearestValue;
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
                for device in Constants.getDevicePriority {
                    if (points.indexForKey(device) != nil) {
                        let pointArray = points[device]!;
                        if (plot.name.isEqual(device)) {
                            break;
                        } else {
                            let val = pointArray[Int(idx)]
                            offset += pointArray[Int(idx)];
                        }
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
            var labelStyle = CPTMutableTextStyle();
            labelStyle.fontSize = 10;
            label.textStyle = labelStyle;
            
            plot.labelOffset = 0;
            return label;
        } else {
            return nil;
        }
    }
    
    func getDeviceColor(deviceName: String) -> CPTColor {
        var color:UIColor;
        if (SessionController.Instance.devices.indexForKey(deviceName) != nil) {
            color = Utility.colorFromHexString(SessionController.Instance.devices[deviceName]!.colorCode);
        } else if (deviceName == "higi") {
            color = Utility.colorFromHexString("#76C043");
        } else {
            color = UIColor.whiteColor();
        }
        return CPTColor(CGColor: color.CGColor);
    }
    
    func populateDates(mode: Mode) -> [String] {
        var dateFormatter = NSDateFormatter();
        var dateComponent = NSDateComponents();
        
        var todaysDate = NSDate();
        var dates:[String] = [];
        
        for index in 0...6 {
            var calendar = NSCalendar.currentCalendar();
            dateComponent.day = index - 6;
            if (mode == Mode.DAY) {
                dateFormatter.dateFormat = "E";
                dateComponent.day = index - 6;
            } else if (mode == Mode.WEEK) {
                dateFormatter.dateFormat = "MM/dd";
                dateComponent.day = (index - 6) * 7;
            } else {
                dateFormatter.dateFormat = "LLL";
                dateComponent.month = index - 6;
            }
            var nextDate = calendar.dateByAddingComponents(dateComponent, toDate: todaysDate, options: nil);
            dates.append(dateFormatter.stringFromDate(nextDate!));
        }
        
        return dates;
    }
}