import Foundation

class ChallengeDetailsChatterRow: UITableViewCell {
    
    
    @IBOutlet weak var chattBubble: UIView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var time: UILabel!
    
    override func layoutSubviews() {
        message.frame.size.width = chattBubble.frame.size.width - 10;
        message.frame.size.height = Utility.heightForTextView(chattBubble.frame.size.width - 10, text: message.text!, fontSize: 12, margin: 20);
        message.sizeToFit();
    }
    
    class func instanceFromNib(comment: Comments) -> ChallengeDetailsChatterRow {
        let row = UINib(nibName: "ChallengeDetailsChatterRow", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeDetailsChatterRow;
        row.avatar.setImageWithURL(Utility.loadImageFromUrl(comment.participant.imageUrl));
        row.displayName.text = comment.participant.displayName;
        row.message.text = comment.comment;
        row.time.text = comment.timeSincePosted;
//        row.chattBubble.b
        return row;
    }
    
    class func heightForIndex(comment: Comments) -> CGFloat {
        return Utility.heightForTextView(200, text: comment.comment, fontSize: 12, margin: 0);
    }
}