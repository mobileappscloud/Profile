//
//  PointMeter.swift
//  higi
//
//  Created by Dan Harms on 1/20/15.
//  Copyright (c) 2015 higi, LLC. All rights reserved.
//

import Foundation

class PointsMeter: UIView {
    
    @IBOutlet weak var meterContainer: UIView!
    @IBOutlet weak var points: UILabel!
    
    private var activities: [HigiActivity] = [];

    let animationDuration = 2.0;
    
    var lineWidth, radius:CGFloat!;
    
    var total = 0;
    
    var targetFrame: CGRect?;
    
    class func create() -> PointsMeter {
        return UINib(nibName: "PointsMeterView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! PointsMeter;
    }
    
    class func create(frame: CGRect) -> PointsMeter {
        let view = UINib(nibName: "PointsMeterView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! PointsMeter;
        view.frame = frame;
        view.targetFrame = frame;
        if (frame.size.width < 50) {
            view.points.font = UIFont.systemFontOfSize(12);
        }
        return view;
    }
    
    func setActivities(dailyActivity: (Int, [HigiActivity])) {
        (total, activities) = dailyActivity;
        lineWidth = self.frame.size.width * 0.06;
        radius = self.frame.size.width / 2 * 0.9;
        var toPath = UIBezierPath();
        var arc = CAShapeLayer();
        arc.lineWidth = lineWidth;
        arc.fillColor = UIColor.clearColor().CGColor;
        arc.strokeColor = UIColor.whiteColor().CGColor;
        toPath.addArcWithCenter(center, radius: radius, startAngle: CGFloat(0), endAngle: CGFloat(2 * M_PI), clockwise: true);
        toPath.closePath();
        arc.path = toPath.CGPath;
        self.meterContainer.layer.addSublayer(arc);
        self.points.text = "\(total)";
    }
    
    func drawArc() {
        var center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2);
        var lastEnd = 0.0;
        let a = self.frame;
        if (activities.count > 0) {
            total = max(total, 100);
            var firstActivity = true;
            var toPath = UIBezierPath();
            for activity in activities {
                var arc = CAShapeLayer();
                arc.lineWidth = lineWidth;
                arc.fillColor = UIColor.clearColor().CGColor;
                arc.strokeColor = Utility.colorFromHexString(activity.device.colorCode).CGColor;
                
                var increment = Double(activity.points) / Double(total);
                if (firstActivity) {
                    var startAngle = M_PI / 2;
                    toPath.addArcWithCenter(center, radius: radius, startAngle: CGFloat(startAngle), endAngle: CGFloat(startAngle + 2 * M_PI), clockwise: true);
                    toPath.closePath();
                }
                arc.path = toPath.CGPath;
                self.meterContainer.layer.addSublayer(arc);

                CATransaction.begin();
                CATransaction.setDisableActions(true);
                arc.strokeStart = CGFloat(0);
                arc.strokeEnd = CGFloat(0);
                CATransaction.setDisableActions(false);
                CATransaction.commit();
                
                var start = lastEnd;
                if (firstActivity) {
                    dispatch_async(dispatch_get_main_queue(), {
                        CATransaction.begin();
                        CATransaction.setAnimationDuration(self.animationDuration);
                        arc.strokeEnd = CGFloat(increment + 0.01);
                        CATransaction.commit();
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        CATransaction.begin();
                        CATransaction.setAnimationDuration(self.animationDuration);
                        arc.strokeStart = CGFloat(start);
                        arc.strokeEnd = CGFloat(start + increment + 0.01);
                        CATransaction.commit();
                    });
                }
                lastEnd += increment;
                firstActivity = false;
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        if (targetFrame != nil) {
            points.frame.size.width = targetFrame!.size.width;
            points.center = CGPoint(x: targetFrame!.size.width / 2 , y: targetFrame!.size.height / 2);
            meterContainer.frame = targetFrame!;
            layoutIfNeeded();
        }
    }
}