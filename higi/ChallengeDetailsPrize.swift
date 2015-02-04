import Foundation

class ChallengeDetailsPrize: UITableViewCell {
    
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var title: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews();
        title.sizeToFit();
        desc.sizeToFit();
    }
    
    class func instanceFromNib(winCondition: ChallengeWinCondition) -> ChallengeDetailsPrize {
        var prize = UINib(nibName: "ChallengeDetailsPrizes", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeDetailsPrize;
        
        if (winCondition.prizeName != nil && winCondition.prizeName != "") {
            prize.title.text = winCondition.prizeName;
        } else if (winCondition.name != nil && winCondition.name != "") {
            prize.title.text = winCondition.name;
        } else {
            prize.title.text = "No prize, doing this simply for the love of the game.";
        }
        prize.title.text = winCondition.name;
        prize.desc.text = winCondition.prizeName;
        return prize;
    }
}