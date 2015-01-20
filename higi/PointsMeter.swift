//
//  PointMeter.swift
//  higi
//
//  Created by Dan Harms on 1/20/15.
//  Copyright (c) 2015 higi, LLC. All rights reserved.
//

import Foundation

class PointsMeter: UIView {
    
    @IBOutlet weak var points: UILabel!
    
    var activities: [HigiActivity] = [];
    
    func drawArc() {
        var total = 0;
        var center = CGPoint(x: 50.0, y: 50.0);
        var radius: CGFloat = 44.0;
        var lastEnd = 0.0;
        if (activities.count > 0) {
            for activity in activities {
                total += activity.points;
                var toPath = UIBezierPath();
                var arc = CAShapeLayer();
                arc.lineWidth = 12;
                arc.fillColor = UIColor.clearColor().CGColor;
                arc.strokeColor = Utility.colorFromHexString(activity.device.colorCode).CGColor;
                
                var increment = Double(activity.points) / Double(total);
                var startingPoint = CGPoint(x: center.x + radius * CGFloat(cos(lastEnd * 2 * M_PI)), y: center.y + radius * CGFloat(sin(lastEnd * 2 * M_PI)));
                toPath.moveToPoint(startingPoint);
                var startAngle = lastEnd * 2 * M_PI;
                toPath.addArcWithCenter(center, radius: radius, startAngle: CGFloat(startAngle), endAngle: CGFloat(startAngle + 2 * M_PI), clockwise: true);
                toPath.closePath();
                
                arc.path = toPath.CGPath;
                self.layer.addSublayer(arc);
                
                CATransaction.begin();
                CATransaction.setDisableActions(true);
                arc.strokeStart = CGFloat(0);
                arc.strokeEnd = CGFloat(0);
                CATransaction.setDisableActions(false);
                CATransaction.commit();
                dispatch_async(dispatch_get_main_queue(), {
                    CATransaction.begin();
                    CATransaction.setAnimationDuration(1.0);
                    arc.strokeEnd = CGFloat(increment + 0.01);
                    CATransaction.commit();
                });
                lastEnd += increment;
            }
        } else {
            var arc = CAShapeLayer();
            arc.lineWidth = 12;
            arc.fillColor = UIColor.whiteColor().CGColor;
            arc.strokeColor = Utility.colorFromHexString("#DDDDDD").CGColor;
            var toPath = UIBezierPath();
            var startingPoint = CGPoint(x: center.x, y: center.y + radius);
            toPath.moveToPoint(startingPoint);
            toPath.addArcWithCenter(center, radius: radius, startAngle: CGFloat(M_PI_2), endAngle: CGFloat(5 * M_PI_2), clockwise: true);
            toPath.closePath();
            
            arc.path = toPath.CGPath;
            self.layer.addSublayer(arc);
            CATransaction.begin();
            CATransaction.setDisableActions(true);
            arc.strokeStart = 0.0;
            arc.strokeEnd = 1.0;
            CATransaction.setDisableActions(false);
            CATransaction.commit();
        }
        
        self.points.text = "\(total)";
    }
}