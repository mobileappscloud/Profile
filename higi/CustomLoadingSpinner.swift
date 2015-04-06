import Foundation
import QuartzCore

class CustomLoadingSpinner: UIView {
    
    let duration:CFTimeInterval = 1;
    
    let lineWidth:CGFloat = 0;
    
    let maxLineWidth:CGFloat = 10;
    
    let easingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut);
    
    let linearFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear);
    
    var progressLayer: CAShapeLayer!;
    
    var shouldAnimate = true;
    
    var radius:CGFloat!;
    
    var outerRadius: CGFloat = 0;
    
    var centerPoint:CGPoint!;
    
    var strokeStart:CGFloat = 0;
    
    var spinVal: CGFloat = 0;
    
    var lastSpinVal: CGFloat = 0;
    
    var linearEasing:CGFloat = 0;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        var centerCoord:CGFloat = min(frame.size.width, frame.size.height) / 2;
        centerPoint = CGPoint(x: centerCoord, y: centerCoord)
        
        radius = centerCoord * 0.9 - lineWidth;
        
        progressLayer = CAShapeLayer();
        progressLayer.path = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: 0, endAngle: CGFloat(CGFloat(M_PI * 2)), clockwise: true).CGPath;

        progressLayer.strokeColor = Utility.colorFromHexString("#76C043").CGColor;
        progressLayer.anchorPoint = centerPoint;
        
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5);
        
        layer.addSublayer(progressLayer);
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createInstance() ->  CustomLoadingSpinner {
        return UINib(nibName: "CustomSpinner", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as CustomLoadingSpinner;
    }
    
    func startAnimating() {
        var phase = 0;
        var angle:CGFloat = CGFloat(M_PI);
        var startingAngle:CGFloat = 0;
        let durations = [duration, duration / 2 , duration * 2, duration];

        let startTime = NSDate();
        var phaseStartTime = startTime;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            while (true) {
                let currentTime = NSDate();
                if (currentTime.timeIntervalSinceDate(phaseStartTime) > durations[phase]) {
                    phaseStartTime = currentTime;
                    phase++;
                    startingAngle = angle;
                    if (phase > 3) {
                        phase = 2;
                    }
                    if (phase == 1) {
                        self.progressLayer.fillColor = UIColor.clearColor().CGColor;
                    }
                }
                var easing:CGFloat = (CGFloat(currentTime.timeIntervalSinceDate(phaseStartTime))) / CGFloat(durations[phase] / 2);

                var drawPercent:CGFloat = 0;
                if (easing < 1) {
                    drawPercent = 0.5 * CGFloat(pow(easing, 3));
                } else {
                    easing -= 2;
                    drawPercent = 0.5 * CGFloat(pow(easing, 3) + 2);
                }
                self.lastSpinVal = self.spinVal;
                self.spinVal = ((CGFloat(currentTime.timeIntervalSinceDate(startTime)) % 2) / CGFloat(2)) * CGFloat(M_PI * 2);
                switch phase {
                case 0:
                    self.growOutsideAnimation(drawPercent);
                case 1:
                    self.growInsideAnimation(drawPercent);
                case 2:
                    self.shrinkArcAnimation(drawPercent);
                case 3:
                    self.growArcAnimation(drawPercent);
                    self.spinVal += CGFloat(drawPercent * CGFloat(M_PI * 2));
                default:
                    let i = 0;
                }
                self.rotateAnimation();
                let path = UIBezierPath(arcCenter: self.centerPoint, radius: self.radius, startAngle: 0, endAngle: CGFloat(CGFloat(M_PI * 2)), clockwise: true).CGPath;
                dispatch_async(dispatch_get_main_queue(), {
                    CATransaction.begin();
                    CATransaction.setDisableActions(true);
                    self.progressLayer.lineWidth = self.lineWidth;
                    self.progressLayer.path = path;
                    self.progressLayer.strokeStart = self.strokeStart;
                    CATransaction.setDisableActions(false);
                    CATransaction.commit();
                });
                if (!self.shouldAnimate) {
                    break;
                }
                NSThread.sleepForTimeInterval(0.01);
                if (!self.shouldAnimate) {
                    break;
                }
            }
        });
    }

    func rotateAnimation() {
        //exclude big negative vals
        if (self.spinVal - self.lastSpinVal > 0) {
            dispatch_async(dispatch_get_main_queue(), {
                CATransaction.begin();
                CATransaction.setDisableActions(true);
                self.layer.transform = CATransform3DRotate(self.layer.transform, self.spinVal - self.lastSpinVal, 0, 0, 1);
                CATransaction.setDisableActions(false);
                CATransaction.commit();
            });
        }
    }
    
    func growArcAnimation(drawPercent: CGFloat) {
        self.strokeStart = 1 - max(0.2, min(drawPercent, 0.8));
    }
    
    func shrinkArcAnimation(drawPercent: CGFloat) {
        self.strokeStart = max(0.2, min(drawPercent, 0.8));
    }

    func growOutsideAnimation(drawPercent: CGFloat) {
        self.outerRadius = radius * drawPercent;
        let path = UIBezierPath(arcCenter: centerPoint, radius: growRadius, startAngle: 0, endAngle: CGFloat(CGFloat(M_PI * 2)), clockwise: true).CGPath;
        dispatch_async(dispatch_get_main_queue(), {
            CATransaction.begin();
            CATransaction.setDisableActions(true);
            self.progressLayer.path = path;
            self.progressLayer.lineWidth = growRadius;
            CATransaction.setDisableActions(false);
            CATransaction.commit();
        });
    }
    
    func growInsideAnimation(drawPercent: CGFloat) {
        let innerWidth = lineWidth + ((startValue * 2) - ((startValue * 2) * max(0, min(drawPercent, 1))));
        let growRadius = radius - (startValue - (startValue  * max(0, min(drawPercent, 1))));
        let path = UIBezierPath(arcCenter: centerPoint, radius: growRadius, startAngle: 0, endAngle: CGFloat(CGFloat(M_PI * 2)), clockwise: true).CGPath;
        
        NSLog("value: %f", Float(growRadius));
        
        dispatch_async(dispatch_get_main_queue(), {
            CATransaction.begin();
            CATransaction.setDisableActions(true);
            self.progressLayer.lineWidth = innerWidth;
            self.progressLayer.path = path;
            CATransaction.setDisableActions(false);
            CATransaction.commit();
        });
    }

    func stopAnimating() {
        shouldAnimate = false;
    }
    
    func isAnimating() -> Bool {
        return shouldAnimate;
    }
}