import Foundation

class MetricGauge: UIView {
    
    @IBOutlet weak var gaugeContainer: UIView!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var label: UILabel!
    
    var lineWidth, radius: CGFloat!;
    
    var ranges: [Range] = [];
    
    struct Range {
        var label: String!;
        
        var color: UIColor!;
        
        var interval: (Int, Int)!;
        
        init(label: String, color: UIColor, interval: (Int, Int)) {
            self.label = label;
            self.color = color;
            self.interval = interval;
        }
    }
    var delegate: MetricDelegate!;
    
    let sweepAngle = M_PI * 2 / 3;
    
    class func create(frame: CGRect, delegate: MetricDelegate, userValue: Int) -> MetricGauge {
        let gauge = UINib(nibName: "MetricGaugeView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MetricGauge;
        gauge.setup(frame, delegate: delegate, userValue: userValue);
        return gauge;
    }
    
    func setup(frame: CGRect, delegate: MetricDelegate, userValue: Int) {
        self.value.text = "\(userValue)";
        self.frame = frame;
        gaugeContainer.frame = frame;
        value.frame.size.width = frame.size.width;
        value.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2);
        label.frame.size.width = frame.size.width;
        label.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2 + value.frame.size.height);
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
        startAngle -= CGFloat(M_PI / 2);
        
        toPath.addArcWithCenter(center, radius: radius, startAngle: startAngle, endAngle: CGFloat(sweepAngle) + startAngle, clockwise: false);
        arc.path = toPath.CGPath;
        gaugeContainer.layer.addSublayer(arc);
        
        let ranges = delegate.getRanges();
        
        var sortedRanges:[(String, UIColor, (Int, Int))] = [];
        
        var min = 99999999, max = 0;
        for range in ranges {
            let (begin, end) = range.interval;
            if (begin < min) {
                min = begin;
            }
            if (end > max) {
                max = end;
            }
            if (userValue <= end && userValue >= begin) {
                self.label.text = range.label;
            }
        }
        
        var strokeStart:CGFloat = 0.0, strokeEnd:CGFloat = 0.0;
        let x = center.x + radius * cos(startAngle);
        let y = center.y + radius * sin(startAngle);
        for range in ranges {
            let (begin, end) = range.interval;
            let rangeInterval = (CGFloat(end) - CGFloat(begin)) / (CGFloat(max) - CGFloat(min));
            strokeEnd = strokeStart + rangeInterval;
            var toPath = UIBezierPath();
            var rangeArc = CAShapeLayer();
            rangeArc.lineWidth = lineWidth;
            rangeArc.fillColor = UIColor.clearColor().CGColor;
            if (userValue <= end && userValue >= begin) {
                self.label.text = range.label;
                rangeArc.strokeColor = range.color.CGColor;
            } else {
                rangeArc.strokeColor = UIColor.whiteColor().CGColor;
            }
            var center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2);
            rangeArc.strokeStart = strokeStart;
            rangeArc.strokeEnd = strokeEnd;
            strokeStart = strokeEnd;
            toPath.addArcWithCenter(center, radius: radius, startAngle: startAngle, endAngle: CGFloat(sweepAngle) + startAngle, clockwise: false);
            rangeArc.path = toPath.CGPath;
            gaugeContainer.layer.addSublayer(rangeArc);
        }
    }
    
    func setUserValue(value: Int) {
        self.value.text = "\(value)";
        for range in ranges {
            let (begin, end) = range.interval;
            if (value <= end && value >= begin) {
                self.label.text = range.label;
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        value.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2);
        label.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2 + value.frame.size.height);
    }
}