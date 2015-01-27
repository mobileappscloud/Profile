import Foundation

class ChallengeDetailsPrize: UIView {
    
    class func instanceFromNib(count: Int, isTeam: Bool) -> ChallengeDetailsPrize {
        var prize = UINib(nibName: "ChallengeDetailsPrize", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeDetailsPrize;
        
        return prize;
    }
}