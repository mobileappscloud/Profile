import Foundation

class DailySummaryViewController: BaseViewController {
    
    @IBOutlet weak var pointsMeterContainer: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var activityView: UIView!
    
    var pointsMeter:PointsMeter!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = "Daily Summary";
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        pointsMeter = UINib(nibName: "PointsMeterView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! PointsMeter;
        pointsMeterContainer.addSubview(pointsMeter);
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        pointsMeter.drawArc();
    }
}