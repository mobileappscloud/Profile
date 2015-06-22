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
    
    var drawAngle: Double!;
    
    class func create(frame: CGRect, delegate: MetricDelegate, tab: Int) -> MetricGauge {
        let gauge = UINib(nibName: "MetricGaugeView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MetricGauge;
        gauge.setup(frame, delegate: delegate, tab: tab);
        return gauge;
    }
    
    func setup(frame: CGRect, delegate: MetricDelegate, tab:Int) {
        var userValue = 0;
        if delegate.getSelectedValue(tab).toInt() != nil {
            userValue = delegate.getSelectedValue(tab).toInt()!;
        } else if (delegate.getType() == MetricsType.BloodPressure) {
            let valueArray = split(delegate.getSelectedValue(tab)) {$0 == "/"};
            if (valueArray.count > 1) {
                let systolic = valueArray[0].toInt()!;
                let diastolic = valueArray[1].toInt()!;
                userValue = BpMetricDelegate.valueIsSystolic(systolic, diastolic: diastolic) ? systolic : diastolic;
            }
        }
        self.value.text = "\(delegate.getSelectedValue(tab))";
        self.frame = frame;
        gaugeContainer.frame = frame;
        self.unit.text = delegate.getSelectedUnit(tab);
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
        drawAngle = sweepAngle / Double(ranges.count);
        var strokeStart:CGFloat = 0.0, strokeEnd:CGFloat = 0.0;
        var valueSet = false;
        var userRange, lowRange, highRange: Range!;
        rangeMax = 0;
        rangeMin = 99999;
        var rangeIndex = 0, i = 0;
        for range in ranges {
            let (begin, end) = range.interval;
            let rangeInterval = 1 / CGFloat(ranges.count);
            strokeEnd = strokeStart + rangeInterval;
            var toPath = UIBezierPath();
            var rangeArc = CAShapeLayer();
            rangeArc.lineWidth = lineWidth;
            rangeArc.fillColor = UIColor.clearColor().CGColor;
            if (range.contains(userValue)) {
                self.label.text = range.label;
                self.label.textColor = range.color;
                valueSet = true;
                userRange = range;
                rangeIndex = i;
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
                userRange = lowRange;
                rangeIndex = 0;
            }
            ratio = 0;
        } else if (userValue > rangeMax) {
            if (!valueSet) {
                self.label.text = highRange.label;
                self.label.textColor = highRange.color;
                userRange = highRange;
                rangeIndex = ranges.count - 1;
            }
            ratio = 1;
        } else {
            ratio = CGFloat(userValue) / CGFloat(rangeMax + rangeMin);
        }
        drawMarker(startAngle + CGFloat(drawAngle) * CGFloat(rangeIndex), value: userValue, range: userRange);
    }
    
    func drawMarker(startAngle:CGFloat, value: Int, range: Range) {
        let valueAngle = CGFloat(value - range.lowerBound) / CGFloat(range.upperBound - range.lowerBound) * CGFloat(drawAngle) + startAngle;
        let ratio = min(CGFloat(value) / CGFloat(rangeMax + rangeMin), 1);
        let angle = CGFloat(startAngle) + CGFloat(sweepAngle) * ratio;
        let triangleHeight:CGFloat = 20;
        let triangleX = center.x + radius * cos(valueAngle) - triangleHeight / 2;
        let triangleY = center.y + radius * sin(valueAngle);
        let triangle = TriangleView(frame: CGRect(x: triangleX, y: triangleY, width: triangleHeight, height: triangleHeight));
        triangle.transform = CGAffineTransformRotate(self.transform, valueAngle - 3 * CGFloat(M_PI) / 2);
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