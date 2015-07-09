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
    
    var startAngle: CGFloat = 0.0;
    
    var userValue: Int!;
    
    var userRange: Range!;
    
    class func create(frame: CGRect, delegate: MetricDelegate, tab: Int) -> MetricGauge {
        let gauge = UINib(nibName: "MetricGaugeView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MetricGauge;
        gauge.setup(frame, delegate: delegate, tab: tab);
        return gauge;
    }
    
    func setup(frame: CGRect, delegate: MetricDelegate, tab:Int) {
        userValue = 0;
        var value = delegate.getSelectedValue(tab);
        if delegate.getType() == MetricsType.Weight && Utility.stringIndexOf(value, needle: "%") > 0 {
            //in the form 20.00%
            let valueArray = split(value) {$0 == "."};
            if (valueArray.count > 1) {
                userValue = valueArray[0].toInt()!;
            }
        } else if (delegate.getType() == MetricsType.BloodPressure) {
            //in the form 120/80
            if Utility.stringIndexOf(value, needle: "/") > 0 {
                let valueArray = split(value) {$0 == "/"};
                if (valueArray.count > 1) {
                    let systolic = valueArray[0].toInt()!;
                    let diastolic = valueArray[1].toInt()!;
                    userValue = BpMetricDelegate.valueIsSystolic(systolic, diastolic: diastolic) ? systolic : diastolic;
                }
            } else if Utility.stringIndexOf(value, needle: ".") > 0 {
                //in the form 80.0
                let valueArray = split(value) {$0 == "."};
                if (valueArray.count > 1) {
                    userValue = valueArray[0].toInt()!;
                }
            }
        } else if value.toInt() != nil {
            userValue = value.toInt()!;
        }

        self.value.text = "\(value)";
        self.frame = frame;
        gaugeContainer.frame = frame;
        self.unit.text = delegate.getSelectedUnit(tab);
        self.delegate = delegate;
        let dimension = min(frame.size.width, frame.size.height);
        lineWidth = dimension * 0.05;
        radius = (dimension / 2 - (lineWidth / 2)) * 0.95;
        var center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2);
        
        //expression too complex for Swift in one line
        startAngle = CGFloat((M_PI * 2 - sweepAngle) / 2);
        startAngle += CGFloat(M_PI / 2);
        
        let rangeClass = delegate.getSelectedClass(tab);
        self.label.text = rangeClass;
        self.label.textColor = delegate.colorFromClass(rangeClass, tab: tab);
        
        let ranges = delegate.getRanges(tab);
        if ranges.count == 0 {
            var toPath = UIBezierPath();
            var rangeArc = CAShapeLayer();
            rangeArc.lineWidth = lineWidth;
            rangeArc.fillColor = UIColor.clearColor().CGColor;
            rangeArc.strokeColor = UIColor.whiteColor().CGColor;
            var center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2);
            rangeArc.strokeStart = 0;
            rangeArc.strokeEnd = 1;
            toPath.addArcWithCenter(center, radius: radius, startAngle: startAngle, endAngle: CGFloat(sweepAngle) + startAngle, clockwise: true);
            rangeArc.path = toPath.CGPath;
            gaugeContainer.layer.addSublayer(rangeArc);
            self.label.text = "";
        } else {
            drawAngle = sweepAngle / Double(ranges.count);
            var strokeStart:CGFloat = 0.0, strokeEnd:CGFloat = 0.0;
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
                    userRange = range;
                    rangeIndex = i;
                }
                rangeArc.strokeColor = range.color.CGColor;
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
                    let labelMargin:CGFloat = 10;
                    let angle = CGFloat(startAngle) + (CGFloat(sweepAngle)) * strokeEnd;
                    var x = center.x + radius * cos(angle);
                    let y = center.y + radius * sin(angle) - (lineWidth + labelMargin) * 2;
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
                    label.font = UIFont.systemFontOfSize(10);
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
            drawMarker(startAngle + CGFloat(drawAngle) * CGFloat(rangeIndex), value: userValue, range: userRange);
        }
    }
    
    func drawMarker(markerAngle:CGFloat, value: Int, range: Range) {
        var valueAngle = CGFloat(value - range.lowerBound) / CGFloat(range.upperBound - range.lowerBound) * CGFloat(drawAngle) + markerAngle;
        valueAngle = min(max(valueAngle, markerAngle), startAngle + CGFloat(sweepAngle));

        let triangleFrame = CGRect(x: 0, y: 0, width: gaugeContainer.frame.size.width, height: gaugeContainer.frame.size.height);
        
        let triangle = TriangleMarker(frame: triangleFrame);
        triangle.initMarker(valueAngle, center: center, radius: radius, lineWidth: lineWidth);
        gaugeContainer.addSubview(triangle);
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        gaugeContainer.frame.size.width = frame.size.width;
        gaugeContainer.frame.size.height = frame.size.height;
        value.frame.size.width = frame.size.width;
        value.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2);
        label.frame.size.width = frame.size.width;
        label.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2);
        unit.frame.size.width = frame.size.width;
        unit.frame.origin.y = value.frame.origin.y - unit.frame.size.height - 4;
        unit.center.x = frame.size.width / 2;
        drawRect(frame);
    }
    
}