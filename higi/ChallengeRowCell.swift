import Foundation

final class ChallengeRowCell: UITableViewCell, UIScrollViewDelegate {
    
    @IBOutlet var scrollView: UIScrollView!;
    @IBOutlet var daysLeft: UILabel! {
        didSet {
            daysLeft.text = ""
        }
    }
    @IBOutlet var title: UILabel! {
        didSet {
            title.text = ""
        }
    }
    @IBOutlet var avatar: UIImageView!;
    @IBOutlet var pager: UIPageControl!;

    override
    func layoutSubviews() {
        scrollView.delegate = self;
        scrollView.delaysContentTouches = true;
        scrollView.contentSize.height = scrollView.frame.size.height;
        changePage(pager);
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let page = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width));
        pager.currentPage = page;
        changePage(pager);
    }
    
    @IBAction func changePage(sender: AnyObject) {
        let pager = sender as! UIPageControl;
        let pageNumber = pager.currentPage;
        
        var frame = scrollView.frame;
        frame.origin.x = frame.size.width * CGFloat(pageNumber);
        frame.origin.y = 0;
        scrollView.setContentOffset(frame.origin, animated: true);
    }

}