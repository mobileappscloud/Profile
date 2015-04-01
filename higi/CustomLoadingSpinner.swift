import Foundation

class CustomLoadingSpinner: UIView {
    
    let duration:CFTimeInterval = 1;
    let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut);
    var progressLayer: CAShapeLayer!;
    
    var shouldAnimate = true;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        let progressPath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2 - 16, y: frame.size.width / 2 - 16), radius: (frame.size.width) / 2, startAngle: 0, endAngle: CGFloat(CGFloat(M_PI * 2)), clockwise: true);
        progressLayer = CAShapeLayer();
        progressLayer.path = progressPath.CGPath;
//        progressLayer.fillColor = Utility.colorFromHexString("#76C043").CGColor;
        progressLayer.fillColor = UIColor.clearColor().CGColor;
        progressLayer.strokeColor = Utility.colorFromHexString("#76C043").CGColor;
        progressLayer.lineWidth = 3;
        
        UIView.animateWithDuration(duration * 2, delay: 0, options: .CurveLinear | .Repeat, animations: {
            self.transform = CGAffineTransformRotate(self.transform, CGFloat(M_PI * 2));
            }, completion: nil);
        
        layer.addSublayer(progressLayer);
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createInstance() ->  CustomLoadingSpinner {
        return UINib(nibName: "CustomSpinner", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as CustomLoadingSpinner;
    }
    
    func startAnimation() {
        let growAnimationPath = CABasicAnimation(keyPath: "path");
        growAnimationPath.fromValue = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2 - 16, y: frame.size.width / 2 - 16), radius: 2, startAngle: 0, endAngle: CGFloat(CGFloat(M_PI * 2)), clockwise: true).CGPath;
        growAnimationPath.toValue = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2 - 16, y: frame.size.width / 2 - 16), radius: (frame.size.width) / 2, startAngle: 0, endAngle: CGFloat(CGFloat(M_PI * 2)), clockwise: true).CGPath;
        growAnimationPath.timingFunction = timingFunction;
        
        let growAnimationBounds = CABasicAnimation(keyPath: "bounds");
        growAnimationBounds.toValue = NSValue(CGRect: CGRectMake(0, 0, (frame.size.width) / 2 - 16, (frame.size.width) / 2 - 16));
        growAnimationBounds.timingFunction = timingFunction;
        
        let strokeDuration = duration;
        let strokeAnimation = CABasicAnimation(keyPath: "lineWidth");
        strokeAnimation.duration = duration;
        strokeAnimation.fromValue = 20;
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
            transformAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut);
            
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
                growAnimationGroup.animations = [growAnimation, fasterSpinAnimation];
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
}