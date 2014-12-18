import Foundation

class ChallengeInvitationView: UIView {
    
    @IBOutlet var inviter: UILabel!
    @IBOutlet var title: UILabel!
    @IBOutlet var starting: UILabel!
    @IBOutlet var type: UILabel!
    @IBOutlet var goal: UILabel!
    @IBOutlet var prize: UILabel!
    @IBOutlet var dateRange: UILabel!
    @IBOutlet var participantCount: UILabel!
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var challengeLogo: UIImageView!
    @IBOutlet var startingIcon: UIImageView!
    @IBOutlet var dateRangeIcon: UIImageView!
    @IBOutlet var participantCountIcon: UIImageView!
    
    
    class func instanceFromNib() -> ChallengeInvitationView {
        return UINib(nibName: "ChallengeInvitationView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeInvitationView
    }
}