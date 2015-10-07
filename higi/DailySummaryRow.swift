import Foundation

class DailySummaryRow: UIView {
    
    @IBOutlet weak var points: UILabel!
    @IBOutlet weak var pointUnitLabel: UILabel! {
        didSet {
            pointUnitLabel.text = NSLocalizedString("DAILY_SUMMARY_ROW_POINTS_UNIT_LABEL", comment: "Label for points units as seen in the daily summary row.")
        }
    }
    @IBOutlet weak var progressCircle: UIView!
    @IBOutlet weak var name: UILabel!
}