import Foundation

class ChallengeDetailsIcons: UIView {
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var icon: UILabel!
    
    class func instanceFromNib(count: Int, isTeam: Bool) -> ChallengeDetailsIcons {
        var icons = UINib(nibName: "ChallengeDetailsIcons", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeDetailsIcons;
        
        icons.icon.text = isTeam ? "\u{f0c0}" : "\u{f007}"
        icons.typeLabel.text = isTeam ? "Teams" : "Individuals";
        icons.count.text = String(count);
        return icons;
    }
}