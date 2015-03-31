import Foundation

class CustomLoadingSpinner: UIView {
    
    let duration:CFTimeInterval = 1;
    let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut);
    var progressLayer: CAShapeLayer!;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        let progressPath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2 - 16, y: frame.size.width / 2 - 16), radius: (frame.size.width) / 2, startAngle: 0, endAngle: CGFloat(CGFloat(M_PI * 2)), clockwise: true);
        progressLayer = CAShapeLayer();
        progressLayer.path = progressPath.CGPath;
        progressLayer.fillColor = Utility.colorFromHexString("#76C043").CGColor;
        progressLayer.strokeColor = Utility.colorFromHexString("#76C043").CGColor;
        progressLayer.lineWidth = 3;
        progressLayer.strokeStart = 0.1;
        progressLayer.strokeEnd = 1;
        
        layer.addSublayer(progressLayer);
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createInstance() ->  CustomLoadingSpinner {
        var spinner = UINib(nibName: "CustomSpinner", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as CustomLoadingSpinner;
        spinner.startAnimation();
        return spinner;
    }
    
    func startAnimation() {
        growAnimation();
//        spinAnimation();
    }
    
    func growAnimation() {
        let growAnimationPath = CABasicAnimation(keyPath: "path");
        growAnimationPath.fromValue = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2 - 16, y: frame.size.width / 2 - 16), radius: 2, startAngle: 0, endAngle: CGFloat(CGFloat(M_PI * 2)), clockwise: true).CGPath;
        growAnimationPath.toValue = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2 - 16, y: frame.size.width / 2 - 16), radius: (frame.size.width) / 2, startAngle: 0, endAngle: CGFloat(CGFloat(M_PI * 2)), clockwise: true).CGPath;

//        progressLayer.addAnimation(growAnimationPath, forKey: nil);
//        
//        progressLayer.path = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2 - 2, y: frame.size.width / 2 - 2), radius: 2, startAngle: 0, endAngle: CGFloat(CGFloat(M_PI * 2)), clockwise: true).CGPath;
//        let newPath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2 - 16, y: frame.size.width / 2 - 16), radius: (frame.size.width) / 2, startAngle: 0, endAngle: CGFloat(CGFloat(M_PI * 2)), clockwise: true);
//        UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseInOut, animations: {
//            self.progressLayer.path = newPath.CGPath;
//            }, completion: { success in
//                let i = 0;
//        });

        let growAnimationBounds = CABasicAnimation(keyPath: "bounds");
        growAnimationBounds.toValue = NSValue(CGRect: CGRectMake(0, 0, (frame.size.width) / 2 - 16, (frame.size.width) / 2 - 16));

        let strokeDuration = 0.7;
        let strokeAnimation = CABasicAnimation(keyPath: "lineWidth");
        strokeAnimation.duration = duration;
        strokeAnimation.fromValue = 8;
        strokeAnimation.toValue = 3;
        strokeAnimation.timingFunction = timingFunction;
        strokeAnimation.timeOffset = strokeDuration;
        
        let growAnimationGroup = CAAnimationGroup();
        growAnimationGroup.animations = [growAnimationPath, growAnimationBounds];
        growAnimationGroup.duration = duration;
        
        CATransaction.begin();
        
        CATransaction.setCompletionBlock({
            self.progressLayer.fillColor = UIColor.clearColor().CGColor;
            self.spinAnimation();
        });
        
        progressLayer.addAnimation(growAnimationGroup, forKey: "grow");
        
        CATransaction.commit();

    }
    
    func spinAnimation() {
        let transformAnimation = CABasicAnimation(keyPath: "transform.rotation");
        transformAnimation.duration = 4 * duration;
        transformAnimation.fromValue = 0;
        transformAnimation.toValue = CGFloat(CGFloat(M_PI * 2));
        transformAnimation.timingFunction = timingFunction
        transformAnimation.repeatDuration = 9999999;
        
//        progressLayer.addAnimation(transformAnimation, forKey: "transform.rotation");
        
        let shrinkAnimation = CABasicAnimation(keyPath: "strokeEnd");
        shrinkAnimation.duration = duration * 2;
        shrinkAnimation.fromValue = 0.1;
        shrinkAnimation.toValue = 0.9;
        shrinkAnimation.timingFunction = timingFunction;

        let growAnimation = CABasicAnimation(keyPath: "strokeStart");
        growAnimation.duration = duration;
        growAnimation.fromValue = 0.9;
        growAnimation.toValue = 0.1;
        growAnimation.timingFunction = timingFunction;
        
        let animationGroup = CAAnimationGroup();
        animationGroup.duration = duration + duration / 2;
        animationGroup.animations = [shrinkAnimation, growAnimation];
        animationGroup.repeatDuration = 99999;
        animationGroup.timeOffset = duration;
        
        progressLayer.addAnimation(animationGroup, forKey: "animate");
    }
}