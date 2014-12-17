import UIKit

class ScrollViewPagerControllerViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet var scrollView: UIScrollView!;
    @IBOutlet var pageControl: UIPageControl!;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
