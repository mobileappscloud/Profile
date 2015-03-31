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
//            self.progressLayer.lineWidth 
//            CATransaction.begin();
//            
//            CATransaction.setCompletionBlock({
//                self.spinAnimation();
//            });
            
//            self.progressLayer.addAnimation(strokeAnimation, forKey: nil);
            self.spinAnimation();
//            CATransaction.commit();
        });
        
        progressLayer.addAnimation(growAnimationGroup, forKey: "grow");
        
        CATransaction.commit();
//        let growAnimation = CABasicAnimation(keyPath: "lineWidth");
//        growAnimation.duration = duration;
//        growAnimation.fromValue = 20;
//        growAnimation.toValue = 3;
//        growAnimation.repeatCount = 1;
//        growAnimation.timingFunction = timingFunction;
//        growAnimation.removedOnCompletion = false;
//        
//        progressLayer.addAnimation(growAnimation, forKey: "lineWidth");
    }
    
    func spinAnimation() {
        let transformAnimation = CABasicAnimation(keyPath: "transform.rotation");
        transformAnimation.duration = 4 * duration;
        transformAnimation.fromValue = 0;
        transformAnimation.toValue = CGFloat(CGFloat(M_PI * 2));
        transformAnimation.timingFunction = timingFunction
        transformAnimation.repeatDuration = 1000;
        
//        progressLayer.addAnimation(transformAnimation, forKey: "transform.rotation");
        
        let startHeadAnimation = CABasicAnimation(keyPath: "strokeStart");
        startHeadAnimation.duration = duration;
        startHeadAnimation.fromValue = 0;
        startHeadAnimation.toValue = 0.5;
        startHeadAnimation.timingFunction = timingFunction;
        
        let startTailAnimation = CABasicAnimation(keyPath: "strokeEnd");
        startTailAnimation.duration = duration;
        startTailAnimation.fromValue = 0;
        startTailAnimation.toValue = 1;
        startTailAnimation.timingFunction = timingFunction;
        
        let endHeadAnimation = CABasicAnimation(keyPath: "strokeStart");
        endHeadAnimation.duration = duration / 2;
        endHeadAnimation.fromValue = 0.5;
        endHeadAnimation.toValue = 1;
        endHeadAnimation.timingFunction = timingFunction;
        endHeadAnimation.beginTime = 1;
        
        let endTailAnimation = CABasicAnimation(keyPath: "strokeEnd");
        endTailAnimation.duration = duration / 2;
        endTailAnimation.fromValue = 1;
        endTailAnimation.toValue = 1;
        endTailAnimation.timingFunction = timingFunction;
        endTailAnimation.beginTime = 1;
        
        let animationGroup = CAAnimationGroup();
        animationGroup.duration = duration + duration / 2;
//        animationGroup.animations = [startHeadAnimation, startTailAnimation, endHeadAnimation, endTailAnimation];
        animationGroup.animations = [startHeadAnimation, endHeadAnimation];
        animationGroup.repeatDuration = 1000;
        animationGroup.timeOffset = 1000;
        
        progressLayer.addAnimation(animationGroup, forKey: "animate");
    }
}