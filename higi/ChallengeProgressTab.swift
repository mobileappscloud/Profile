import Foundation

class ChallengeProgressTab: UITableViewCell {


    class func instanceFromNib(challenge: HigiChallenge) -> ChallengeProgressTab {
        let tab = UINib(nibName: "ChallengeProgressTab", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeProgressTab;
        return tab;
    }
}