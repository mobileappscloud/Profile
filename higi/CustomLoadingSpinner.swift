import Foundation
import QuartzCore

final class CustomLoadingSpinner: UIView {
    
    private let duration: CFTimeInterval = 1
    
    private var lineWidth: CGFloat = 0, maxLineWidth:CGFloat = 0, startingStrokeStart:CGFloat = 0, outerRadius: CGFloat = 0, strokeStart:CGFloat = 0, lastRotation: CGFloat = 0, minSweep: CGFloat = 0.2, radius: CGFloat = 0, rotation: CGFloat = 0
    
    private var progressLayer: CAShapeLayer
    
    private var shouldAnimate = true
    var shouldAnimateFull = true

    private var centerPoint:CGPoint
    
    override init(frame: CGRect) {
        centerPoint = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        
        progressLayer = CAShapeLayer()
        progressLayer.path = UIBezierPath(arcCenter: centerPoint, radius: 0, startAngle: 0, endAngle: CGFloat(CGFloat(M_PI * 2)), clockwise: true).CGPath
        progressLayer.strokeColor = Theme.Color.primary.CGColor
        progressLayer.anchorPoint = centerPoint
        progressLayer.fillColor = UIColor.clearColor().CGColor
        
        super.init(frame: frame)
        
        radius = (min(frame.size.width, frame.size.height) / 2) - maxLineWidth
        maxLineWidth = min(frame.size.width, frame.size.height) * 0.1
        
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.addSublayer(progressLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private API
extension CustomLoadingSpinner {
    private func createInstance() ->  CustomLoadingSpinner {
        return UINib(nibName: "CustomSpinner", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! CustomLoadingSpinner
    }
    
    
    private func rotateAnimation() {
        //exclude big negative vals
        if (self.rotation - self.lastRotation > 0) {
            dispatch_async(dispatch_get_main_queue(), {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                self.layer.transform = CATransform3DRotate(self.layer.transform, self.rotation - self.lastRotation, 0, 0, 1)
                CATransaction.setDisableActions(false)
                CATransaction.commit()
            })
        }
    }
    
    private func growArcAnimation(drawPercent: CGFloat) {
        strokeStart = startingStrokeStart - (startingStrokeStart - minSweep) * drawPercent
    }
    
    private func shrinkArcAnimation(drawPercent: CGFloat) {
        strokeStart = startingStrokeStart + (1 - minSweep - startingStrokeStart) * drawPercent
    }
    
    private func growOutsideAnimation(drawPercent: CGFloat) {
        self.lineWidth = radius * drawPercent
        self.outerRadius = radius * drawPercent
    }
    
    private func growInsideAnimation(drawPercent: CGFloat) {
        self.lineWidth = (radius - (radius * 0.8) * drawPercent)
    }
}

// MARK: - Public API
extension CustomLoadingSpinner {
    func startAnimating() {
        shouldAnimate = true
        var phase = 0
        if (!shouldAnimateFull) {
            phase = 2
            progressLayer.path = UIBezierPath(arcCenter: self.centerPoint, radius: radius, startAngle: 0, endAngle: CGFloat(CGFloat(M_PI * 2)), clockwise: true).CGPath
            lineWidth = radius * 0.2
            outerRadius = radius + self.lineWidth / 2
        }
        let durations = [duration, duration / 2 , duration, duration * 2]
        
        let startTime = NSDate()
        var phaseStartTime = startTime
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            [weak self] in
            while (true) {
                guard let strongSelf = self else { return }
                let currentTime = NSDate()
                if (currentTime.timeIntervalSinceDate(phaseStartTime) > durations[phase]) {
                    phaseStartTime = currentTime
                    phase += 1
                    strongSelf.startingStrokeStart = strongSelf.strokeStart
                    if (phase > 3) {
                        phase = 2
                    }
                    if (phase == 1) {
                        self?.progressLayer.fillColor = UIColor.clearColor().CGColor
                    }
                }
                var easing:CGFloat = (CGFloat(currentTime.timeIntervalSinceDate(phaseStartTime))) / CGFloat(durations[phase] / 2)
                
                var drawPercent:CGFloat = 0
                if (easing < 1) {
                    drawPercent = 0.5 * CGFloat(pow(easing, 3))
                } else {
                    easing -= 2
                    drawPercent = 0.5 * CGFloat(pow(easing, 3) + 2)
                }
                strongSelf.lastRotation = strongSelf.rotation
                strongSelf.rotation = ((CGFloat(currentTime.timeIntervalSinceDate(startTime)) % 2) / CGFloat(2)) * CGFloat(M_PI * 2)
                switch phase {
                case 0:
                    strongSelf.growOutsideAnimation(drawPercent)
                case 1:
                    strongSelf.growInsideAnimation(drawPercent)
                case 2:
                    strongSelf.shrinkArcAnimation(drawPercent)
                case 3:
                    strongSelf.growArcAnimation(drawPercent)
                    strongSelf.rotation += CGFloat(drawPercent * CGFloat(M_PI * 2))
                default:
                    break
                }
                strongSelf.rotateAnimation()
                let path = UIBezierPath(arcCenter: strongSelf.centerPoint, radius: strongSelf.outerRadius - strongSelf.lineWidth / 2, startAngle: 0, endAngle: CGFloat(CGFloat(M_PI * 2)), clockwise: true).CGPath
                
                dispatch_async(dispatch_get_main_queue(), {
                    [weak strongSelf] in
                    guard let strongSelf = strongSelf else { return }
                    CATransaction.begin()
                    CATransaction.setDisableActions(true)
                    strongSelf.progressLayer.lineWidth = strongSelf.lineWidth
                    strongSelf.progressLayer.path = path
                    strongSelf.progressLayer.strokeStart = strongSelf.strokeStart
                    CATransaction.setDisableActions(false)
                    CATransaction.commit()
                })
                if !strongSelf.shouldAnimate {
                    break
                }
                NSThread.sleepForTimeInterval(0.01)
                if !strongSelf.shouldAnimate {
                    break
                }
            }
            })
    }

    func stopAnimating() {
        shouldAnimate = false
    }
}