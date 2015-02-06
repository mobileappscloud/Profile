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
    }
    
    class func instanceFromNib(comment: String, participant: ChallengeParticipant, timeSincePosted: String, isYou: Bool) -> ChallengeDetailsChatterRow {
        let row = UINib(nibName: "ChallengeDetailsChatterRow", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeDetailsChatterRow;
        if (isYou) {
            row.yourAvatar.setImageWithURL(Utility.loadImageFromUrl(participant.imageUrl));
            row.chatBubble.hidden = true;
            row.yourChatBubble.hidden = false;
            row.displayName.textColor = UIColor.whiteColor();
            row.message.textColor = UIColor.whiteColor();
            row.yourChatBubble.image = row.yourChatBubble.image!.resizableImageWithCapInsets(UIEdgeInsets(top: 17, left: 19, bottom: 26, right: 31));
            row.message.textAlignment = NSTextAlignment.Right;
        } else {
            row.avatar.setImageWithURL(Utility.loadImageFromUrl(participant.imageUrl));
            row.yourChatBubble.hidden = true;
            row.chatBubble.hidden = false;
            row.chatBubble.image = row.chatBubble.image!.resizableImageWithCapInsets(UIEdgeInsets(top: 19, left: 31, bottom: 27, right: 49));
            row.message.textAlignment = NSTextAlignment.Left;
        }
        row.displayName.text = participant.displayName;
        row.message.text = comment;
        row.message.sizeToFit();
        row.time.text = timeSincePosted;
        row.time.sizeToFit();
        var timeFrame = row.time.frame;
        row.frame.size.height = row.time.frame.origin.y;
        return row;
    }
    
    class func heightForIndex(comment: Comments) -> CGFloat {
        return Utility.heightForTextView(200, text: comment.comment, fontSize: 12, margin: 50);
    }
}