import Foundation

class ChallengeRowCell: UITableViewCell, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var scrollView: UIScrollView!;
    @IBOutlet var daysLeft: UILabel!;
    @IBOutlet var title: UILabel!;
    @IBOutlet var avatar: UIImageView!;
    @IBOutlet var pager: UIPageControl!;
        
    class func instanceFromNib() -> ChallengeRowCell {
        return UINib(nibName: "ChallengeRowCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeRowCell;
    }

    override
    func layoutSubviews() {
        scrollView.delegate = self;
        scrollView.delaysContentTouches = true;
        scrollView.contentSize.height = scrollView.frame.size.height;
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

}