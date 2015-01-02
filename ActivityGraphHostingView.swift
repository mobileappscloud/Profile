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
        
        graph.paddingLeft = 0;
        graph.paddingTop = 0;
        graph.paddingRight = 0;
        graph.paddingBottom = 0;
        
        var plotSpace = graph.defaultPlotSpace as CPTXYPlotSpace;
        plotSpace.allowsUserInteraction = false;
        plotSpace.xRange = NewCPTPlotRange(location: -0.5, length: 8);
        plotSpace.yRange = NewCPTPlotRange(location: 0, length: 100);
        plotSpace.globalXRange = plotSpace.xRange;
        plotSpace.globalYRange = plotSpace.yRange;
        
        var firstPlot = true;
        for (device, pointArray) in points {
            var plot = CPTBarPlot(frame: CGRectZero);
            plot.fill = CPTFill(color: CPTColor(CGColor: UIColor.redColor().CGColor));
            plot.barWidthScale = 1;
            
            plot.barBasesVary = !firstPlot;
            firstPlot = false;
            
            plot.dataSource = self;
            plot.name = device;
            graph.addPlot(plot, toPlotSpace: plotSpace);
        }
    }
    
    func doubleForPlot(plot: CPTPlot!, field fieldEnum: UInt, recordIndex idx: UInt) -> Double {
        var test = points[plot.name]![Int(idx)];
        return 5;
//        return points[plot.name![Int(idx)]];
    }
    
    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt {
        return 7;
    }
    
}