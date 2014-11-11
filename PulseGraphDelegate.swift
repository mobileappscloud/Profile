//
//  PulseGraph.swift
//  higi
//
//  Created by Dan Harms on 6/24/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class PulseGraphDelegate: GraphDelegate {
    
    func getBackgroundColor() -> UIColor {
        return Utility.colorFromHexString("#5FB0E0");
    }
    
    func createGraph(checkins: [HigiCheckin], isPortrait: Bool, frame: CGRect) -> BaseCustomGraphHostingView? {
        var xyPoints: [GraphPoint] = [];
        for checkin in checkins {
            if (checkin.pulseBpm != nil) {
                xyPoints.append(GraphPoint(x: Double(checkin.dateTime.timeIntervalSince1970), y: Double(checkin.pulseBpm!)));
            }
        }
        return BaseCustomGraphHostingView(frame: frame, points: xyPoints, isPortrait: isPortrait);
    }
    
    func getHighlightString(checkin: HigiCheckin) -> String {
        return "\(checkin.pulseBpm!) bpm - \(checkin.pulseClass!)";
    }
    
    func getTitle() -> String {
        return "Pulse";
    }
    
    func getUnit() -> String {
        return "bpm";
    }
    
    func getMeasureValue(checkin: HigiCheckin) -> String {
        if (checkin.pulseBpm != nil) {
            return "\(checkin.pulseBpm!)";
        } else {
            return "";
        }
    }
    
    func getMeasureClass(checkin: HigiCheckin) -> String {
        return checkin.pulseClass!;
    }
    
    func cellForCheckin(checkin: HigiCheckin, cell: BodyStatCheckinCell) {
        var gauge = UIImage(named: "gauge1_normal.png")
        if (checkin.pulseClass == "Low") {
            gauge = UIImage(named: "gauge1_low.png")
        } else if (checkin.pulseClass == "High") {
            gauge = UIImage(named: "gauge1_high.png")
        }
        cell.gauge.image = gauge;
    }
    
    func getInfoImage() -> UIImage {
        return UIImage(named: "pulse_overlay.png")!;
    }
    
    func getScreenPoint(graph: CPTGraphHostingView, checkin: HigiCheckin, isPortrait: Bool) -> CGPoint {
        var xRange = (graph.hostedGraph.defaultPlotSpace as CPTXYPlotSpace).xRange;
        var yRange = (graph.hostedGraph.defaultPlotSpace as CPTXYPlotSpace).yRange;
        var frame = graph.frame;
        var dateX = CGFloat(checkin.dateTime.timeIntervalSince1970);
        var valueY = CGFloat(checkin.pulseBpm!);
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