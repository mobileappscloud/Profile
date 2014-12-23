import Foundation

class ChallengeRowCell: UITableViewCell, UIScrollViewDelegate {
    
    @IBOutlet var scrollView: UIScrollView!;
    @IBOutlet var daysLeft: UILabel!;
    @IBOutlet var title: UILabel!;
    @IBOutlet var avatar: UIImageView!;
    @IBOutlet var pager: UIPageControl!;
    @IBOutlet weak var join: UILabel!
    
    var totalPages = 0;
    var currentPage = 0;
    
    class func instanceFromNib(numPages: Int) -> ChallengeRowCell {
        return UINib(nibName: "ChallengeRowCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeRowCell;
    }
    
    override
    func layoutSubviews() {
        scrollView.delegate = self;
        var page = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width));
        currentPage = page;
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
        currentPage = pageNumber;
        
        var frame = scrollView.frame;
        frame.size.width = 320;
        frame.origin.x = frame.size.width * CGFloat(pageNumber);
        frame.origin.y = 0;
        scrollView.setContentOffset(frame.origin, animated: true);
    }
}