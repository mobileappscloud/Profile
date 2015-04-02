import Foundation
import QuartzCore

class CustomLoadingSpinner: UIView {
    
    let duration:CFTimeInterval = 1;
    let lineWidth:CGFloat = 3;
    let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut);
    var progressLayer: CAShapeLayer!;
    
    var shouldAnimate = true;
    
    var radius:CGFloat!;
    var centerPoint:CGPoint!;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        var centerCoord:CGFloat = min(frame.size.width, frame.size.height) / 2;
        centerPoint = CGPoint(x: centerCoord, y: centerCoord)
        radius = centerCoord * 0.9 - lineWidth;
        
        let progressPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: 0, endAngle: CGFloat(CGFloat(M_PI * 2)), clockwise: true);
        
        progressLayer = CAShapeLayer();
//        progressLayer.path = createPathRotatedAroundBoundingBoxCenter(progressPath.CGPath, radians: CGFloat(M_PI));
        progressLayer.path = progressPath.CGPath;
        progressLayer.fillColor = UIColor.clearColor().CGColor;
        progressLayer.strokeColor = Utility.colorFromHexString("#76C043").CGColor;
        progressLayer.lineWidth = lineWidth;
        progressLayer.anchorPoint = centerPoint;
        
//        layer.anchorPoint = centerPoint;

        slowSpinAnimation();
        
//        UIView.animateWithDuration(duration * 4, delay: 0, options: .CurveLinear | .Repeat, animations: {
//            self.transform = CGAffineTransformRotate(self.transform, CGFloat(M_PI));
//            }, completion: nil);
//        
//        progressLayer.transform = CATransform3DRotate(progressLayer.transform, CGFloat(M_PI), centerCoord, centerCoord, 1);
        
        layer.addSublayer(progressLayer);
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createInstance() ->  CustomLoadingSpinner {
        return UINib(nibName: "CustomSpinner", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as CustomLoadingSpinner;
    }
    
    func slowSpinAnimation() {
        CATransaction.begin();
        
        let slowSpin = CABasicAnimation(keyPath: "transform.rotation.z");
        slowSpin.duration = duration;
        slowSpin.fromValue = 0;
        slowSpin.toValue = CGFloat(M_PI / 2);
        slowSpin.cumulative = true;
        slowSpin.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear);
        
        CATransaction.setCompletionBlock({
            self.fastSpinAnimation();
        });
        
        layer.addAnimation(slowSpin, forKey: nil);

        CATransaction.commit();
    }
    
    func fastSpinAnimation() {
        CATransaction.begin();
        
        let fastSpin = CABasicAnimation(keyPath: "transform.rotation");
        fastSpin.duration = duration;
        fastSpin.fromValue = CGFloat(M_PI / 2);
        fastSpin.toValue = CGFloat(M_PI);
        fastSpin.timingFunction = timingFunction;

        CATransaction.setCompletionBlock({
            self.slowSpinAnimation();
        });
        
        layer.addAnimation(fastSpin, forKey: nil);
        
        CATransaction.commit();
    }
    
    func startAnimation() {
        let growAnimationPath = CABasicAnimation(keyPath: "path");
        growAnimationPath.fromValue = UIBezierPath(arcCenter: centerPoint, radius: 0, startAngle: 0, endAngle: CGFloat(CGFloat(M_PI * 2)), clockwise: true).CGPath;
        growAnimationPath.toValue = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: 0, endAngle: CGFloat(CGFloat(M_PI * 2)), clockwise: true).CGPath;
        growAnimationPath.timingFunction = timingFunction;

        let growAnimationBounds = CABasicAnimation(keyPath: "bounds");
        growAnimationBounds.toValue = NSValue(CGRect: CGRectMake(0, 0, radius, radius));
        
        let strokeDuration = duration;
        let strokeAnimation = CABasicAnimation(keyPath: "lineWidth");
        strokeAnimation.duration = duration;
        strokeAnimation.fromValue = 8;
        strokeAnimation.toValue = 3;
        strokeAnimation.timingFunction = timingFunction;
        strokeAnimation.timeOffset = strokeDuration;
        
        let growAnimationGroup = CAAnimationGroup();
        growAnimationGroup.animations = [growAnimationPath, growAnimationBounds, strokeAnimation];
        growAnimationGroup.duration = duration;
        
        CATransaction.begin();
        
        CATransaction.setCompletionBlock({
            self.progressLayer.fillColor = UIColor.clearColor().CGColor;
            self.progressLayer.strokeStart = 0.9;
            self.spinAnimation();
        });
        
        progressLayer.addAnimation(growAnimationGroup, forKey: "grow");
        
        CATransaction.commit();
    }
    
    func stopAnimation() {
        shouldAnimate = false;
    }
    
    func spinAnimation() {
        if (shouldAnimate) {
            
            CATransaction.begin();
            
            let shrinkAnimation = CABasicAnimation(keyPath: "strokeStart");
            shrinkAnimation.duration = duration;
            shrinkAnimation.fromValue = 0.1;
            shrinkAnimation.toValue = 0.9;
            shrinkAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut);
            
            let transformAnimation = CABasicAnimation(keyPath: "transform.rotation");
            transformAnimation.duration = duration;
            transformAnimation.fromValue = 0;
            transformAnimation.toValue = CGFloat(M_PI * 2);
            transformAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear);
            
            let shrinkAnimationGroup = CAAnimationGroup();
            shrinkAnimationGroup.animations = [shrinkAnimation];
            shrinkAnimationGroup.duration = self.duration;
            shrinkAnimationGroup.removedOnCompletion = false;
            
            CATransaction.setCompletionBlock({
                let growAnimation = CABasicAnimation(keyPath: "strokeStart");
                growAnimation.duration = self.duration;
                growAnimation.fromValue = 0.9;
                growAnimation.toValue = 0.1;
                growAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut);

                let fasterSpinAnimation = CABasicAnimation(keyPath: "transform.rotation");
                fasterSpinAnimation.duration = self.duration;
                fasterSpinAnimation.fromValue = 0;
                fasterSpinAnimation.toValue = CGFloat(M_PI * 2);
                fasterSpinAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut);
                
                let growAnimationGroup = CAAnimationGroup();
                growAnimationGroup.animations = [growAnimation];
                growAnimationGroup.duration = self.duration;
                growAnimationGroup.removedOnCompletion = false;

                CATransaction.begin();

                CATransaction.setCompletionBlock({
                    self.spinAnimation();
                });

                self.progressLayer.addAnimation(growAnimationGroup, forKey: nil);

                CATransaction.commit();
            });
            
            progressLayer.addAnimation(shrinkAnimationGroup, forKey: nil);
            
            CATransaction.commit();
        }
    }
    
    func createPathRotatedAroundBoundingBoxCenter(path: CGPathRef, radians: CGFloat) -> CGPathRef {
        var bounds = CGPathGetBoundingBox(path);
        var center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
        var transform = CGAffineTransformIdentity;
        transform = CGAffineTransformTranslate(transform, center.x, center.y);
        transform = CGAffineTransformRotate(transform, radians);
        transform = CGAffineTransformTranslate(transform, -center.x, -center.y);
        return CGPathCreateCopyByTransformingPath(path, &transform);
    }
    
    func isAnimating() -> Bool {
        return shouldAnimate;
    }
}