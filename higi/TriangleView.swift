import Foundation

class TriangleView : UIView {
    
    var w, h: CGFloat!;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        w = frame.size.width;
        h = frame.size.height;
        backgroundColor = UIColor.clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect);
        drawTriangle(UIGraphicsGetCurrentContext() as CGContextRef, bounds: CGRect(x: 0, y: 0, width: w, height: h));
    }
    
    func drawTriangle(context: CGContextRef, bounds rect: CGRect) {
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor);
        CGContextMoveToPoint(context, rect.width / 8, rect.height * 7 / 8);
        CGContextAddLineToPoint(context, rect.width / 2, rect.height / 8);
        CGContextAddLineToPoint(context, rect.width * 7 / 8, rect.height * 7 / 8);
        CGContextAddLineToPoint(context, rect.width / 8, rect.height * 7 / 8);
        CGContextFillPath(context);
    }
}