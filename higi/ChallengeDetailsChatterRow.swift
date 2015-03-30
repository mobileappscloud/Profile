import Foundation

class ChallengeDetailsChatterRow: UITableViewCell {
    
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var chatBubble: UIImageView!
    @IBOutlet weak var yourChatBubble: UIImageView!
    @IBOutlet weak var yourAvatar: UIImageView!
    
    override func layoutSubviews() {
        message.frame.size.width = chatView.frame.size.width - 10;
        message.frame.size.height = Utility.heightForTextView(chatView.frame.size.width - 10, text: message.text!, fontSize: 12, margin: 20);
        message.sizeToFit();
        time.sizeToFit();
        var timeFrame = time.frame;
        chatView.frame.size.height = time.frame.origin.y;
    }
    
    class func instanceFromNib(comment: String, participant: ChallengeParticipant, timeSincePosted: String, isYou: Bool, isTeam: Bool) -> ChallengeDetailsChatterRow {
        let row = UINib(nibName: "ChallengeDetailsChatterRow", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeDetailsChatterRow;
        if (isYou) {
            row.yourAvatar.setImageWithURL(Utility.loadImageFromUrl(participant.imageUrl));
            row.chatBubble.hidden = true;
            row.yourChatBubble.hidden = false;
            row.displayName.textColor = UIColor.whiteColor();
            row.message.textColor = UIColor.whiteColor();
            row.yourChatBubble.image = UIImage(named: "chat_bubble_green")!.resizableImageWithCapInsets(UIEdgeInsets(top: 17, left: 19, bottom: 18, right: 32));
            row.message.textAlignment = NSTextAlignment.Right;
            row.time.textAlignment = NSTextAlignment.Right;
            row.displayName.textAlignment = NSTextAlignment.Right;
            row.time.textColor = Utility.colorFromHexString("#DDDDDD");
        } else {
            row.avatar.setImageWithURL(Utility.loadImageFromUrl(participant.imageUrl));
            row.yourChatBubble.hidden = true;
            row.chatBubble.hidden = false;
            row.chatBubble.image = UIImage(named: "chat_bubble")!.resizableImageWithCapInsets(UIEdgeInsets(top: 19, left: 31, bottom: 23, right: 19));
            row.message.textAlignment = NSTextAlignment.Left;
        }
        if (isTeam) {
            row.displayName.text = "\(participant.displayName) - [\(participant.team.name)]";
        } else {
            row.displayName.text = participant.displayName;
        }
        row.message.text = comment;
        row.message.sizeToFit();
        row.time.text = timeSincePosted;
        let beforeFrame = row.time.frame;
        row.time.sizeToFit();
        var timeFrame = row.time.frame;
        row.frame.size.height = row.time.frame.origin.y;
        return row;
    }
    
    class func heightForIndex(comment: Comments) -> CGFloat {
        let labelHeight:CGFloat = 22;
        let topMargin:CGFloat = 4;
        let bottomMargin:CGFloat = 10;
        let messageMargin:CGFloat = 10;
        let messageWidth:CGFloat = 164;
        return labelHeight + topMargin + Utility.heightForTextView(messageWidth, text: comment.comment, fontSize: 12, margin: messageMargin) + labelHeight + bottomMargin;
    }
}