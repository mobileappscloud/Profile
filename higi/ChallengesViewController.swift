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
    
    private var userController: UserController!
    
    func configureWith(userController userController: UserController) {
        self.userController = userController
    }
    
    override func viewDidLoad() {
        title = NSLocalizedString("CHALLENGES_VIEW_TITLE", comment: "Title for challenges view.")
    }
}

// MARK: - Navigation
extension ChallengesViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ChallengesViewController.Storyboard.Segue.segmentedPage {
            let segmentedPageViewController = segue.destinationViewController as! SegmentedPageViewController
            
            let titles = [
                NSLocalizedString("CHALLENGES_VIEW_SEGMENTED_CONTROL_SEGMENT_TITLE_CURRENT", comment: "Segment title for Current on segmented control in the challenges view."),
                NSLocalizedString("CHALLENGES_VIEW_SEGMENTED_CONTROL_SEGMENT_TITLE_FINISHED", comment: "Segment title for Finished on segmented control in the challenges view.")
            ]
            let currentChallengesVC = storyboard!.instantiateViewControllerWithIdentifier(ChallengesViewController.Storyboard.Identifier.ChallengesTableViewController) as! ChallengesTableViewController
            let currentChallengesTableType = ChallengesTableViewController.TableType(challengeType: .Current, entityType: .user, entityId: userController.user.identifier, pageSize: 0)
            currentChallengesVC.configureWith(userController: userController, tableType: currentChallengesTableType)
            
            let finishedChallengesVC = storyboard!.instantiateViewControllerWithIdentifier(ChallengesViewController.Storyboard.Identifier.ChallengesTableViewController) as! ChallengesTableViewController
            let finishedChallengesTableType = ChallengesTableViewController.TableType(challengeType: .Finished, entityType: .user, entityId: userController.user.identifier, pageSize: 10)
            finishedChallengesVC.configureWith(userController: userController, tableType: finishedChallengesTableType)

            segmentedPageViewController.set([currentChallengesVC, finishedChallengesVC], titles: titles)
        }
        
    }
}