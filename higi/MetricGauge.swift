import Foundation

class MetricGauge: UIView {
    
    @IBOutlet weak var gaugeContainer: UIView!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var label: UILabel!
    
    var lineWidth, radius: CGFloat!;
    
    var ranges: [(String, (Int, Int))] = [];
    
    var delegate: MetricDelegate!;
    
    let sweepAngle = M_PI * 2 / 3;
    
    class func create(frame: CGRect, delegate: MetricDelegate) -> MetricGauge {
        let gauge = UINib(nibName: "MetricGaugeView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MetricGauge;
        gauge.setup(frame, delegate: delegate);
        return gauge;
    }
    
    func setup(frame: CGRect, delegate: MetricDelegate) {
        self.frame = frame;
        gaugeContainer.frame = frame;
        value.frame.size.width = frame.size.width;
        value.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2);
        label.frame.size.width = frame.size.width;
        label.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2 - value.frame.size.height);
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
        for range in ranges {
            
        }
    }
    
    func setUserValue(value: Int) {
        self.value.text = "\(value)";
    }
}