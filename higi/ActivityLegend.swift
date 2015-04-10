import Foundation

public class ActivityLegend: UIView {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var points: UILabel!
    @IBOutlet weak var key: UIView!
    
    class func instanceFromNib(device: ActivityDevice, points: Int) -> ActivityLegend {
        let row = UINib(nibName: "ActivityLegendView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ActivityLegend;
        row.name.text = device.name as String;
        row.points.text = "\(String(points)) pts";
        row.key.backgroundColor = Utility.colorFromHexString(device.colorCode);
        return row;
    }
}