//
//  BpGraph.swift
//  higi
//
//  Created by Dan Harms on 7/23/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class BpGraphDelegate: GraphDelegate {

    
    func getBackgroundColor() -> UIColor {
        return Utility.colorFromHexString("#8478C2");
    }
    
    func createGraph(checkins: [HigiCheckin], isPortrait: Bool, frame: CGRect)  -> BaseCustomGraphHostingView? {
        var xyPoints: [GraphPoint] = [];
        var diastolicPoints: [GraphPoint] = [];
        for checkin in checkins {
            xyPoints.append(GraphPoint(x: Double(checkin.dateTime.timeIntervalSince1970), y: Double(checkin.systolic!)));
            diastolicPoints.append(GraphPoint(x: Double(checkin.dateTime.timeIntervalSince1970), y: Double(checkin.diastolic!)));
        }
        return BpGraphHostingView(frame: frame, systolicPoints: xyPoints, diastolicPoints: diastolicPoints, isPortrait: isPortrait);
    }
    
    func getHighlightString(checkin: HigiCheckin) -> String {
        return "\(checkin.systolic!)/\(checkin.diastolic!) mm Hg - \(checkin.bpClass!)";
    }
    
    func getTitle() -> String {
        return "Blood Pressure";
    }
    
    func getUnit() -> String {
        return "mm Hg";
    }
    
    func getMeasureValue(checkin: HigiCheckin) -> String {
        return "\(checkin.systolic!)/\(checkin.diastolic!)";
    }
    
    func getMeasureClass(checkin: HigiCheckin) -> String {
        return checkin.bpClass! as String;
    }
    
    func cellForCheckin(checkin: HigiCheckin, cell: BodyStatCheckinCell) {
        var gauge = UIImage(named: "gauge2_normal.png");
        if (checkin.bpClass == "At Risk") {
            gauge = UIImage(named: "gauge2_atrisk.png");
        } else if (checkin.bpClass == "High") {
            gauge = UIImage(named: "gauge2_high.png");
        }
        cell.gauge.image = gauge;
        cell.measureValue.hidden = true;
        cell.bpMeasures.hidden = false;
        cell.systolic.text = "\(checkin.systolic!)";
        cell.diastolic.text = "\(checkin.diastolic!)";
    }
    
    func getInfoImage() -> UIImage {
        return UIImage(named: "bp_overlay.png")!;
    }
    
    func getScreenPoint(graph: CPTGraphHostingView, checkin: HigiCheckin, isPortrait: Bool) -> CGPoint {
        var xRange = (graph.hostedGraph.defaultPlotSpace as! CPTXYPlotSpace).xRange;
        var yRange = (graph.hostedGraph.defaultPlotSpace as! CPTXYPlotSpace).yRange;
        var frame = graph.frame;
        var dateX = CGFloat(checkin.dateTime.timeIntervalSince1970);
        var valueY = CGFloat(checkin.systolic!);
        var x = ((dateX - CGFloat(xRange.locationDouble)) / CGFloat(xRange.lengthDouble)) * frame.size.width;
        var y = (1.0 - ((valueY - CGFloat(yRange.locationDouble)) / CGFloat(yRange.lengthDouble))) * (frame.size.height - 30);
        if (!isPortrait) {
            y -= 55;
        }
        return CGPoint(x: x, y: y);
    }
    
    func getScreenPoint2(graph: CPTGraphHostingView, checkin: HigiCheckin, isPortrait: Bool) -> CGPoint? {
        var xRange = (graph.hostedGraph.defaultPlotSpace as! CPTXYPlotSpace).xRange;
        var yRange = (graph.hostedGraph.defaultPlotSpace as! CPTXYPlotSpace).yRange;
        var frame = graph.frame;
        var dateX = CGFloat(checkin.dateTime.timeIntervalSince1970);
        var valueY = CGFloat(checkin.diastolic!);
        var x = ((dateX - CGFloat(xRange.locationDouble)) / CGFloat(xRange.lengthDouble)) * frame.size.width;
        var y = (1.0 - ((valueY - CGFloat(yRange.locationDouble)) / CGFloat(yRange.lengthDouble))) * (frame.size.height - 30);
        if (!isPortrait) {
            y -= 55;
        }
        return CGPoint(x: x, y: y);
    }
    
}