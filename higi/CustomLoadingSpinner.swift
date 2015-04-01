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
        let growAnimationPath = CABasicAnimation(keyPath: "path");
        growAnimationPath.fromValue = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2 - 16, y: frame.size.width / 2 - 16), radius: 2, startAngle: 0, endAngle: CGFloat(CGFloat(M_PI * 2)), clockwise: true).CGPath;
        growAnimationPath.toValue = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2 - 16, y: frame.size.width / 2 - 16), radius: (frame.size.width) / 2, startAngle: 0, endAngle: CGFloat(CGFloat(M_PI * 2)), clockwise: true).CGPath;

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
        
        CATransaction.begin();
        
        let shrinkAnimation = CABasicAnimation(keyPath: "strokeStart");
        shrinkAnimation.duration = duration;
        shrinkAnimation.fromValue = 0.1;
        shrinkAnimation.toValue = 0.9;
        shrinkAnimation.timingFunction = timingFunction;
//        shrinkAnimation.repeatDuration = 9999999;
        
        CATransaction.setCompletionBlock({
            let growAnimation = CABasicAnimation(keyPath: "strokeStart");
            growAnimation.duration = self.duration;
            growAnimation.fromValue = 0.9;
            growAnimation.toValue = 0.1;
            growAnimation.timingFunction = self.timingFunction;
//            growAnimation.repeatDuration = 99999999;
            self.progressLayer.addAnimation(growAnimation, forKey: "shrink");
        });
        
        progressLayer.addAnimation(shrinkAnimation, forKey: "grow");
        
        CATransaction.commit();
    }
}