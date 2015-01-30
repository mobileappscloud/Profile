import Foundation

class ChallengeDetailsChatterRow: UITableViewCell {
    
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var chatBubble: UIImageView!
    @IBOutlet weak var yourChatBuble: UIImageView!
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
            row.yourChatBuble.hidden = false;
        } else {
            row.avatar.setImageWithURL(Utility.loadImageFromUrl(participant.imageUrl));
            row.yourChatBuble.hidden = true;
            row.chatBubble.hidden = false;
        }
        row.displayName.text = participant.displayName;
        row.message.text = comment;
        row.time.text = timeSincePosted;

        return row;
    }
    
    class func heightForIndex(comment: Comments) -> CGFloat {
        return Utility.heightForTextView(200, text: comment.comment, fontSize: 12, margin: 50);
    }
}