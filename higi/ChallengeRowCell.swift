import Foundation

class ChallengeRowCell: UITableViewCell, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var scrollView: UIScrollView!;
    @IBOutlet var daysLeft: UILabel!;
    @IBOutlet var title: UILabel!;
    @IBOutlet var avatar: UIImageView!;
    @IBOutlet var pager: UIPageControl!;
    @IBOutlet weak var join: UILabel!
    
    class func instanceFromNib() -> ChallengeRowCell {
        return UINib(nibName: "ChallengeRowCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeRowCell;
    }
        
    override
    func layoutSubviews() {
        scrollView.delegate = self;
        scrollView.delaysContentTouches = true;
        var page = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width));
        changePage(pager);
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var page = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width));
        pager.currentPage = page;
        changePage(pager);
    }
    
    @IBAction func changePage(sender: AnyObject) {
        var pager = sender as UIPageControl;
        var pageNumber = pager.currentPage;
        
        var frame = scrollView.frame;
        frame.size.width = 320;
        frame.origin.x = frame.size.width * CGFloat(pageNumber);
        frame.origin.y = 0;
        scrollView.setContentOffset(frame.origin, animated: true);
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        return self;
    }
    
    override
    func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if (self.nextResponder() != nil) {
            self.nextResponder()!.touchesBegan(touches, withEvent: event);
        }
    }
}