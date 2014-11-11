//
//  MapGraph.swift
//  higi
//
//  Created by Dan Harms on 6/24/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class MapGraphDelegate: GraphDelegate {
    
    func getBackgroundColor() -> UIColor {
        return Utility.colorFromHexString("#4CA156");
    }
    
    func createGraph(checkins: [HigiCheckin], isPortrait: Bool, frame: CGRect) -> BaseCustomGraphHostingView? {
        var xyPoints: [GraphPoint] = [];
        for checkin in checkins {
            xyPoints.append(GraphPoint(x: Double(checkin.dateTime.timeIntervalSince1970), y: Double(checkin.map!)));
        }
        return BaseCustomGraphHostingView(frame: frame, points: xyPoints, isPortrait: isPortrait);
    }
    
    func getHighlightString(checkin: HigiCheckin) -> String {
        var formatted = String(format: "%.1f", checkin.map!);
        return "\(formatted) mm Hg - \(checkin.bpClass!)";
    }
    
    func getTitle() -> String {
        return "Mean Arterial Pressure";
    }
    
    func getUnit() -> String {
        return "mm Hg";
    }
    
    func getMeasureValue(checkin: HigiCheckin) -> String {
        return String(format: "%.1f", checkin.map!);
    }
    
    func getMeasureClass(checkin: HigiCheckin) -> String {
        return checkin.bpClass!;
    }
    
    func cellForCheckin(checkin: HigiCheckin, cell: BodyStatCheckinCell) {
        var gauge = UIImage(named: "gauge2_normal.png");
        if (checkin.bpClass == "At Risk") {
            gauge = UIImage(named: "gauge2_atrisk.png");
        } else if (checkin.bpClass == "High") {
            gauge = UIImage(named: "gauge2_high.png");
        }
        cell.gauge.image = gauge;
    }
    
    func getInfoImage() -> UIImage {
        return UIImage(named: "map_overlay.png")!;
    }
    
    func getScreenPoint(graph: CPTGraphHostingView, checkin: HigiCheckin, isPortrait: Bool) -> CGPoint {
        var xRange = (graph.hostedGraph.defaultPlotSpace as CPTXYPlotSpace).xRange;
        var yRange = (graph.hostedGraph.defaultPlotSpace as CPTXYPlotSpace).yRange;
        var frame = graph.frame;
        var dateX = CGFloat(checkin.dateTime.timeIntervalSince1970);
        var valueY = CGFloat(checkin.map!);
        var x = ((dateX - CGFloat(xRange.locationDouble)) / CGFloat(xRange.lengthDouble)) * frame.size.width;
        var y = (1.0 - ((valueY - CGFloat(yRange.locationDouble)) / CGFloat(yRange.lengthDouble))) * (frame.size.height - 30);
        if (!isPortrait) {
            y -= 55;
        }
        return CGPoint(x: x, y: y);
    }
    
    func getScreenPoint2(graph: CPTGraphHostingView, checkin: HigiCheckin, isPortrait: Bool) -> CGPoint? {
        return nil;
    }
}