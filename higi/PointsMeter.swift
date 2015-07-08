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

    private var combinedActivities: [(type: String, total: Int)] = [];
    
    private let animationDuration = 1.0;
    
    private var lineWidth, radius:CGFloat!;
    
    private var total = 0;
    
    private var targetFrame: CGRect?;
    
    private var activitiesByType:[String: (Int, [HigiActivity])] = [:];
    
    private var activityTypes: [String] = [];
    
    private var lightArc = false, thickArc = false;
    
    class func create() -> PointsMeter {
        return UINib(nibName: "PointsMeterView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! PointsMeter;
    }
    
    class func create(frame: CGRect) -> PointsMeter {
        let meter = UINib(nibName: "PointsMeterView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! PointsMeter;
        meter.frame = frame;
        meter.targetFrame = frame;
        if (frame.size.width < 50) {
            meter.points.font = UIFont.systemFontOfSize(12);
        }
        return meter;
    }
    
    class func create(frame: CGRect, thickArc: Bool) -> PointsMeter {
        let meter = create(frame);
        meter.thickArc = thickArc;
        return meter;
    }
    
    func setActivities(dailyActivity: (Int, [HigiActivity])) {
        (total, activities) = dailyActivity;
        lineWidth = self.frame.size.width * 0.06;
        if thickArc {
            lineWidth = lineWidth * 1.5;
        }
        radius = self.frame.size.width / 2 * 0.9 - (lineWidth / 2);
        var toPath = UIBezierPath();
        var arc = CAShapeLayer();
        arc.lineWidth = lineWidth;
        arc.fillColor = UIColor.clearColor().CGColor;
        if lightArc {
            arc.strokeColor = UIColor.whiteColor().CGColor;
        } else {
            arc.strokeColor = Utility.colorFromHexString("#EEEEEE").CGColor;
        }
        var center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2);
        toPath.addArcWithCenter(center, radius: radius, startAngle: CGFloat(0), endAngle: CGFloat(2 * M_PI), clockwise: true);
        toPath.closePath();
        arc.path = toPath.CGPath;
        self.meterContainer.layer.addSublayer(arc);
        self.points.text = "\(total)";
        activitiesByType.removeAll(keepCapacity: false);
        activityTypes.removeAll(keepCapacity: false);
        for activity in activities {
            let type = ActivityCategory.categoryFromActivity(activity).getString();
            if let (totalPoints, activityList) = activitiesByType[type] {
                var previousActivities = activityList;
                previousActivities.append(activity);
                var points = totalPoints;
                if (activity.points > 0 && activity.errorDescription == nil) {
                    points += activity.points!;
                }
                activitiesByType[type] = (points, previousActivities);
            } else {
                var points = 0;
                if (activity.points > 0 && activity.errorDescription == nil) {
                    points += activity.points!;
                }
                activitiesByType[type] = (points, [activity]);
                activityTypes.append(type);
            }
        }
    }
    
    func drawArc(animated: Bool) {
        var center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2);
        var lastEnd = 0.0;
        if (activitiesByType.count > 0) {
            total = max(total, 100);
            var firstActivity = true;
            var toPath = UIBezierPath();
            for type in activityTypes {
                let (points, activity) = activitiesByType[type]!;
                var arc = CAShapeLayer();
                arc.lineWidth = lineWidth;
                arc.fillColor = UIColor.clearColor().CGColor;
                arc.strokeColor = ActivityCategory.categoryFromString(type).getColor().CGColor;

                var increment = Double(points) / Double(total);
                if (firstActivity) {
                    var startAngle = M_PI / 2;
                    toPath.addArcWithCenter(center, radius: radius, startAngle: CGFloat(startAngle), endAngle: CGFloat(startAngle + 2 * M_PI), clockwise: true);
                    toPath.closePath();
                }
                arc.path = toPath.CGPath;
                self.meterContainer.layer.addSublayer(arc);

                if (animated) {
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
                } else {
                    var start = lastEnd;
                    arc.strokeStart = CGFloat(start);
                    arc.strokeEnd = CGFloat(start + increment + 0.01);
                }
                lastEnd += increment;
                firstActivity = false;
            }
        }
    }
    
    func setDarkText() {
        self.points.textColor = Utility.colorFromHexString("#444444");
    }
    
    func setLightText() {
        self.points.textColor = Utility.colorFromHexString("#FFFFFF");
    }
    
    func setLightArc() {
        lightArc = true;
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        if (targetFrame != nil) {
            points.frame.size.width = targetFrame!.size.width;
            points.center = CGPoint(x: targetFrame!.size.width / 2 , y: targetFrame!.size.height / 2);
            meterContainer.frame = targetFrame!;
            meterContainer.center = CGPoint(x: targetFrame!.size.width / 2 , y: targetFrame!.size.height / 2);
            layoutIfNeeded();
        }
    }
}