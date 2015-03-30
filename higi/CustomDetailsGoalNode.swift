import Foundation

class CustomDetailsGoalNode: UIView {

    @IBOutlet weak var goalIndex: UILabel!
    
    override func drawRect(rect: CGRect) {
        updateLayerProperties()
    }
    
    func updateLayerProperties() {
        layer.masksToBounds = true
        layer.cornerRadius = 15.0
    }
}