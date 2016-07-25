import Foundation

final class ChallengeDetailsTab: UITableView {
    
    @IBOutlet weak var descriptionTitle: UILabel! {
        didSet {
            descriptionTitle.text = NSLocalizedString("CHALLENGE_DETAILS_TAB_SECTION_DESCRIPTION_TITLE", comment: "Title for challenge description section.")
        }
    }
    @IBOutlet weak var durationTitle: UILabel! {
        didSet {
            durationTitle.text = NSLocalizedString("CHALLENGE_DETAILS_TAB_SECTION_DURATION_TITLE", comment: "Title for challenge duration section.")
        }
    }
    @IBOutlet weak var typeTitle: UILabel! {
        didSet {
            typeTitle.text = NSLocalizedString("CHALLENGE_DETAILS_TAB_SECTION_TYPE_TITLE", comment: "Title for challenge type section.")
        }
    }
    @IBOutlet weak var participantTitle: UILabel!  {
        didSet {
            participantTitle.text = NSLocalizedString("CHALLENGE_DETAILS_TAB_SECTION_PARTICIPANT_TITLE", comment: "Title for challenge participant section.")
        }
    }
    @IBOutlet weak var teamTitle: UILabel! {
        didSet {
            teamTitle.text = NSLocalizedString("CHALLENGE_DETAILS_TAB_SECTION_TEAM_TITLE", comment: "Title for challenge team participant section.")
        }
    }
    @IBOutlet weak var individualsTitle: UILabel! {
        didSet {
            individualsTitle.text = NSLocalizedString("CHALLENGE_DETAILS_TAB_SECTION_INDIVIDUAL_TITLE", comment: "Title for challenge individual participant section.")
        }
    }
    @IBOutlet weak var prizesTitle: UILabel! {
        didSet {
            prizesTitle.text = NSLocalizedString("CHALLENGE_DETAILS_TAB_SECTION_PRIZES_TITLE", comment: "Title for challenge prizes section.")
        }
    }
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var durationText: UILabel!
    @IBOutlet weak var typeText: UILabel!
    @IBOutlet weak var teamCountText: UILabel!
    @IBOutlet weak var individualCountText: UILabel!
    @IBOutlet weak var descriptionView: UIView!
    
    @IBOutlet weak var teamCountView: UIView!
    @IBOutlet weak var participantIcon: UILabel!
    @IBOutlet weak var participantCountView: UIView!
    @IBOutlet weak var participantRowView: UIView!
    @IBOutlet weak var termsButton: UIButton! {
        didSet {
            termsButton.setTitle(NSLocalizedString("CHALLENGE_DETAILS_TAB_SECTION_TERMS_BUTTON_TITLE", comment: "Title for button which shows challenge terms."), forState: .Normal)
        }
    }
    @IBOutlet weak var prizesContainer: UIView!
    @IBOutlet weak var teamCountSubview: UIView!
    @IBOutlet weak var participantCountSubView: UIView!
 }