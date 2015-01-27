import Foundation

class ChallengeDetailsPrize: UIView {
    
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var title: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews();
        title.sizeToFit();
        desc.sizeToFit();
    }
    class func instanceFromNib(winCondition: ChallengeWinCondition) -> ChallengeDetailsPrize {
        var prize = UINib(nibName: "ChallengeDetailsPrizes", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeDetailsPrize;
        
        prize.title.text = winCondition.prizeName;
        prize.desc.text = winCondition.description;
        return prize;
    }
}