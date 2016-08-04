import Foundation

final class ChallengesViewController: UIViewController {
    struct Storyboard {
        struct Segue {
            static let segmentedPage = "SegmentedPageViewEmbedSegue"
        }
        
        struct Identifier {
            static let ChallengesTableViewController = "ChallengesTableViewController"
        }
    }
}

// MARK: - Navigation
extension ChallengesViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ChallengesViewController.Storyboard.Segue.segmentedPage {
            let segmentedPageViewController = segue.destinationViewController as! SegmentedPageViewController
            
            let horizontalMargin: CGFloat = 60.0
            segmentedPageViewController.segmentedControlHorizontalMargin = horizontalMargin
            
            let titles = ["Active", "New", "Finished"] // TODO: Peter Ryszkiewicz: Localize
            let vc = UIViewController()
            vc.view.backgroundColor = UIColor.orangeColor()
            let activeChallengesVC = storyboard!.instantiateViewControllerWithIdentifier(ChallengesViewController.Storyboard.Identifier.ChallengesTableViewController)
            
            
            let viewControllers = [activeChallengesVC, vc, vc]
            
            segmentedPageViewController.set(viewControllers, titles: titles)
        }
        
    }
}