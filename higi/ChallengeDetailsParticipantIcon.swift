import Foundation

final class ChallengeDetailsParticipantIcon: UIView {
    
    @IBOutlet weak var count:UILabel!;
    @IBOutlet weak var icon:UILabel!;
    @IBOutlet weak var unit: UILabel! {
        didSet {
            unit.text = NSLocalizedString("CHALLENGE_DETAILS_PARTICIPANT_ICON_LABEL_UNITS", comment: "Text label for challenge detail participant icon units.")
        }
    }
    
}