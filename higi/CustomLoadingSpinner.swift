import Foundation
import QuartzCore

class CustomLoadingSpinner: UIView {
    
    private let duration:CFTimeInterval = 1;
    
    private var lineWidth:CGFloat = 0, maxLineWidth:CGFloat = 0, startingStrokeStart:CGFloat = 0, outerRadius: CGFloat = 0, strokeStart:CGFloat = 0, lastRotation: CGFloat = 0, minSweep: CGFloat = 0.2, radius:CGFloat = 0, rotation: CGFloat = 0;
    
    private var progressLayer: CAShapeLayer!;
    
    internal var shouldAnimate = true, shouldAnimateFull = true;

    private var centerPoint:CGPoint!;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        centerPoint = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)

        radius = (min(frame.size.width, frame.size.height) / 2) - maxLineWidth;
        maxLineWidth = min(frame.size.width, frame.size.height) * 0.1;
        
        progressLayer = CAShapeLayer();
        progressLayer.path = UIBezierPath(arcCenter: centerPoint, radius: 0, startAngle: 0, endAngle: CGFloat(CGFloat(M_PI * 2)), clockwise: true).CGPath;
        progressLayer.strokeColor = Utility.colorFromHexString(Constants.higiGreen).CGColor;
        progressLayer.anchorPoint = centerPoint;
        progressLayer.fillColor = UIColor.clearColor().CGColor;
        
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5);
        layer.addSublayer(progressLayer);
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createInstance() ->  CustomLoadingSpinner {
        return UINib(nibName: "CustomSpinner", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! CustomLoadingSpinner;
    }
    
    func startAnimating() {
        shouldAnimate = true;
        var phase = 0;
        if (!shouldAnimateFull) {
            phase = 2;
            progressLayer.path = UIBezierPath(arcCenter: self.centerPoint, radius: radius, startAngle: 0, endAngle: CGFloat(CGFloat(M_PI * 2)), clockwise: true).CGPath;
            lineWidth = radius * 0.2;
            outerRadius = radius + self.lineWidth / 2
        }
        let durations = [duration, duration / 2 , duration, duration * 2];

        let startTime = NSDate();
        var phaseStartTime = startTime;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            while (true) {
                let currentTime = NSDate();
                if (currentTime.timeIntervalSinceDate(phaseStartTime) > durations[phase]) {
                    phaseStartTime = currentTime;
                    phase++;
                    self.startingStrokeStart = self.strokeStart;
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
                self.lastRotation = self.rotation;
                self.rotation = ((CGFloat(currentTime.timeIntervalSinceDate(startTime)) % 2) / CGFloat(2)) * CGFloat(M_PI * 2);
                switch phase {
                case 0:
                    self.growOutsideAnimation(drawPercent);
                case 1:
                    self.growInsideAnimation(drawPercent);
                case 2:
                    self.shrinkArcAnimation(drawPercent);
                case 3:
                    self.growArcAnimation(drawPercent);
                    self.rotation += CGFloat(drawPercent * CGFloat(M_PI * 2));
                default:
                    let i = 0;
                }
                self.rotateAnimation();
                let path = UIBezierPath(arcCenter: self.centerPoint, radius: self.outerRadius - self.lineWidth / 2, startAngle: 0, endAngle: CGFloat(CGFloat(M_PI * 2)), clockwise: true).CGPath;
                
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
        if (self.rotation - self.lastRotation > 0) {
            dispatch_async(dispatch_get_main_queue(), {
                CATransaction.begin();
                CATransaction.setDisableActions(true);
                self.layer.transform = CATransform3DRotate(self.layer.transform, self.rotation - self.lastRotation, 0, 0, 1);
                CATransaction.setDisableActions(false);
                CATransaction.commit();
            });
        }
    }
    
    func growArcAnimation(drawPercent: CGFloat) {
        strokeStart = startingStrokeStart - (startingStrokeStart - minSweep) * drawPercent;
    }
    
    func shrinkArcAnimation(drawPercent: CGFloat) {
        strokeStart = startingStrokeStart + (1 - minSweep - startingStrokeStart) * drawPercent;
    }

    func growOutsideAnimation(drawPercent: CGFloat) {
        self.lineWidth = radius * drawPercent;
        self.outerRadius = radius * drawPercent;
    }

    func growInsideAnimation(drawPercent: CGFloat) {
        self.lineWidth = (radius - (radius * 0.8) * drawPercent);
    }

    func stopAnimating() {
        shouldAnimate = false;
    }
    
    func isAnimating() -> Bool {
        return shouldAnimate;
    }
}