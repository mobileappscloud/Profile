import Foundation

class MetricGauge: UIView {
    
    @IBOutlet weak var gaugeContainer: UIView!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var unit: UILabel!
    var lineWidth, radius: CGFloat!;
    
    var ranges: [Range] = [];
    
    var rangeMax, rangeMin: Int!;
    
    struct Range {
        var label: String!;
        
        var color: UIColor!;
        
        var interval: (Int, Int)!;
        
        var lowerBound, upperBound: Int!;
        
        init(label: String, color: UIColor, interval: (Int, Int)) {
            self.label = label;
            self.color = color;
            self.interval = interval;
            self.lowerBound = interval.0;
            self.upperBound = interval.1;
        }
        
        func contains(value: Int) -> Bool {
            return value >= lowerBound && value < upperBound;
        }
    }
    var delegate: MetricDelegate!;
    
    let sweepAngle = 2 * M_PI * 2 / 3;
    
    class func create(frame: CGRect, delegate: MetricDelegate, userValue: Int, unit: String, tab: Int) -> MetricGauge {
        let gauge = UINib(nibName: "MetricGaugeView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MetricGauge;
        gauge.setup(frame, delegate: delegate, userValue: userValue, unit: unit, tab: tab);
        return gauge;
    }
    
    func setup(frame: CGRect, delegate: MetricDelegate, userValue: Int, unit: String, tab:Int) {
        self.value.text = "\(userValue)";
        self.frame = frame;
        gaugeContainer.frame = frame;
        self.unit.text = unit;
        self.delegate = delegate;
        lineWidth = frame.size.width * 0.1;
        radius = (frame.size.width / 2 - (lineWidth / 2)) * 0.9;
        var toPath = UIBezierPath();
        var arc = CAShapeLayer();
        arc.lineWidth = lineWidth;
        arc.fillColor = UIColor.clearColor().CGColor;
        arc.strokeColor = UIColor.whiteColor().CGColor;
        var center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2);
        
        //expression too complex for Swift in one line
        var startAngle = CGFloat((M_PI * 2 - sweepAngle) / 2);
        startAngle += CGFloat(M_PI / 2);
        
        toPath.addArcWithCenter(center, radius: radius, startAngle: startAngle, endAngle: CGFloat(sweepAngle) + startAngle, clockwise: true);
        arc.path = toPath.CGPath;
        gaugeContainer.layer.addSublayer(arc);
        
        let ranges = delegate.getRanges(tab);
        var strokeStart:CGFloat = 0.0, strokeEnd:CGFloat = 0.0;
        var valueSet = false;
        var lowRange, highRange: Range!;
        rangeMax = 0;
        rangeMin = 99999;
        var i = 0;
        for range in ranges {
            let (begin, end) = range.interval;
            let rangeInterval = 1 / CGFloat(ranges.count);
            strokeEnd = strokeStart + rangeInterval;
            var toPath = UIBezierPath();
            var rangeArc = CAShapeLayer();
            rangeArc.lineWidth = lineWidth;
            rangeArc.fillColor = UIColor.clearColor().CGColor;
            if (userValue < end && userValue >= begin) {
                self.label.text = range.label;
                self.label.textColor = range.color;
                valueSet = true;
            }
            rangeArc.strokeColor = range.color.CGColor;
            
            if (begin < rangeMin) {
                rangeMin = begin;
                lowRange = range;
            }
            if (end > rangeMax) {
                rangeMax = end;
                highRange = range;
            }
            var center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2);
            rangeArc.strokeStart = strokeStart;
            rangeArc.strokeEnd = strokeEnd;
            strokeStart = strokeEnd;
            toPath.addArcWithCenter(center, radius: radius, startAngle: startAngle, endAngle: CGFloat(sweepAngle) + startAngle, clockwise: true);
            rangeArc.path = toPath.CGPath;
            gaugeContainer.layer.addSublayer(rangeArc);
            if (i < ranges.count - 1) {
                let rangeVal = CGFloat(i + 1);
                let labelWidth:CGFloat = 100;
                let labelMargin:CGFloat = 8
                let angle = CGFloat(startAngle) + (CGFloat(sweepAngle)) * strokeEnd;
                var x = center.x + radius * cos(angle);
                let y = center.y + radius * sin(angle) - lineWidth * 2 - labelMargin;
                var textAlign = NSTextAlignment.Left;
                if (rangeVal < CGFloat(ranges.count) / 2) {
                    textAlign = NSTextAlignment.Right;
                    x = x - labelWidth - labelMargin;
                } else if (rangeVal == CGFloat(ranges.count) / 2) {
                    textAlign = NSTextAlignment.Center;
                    x -= labelWidth / 2;
                } else {
                    x += labelMargin;
                }
                let label = UILabel(frame: CGRect(x: x, y: y, width: labelWidth, height: 50));
                label.textAlignment = textAlign;
                label.text = "\(end)";
                label.font = UIFont.systemFontOfSize(12);
                gaugeContainer.addSubview(label);
                
                var toPath = UIBezierPath();
                var rangeArc = CAShapeLayer();
                rangeArc.lineWidth = lineWidth;
                rangeArc.fillColor = UIColor.clearColor().CGColor;
                rangeArc.strokeColor = UIColor.lightGrayColor().CGColor;
                var center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2);
                rangeArc.strokeStart = strokeStart;
                rangeArc.strokeEnd = strokeStart + 0.001;
                strokeStart = strokeEnd;
                toPath.addArcWithCenter(center, radius: radius, startAngle: startAngle, endAngle: CGFloat(sweepAngle) + startAngle, clockwise: true);
                rangeArc.path = toPath.CGPath;
                gaugeContainer.layer.addSublayer(rangeArc);
                strokeStart += 0.001;
            }
            i++;
        }
        var ratio:CGFloat!;
        if (userValue < rangeMin) {
            if (!valueSet) {
                self.label.text = lowRange.label;
                self.label.textColor = lowRange.color;
            }
            ratio = 0;
        } else if (userValue > rangeMax) {
            if (!valueSet) {
                self.label.text = highRange.label;
                self.label.textColor = highRange.color;
            }
            ratio = 1;
        } else {
            ratio = CGFloat(userValue) / CGFloat(rangeMax + rangeMin);
        }
        let angle = CGFloat(startAngle) + CGFloat(sweepAngle) * ratio;
        let triangleHeight:CGFloat = 20;
        let triangleX = center.x + radius * cos(angle) - triangleHeight / 2;
        let triangleY = center.y + radius * sin(angle);
        let triangle = TriangleView(frame: CGRect(x: triangleX, y: triangleY, width: triangleHeight, height: triangleHeight));
        triangle.transform = CGAffineTransformRotate(self.transform, angle - 3 * CGFloat(M_PI) / 2);
        addSubview(triangle);
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        value.frame.size.width = frame.size.width;
        value.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2);
        label.frame.size.width = frame.size.width;
        label.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2);
        unit.frame.size.width = frame.size.width;
        unit.frame.origin.y = value.frame.origin.y - unit.frame.size.height - 4;
        unit.center.x = frame.size.width / 2;
    }
}