//
//  WeightMap.swift
//  higi
//
//  Created by Dan Harms on 6/24/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class WeightGraphDelegate: GraphDelegate {
    
    func getBackgroundColor() -> UIColor {
        return Utility.colorFromHexString("#EF6C56");
    }
    
    func createGraph(checkins: [HigiCheckin], isPortrait: Bool, frame: CGRect) -> BaseCustomGraphHostingView? {
        var xyPoints: [GraphPoint] = [];
        for checkin in checkins {
            xyPoints.append(GraphPoint(x: Double(checkin.dateTime.timeIntervalSince1970), y: Double(checkin.weightLbs!)));
        }
        return BaseCustomGraphHostingView(frame: frame, points: xyPoints, isPortrait: isPortrait);
    }
    
    func getHighlightString(checkin: HigiCheckin) -> String {
        return "\(Int(checkin.weightLbs!)) lbs - \(checkin.bmiClass!)";
    }
    
    func getTitle() -> String {
        return "Weight";
    }
    
    func getUnit() -> String {
        return "lbs";
    }
    
    func getMeasureValue(checkin: HigiCheckin) -> String {
        return "\(Int(checkin.weightLbs!))";
    }
    
    func getMeasureClass(checkin: HigiCheckin) -> String {
        return checkin.bmiClass!;
    }
    
    func cellForCheckin(checkin: HigiCheckin, cell: BodyStatCheckinCell) {
        var gauge = UIImage(named: "gauge3_normal.png");
        if (checkin.bmiClass == "Overweight") {
            gauge = UIImage(named: "gauge3_overweight.png");
        } else if (checkin.bmiClass == "Obese") {
            gauge = UIImage(named: "gauge3_obese.png");
        }
        cell.gauge.image = gauge;
    }
    
    func getInfoImage() -> UIImage {
        return UIImage(named: "weight_overlay.png")!;
    }
    
    func getScreenPoint(graph: CPTGraphHostingView, checkin: HigiCheckin, isPortrait: Bool) -> CGPoint {
        var xRange = (graph.hostedGraph.defaultPlotSpace as CPTXYPlotSpace).xRange;
        var yRange = (graph.hostedGraph.defaultPlotSpace as CPTXYPlotSpace).yRange;
        var frame = graph.frame;
        var dateX = CGFloat(checkin.dateTime.timeIntervalSince1970);
        var valueY = CGFloat(checkin.weightLbs!);
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