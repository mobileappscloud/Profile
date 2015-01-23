import Foundation

class ChallengeRowCell: UITableViewCell, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var scrollView: UIScrollView!;
    @IBOutlet var daysLeft: UILabel!;
    @IBOutlet var title: UILabel!;
    @IBOutlet var avatar: UIImageView!;
    @IBOutlet var pager: UIPageControl!;
    @IBOutlet weak var join: UILabel!
    
    //@todo remove this if not used
    let tapGestureRecognizer = UITapGestureRecognizer();
    let swipeGestureRecognizer = UISwipeGestureRecognizer();
    
    class func instanceFromNib() -> ChallengeRowCell {
        return UINib(nibName: "ChallengeRowCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeRowCell;
    }

    override
    func layoutSubviews() {
        scrollView.delegate = self;
        scrollView.delaysContentTouches = true;
        var page = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width));
        changePage(pager);
        
//        @todo fix this up or remove it
//
//        tapGestureRecognizer.addTarget(self, action: "cellTapped:");
//        tapGestureRecognizer.cancelsTouchesInView = false;
//        swipeGestureRecognizer.addTarget(self, action: "cellSwiped:");
//        
//        scrollView.addGestureRecognizer(tapGestureRecognizer);
//        scrollView.addGestureRecognizer(swipeGestureRecognizer);
//
    }
    
    func cellTapped(sender: AnyObject) {
        var i = 0;
    }
    
    func cellSwiped(sender: AnyObject) {
        var t = 0;
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

}