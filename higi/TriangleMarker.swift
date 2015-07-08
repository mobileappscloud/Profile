import Foundation

class TriangleMarker : UIView {
    
    var w, h: CGFloat!;
    
    var valueAngle: CGFloat!, radius:CGFloat!, lineWidth: CGFloat!;
    
    var userRange: MetricGauge.Range!;
    
    var centerPoint: CGPoint!;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        w = frame.size.width;
        h = frame.size.height;
        backgroundColor = UIColor.clearColor()
    }
    
    func initMarker(valueAngle:CGFloat, center: CGPoint, radius: CGFloat, lineWidth: CGFloat) {
        self.valueAngle = valueAngle;
        self.centerPoint = center;
        self.radius = radius;
        self.lineWidth = lineWidth;
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect);
        drawMarker();
    }
    
    func drawTriangle(context: CGContextRef, bounds rect: CGRect) {
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor);
        CGContextMoveToPoint(context, rect.width / 8, rect.height * 7 / 8);
        CGContextAddLineToPoint(context, rect.width / 2, rect.height / 8);
        CGContextAddLineToPoint(context, rect.width * 7 / 8, rect.height * 7 / 8);
        CGContextAddLineToPoint(context, rect.width / 8, rect.height * 7 / 8);
        CGContextFillPath(context);
    }
    
    func drawMarker() {
        let triangleHeight:CGFloat = 20;
        let angleDelta = CGFloat(M_PI) / 30;
        let innerRadius = radius - lineWidth - 5;
        let context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor);
        CGContextMoveToPoint(context, center.x + radius * cos(valueAngle), center.y + radius * sin(valueAngle));
        CGContextAddLineToPoint(context, center.x + innerRadius * cos(valueAngle + angleDelta), center.y + innerRadius * sin(valueAngle + angleDelta));
        CGContextAddLineToPoint(context, center.x + innerRadius * cos(valueAngle - angleDelta), center.y + innerRadius * sin(valueAngle - angleDelta));
        CGContextFillPath(context);
    }
}