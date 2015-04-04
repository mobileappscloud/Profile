import Foundation
import QuartzCore

class CustomLoadingSpinner: UIView {
    
    let duration:CFTimeInterval = 1;
    
    let lineWidth:CGFloat = 3;
    
    let easingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut);
    
    let linearFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear);
    
    var progressLayer: CAShapeLayer!;
    
    var shouldAnimate = true;
    
    var radius:CGFloat!;
    
    var centerPoint:CGPoint!;
    
    var strokeVal:CGFloat = 0.9;
    
    var spinVal = CGFloat(M_PI);
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        var centerCoord:CGFloat = min(frame.size.width, frame.size.height) / 2;
        centerPoint = CGPoint(x: centerCoord, y: centerCoord)
        radius = centerCoord * 0.9 - lineWidth;
        
        progressLayer = CAShapeLayer();
        progressLayer.path = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: 0, endAngle: CGFloat(CGFloat(M_PI * 2)), clockwise: true).CGPath;
        progressLayer.fillColor = UIColor.clearColor().CGColor;
        progressLayer.strokeColor = Utility.colorFromHexString("#76C043").CGColor;
        progressLayer.lineWidth = lineWidth;
        progressLayer.anchorPoint = centerPoint;
        progressLayer.strokeStart = 0.3;
        
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5);
//        UIView.animateWithDuration(duration * 2, delay: 0, options: .CurveLinear | .Repeat, animations: {
//            self.transform = CGAffineTransformRotate(self.transform, CGFloat(M_PI * 3));
//            }, completion: nil);

//        startSlowSpin();
        
        layer.addSublayer(progressLayer);
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createInstance() ->  CustomLoadingSpinner {
        return UINib(nibName: "CustomSpinner", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as CustomLoadingSpinner;
    }

    func startSlowSpin() {
        let slowSpin = CABasicAnimation(keyPath: "transform.rotation");
        slowSpin.duration = duration * 2;
        slowSpin.fromValue = 0;
        slowSpin.toValue = CGFloat(M_PI * 2);
        slowSpin.timingFunction = linearFunction;
        slowSpin.repeatDuration = CFTimeInterval.infinity;
        layer.addAnimation(slowSpin, forKey: "slowSpin");
    }
    
    func startAnimating() {
        var phase = 0;
        var angle:CGFloat = CGFloat(M_PI);
        var startingAngle:CGFloat = 0;
        let durations = [duration * 1000, duration / 2 * 1000, duration * 1000, duration * 2 * 1000];
//        CATransaction.begin();
//        CATransaction.setDisableActions(true);
//        self.progressLayer.strokeStart = 0.9;
//        CATransaction.setDisableActions(false);
//        CATransaction.commit();
        
        let startTime = NSDate();
        var phaseStartTime = startTime;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            while (true) {
                let currentTime = NSDate();
                if (currentTime.timeIntervalSinceDate(phaseStartTime) * 1000 > durations[phase]) {
                    phaseStartTime = currentTime;
                    phase++;
                    startingAngle = angle;
                    if (phase > 3) {
                        phase = 2;
                    }
                }
                var easing:CGFloat = (CGFloat(currentTime.timeIntervalSinceDate(phaseStartTime)) * 1000) / CGFloat(durations[phase] / 2);
                var drawPercent:CGFloat = 0;
                if (easing < 1) {
                    drawPercent = 0.5 * CGFloat(pow(easing, 3));
                } else {
                    easing -= 2;
                    drawPercent = 0.5 * CGFloat(pow(easing, 3) + 2);
                }
                let a = (CGFloat(currentTime.timeIntervalSinceDate(phaseStartTime)) * 1000);
                let b = ((CGFloat(currentTime.timeIntervalSinceDate(phaseStartTime)) * 1000) % 2000);
                let c = 2000 * 360;
                let d = ((CGFloat(currentTime.timeIntervalSinceDate(phaseStartTime)) * 1000) % 2000) / (2000 * 360)
                self.spinVal = ((CGFloat(currentTime.timeIntervalSinceDate(phaseStartTime)) * 1000) % 2000) / (2000 * 360);
                switch phase {
                case 0:
                    self.growOutsideAnimation(drawPercent);
                case 1:
                    self.growInsideAnimation(drawPercent);
                case 2:
                    self.shrinkArcAnimation(drawPercent);
                case 3:
                    self.growArcAnimation(drawPercent);
                default:
                    let i = 0;
                }
//                self.rotateLayer();
                NSThread.sleepForTimeInterval(0.01);
                if (!self.shouldAnimate) {
                    break;
                }
            }
        });
    }
    
//    func rotateLayer() {
//        dispatch_async(dispatch_get_main_queue(), {
//            CATransaction.begin();
//            CATransaction.setDisableActions(true);
//            self.progressLayer.transform = CATransform3DRotate(self.progressLayer.transform, CGFloat(self.spinVal * M_PI), self.centerPoint.x, self.centerPoint.y, 1);
//            CATransaction.setDisableActions(false);
//            CATransaction.commit();
//        });
//    }
    
    func growArcAnimation(drawPercent: CGFloat) {
        dispatch_async(dispatch_get_main_queue(), {
            CATransaction.begin();
            CATransaction.setDisableActions(true);
            self.progressLayer.strokeStart = 1 - max(0.1, min(drawPercent, 0.9));
            CATransaction.setDisableActions(false);
            CATransaction.commit();
        });
    }
    
    func shrinkArcAnimation(drawPercent: CGFloat) {
        dispatch_async(dispatch_get_main_queue(), {
            CATransaction.begin();
            CATransaction.setDisableActions(true);
            self.progressLayer.strokeStart = max(0.1, min(drawPercent, 0.9));
            CATransaction.setDisableActions(false);
            CATransaction.commit();
        });
    }
    
    func growOutsideAnimation(drawPercent: CGFloat) {

    }
    
    func growInsideAnimation(drawPercent: CGFloat) {

    }
    
    func stopAnimating() {
        shouldAnimate = false;
    }
    
    func isAnimating() -> Bool {
        return shouldAnimate;
    }
}