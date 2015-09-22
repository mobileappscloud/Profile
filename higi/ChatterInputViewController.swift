import Foundation

class ChatterInputViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var navBar: UINavigationItem!

    @IBOutlet weak var textInput: UITextView!
    var parent: ChallengeDetailsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        let backButton = UIButton(type: UIButtonType.Custom);
        backButton.setBackgroundImage(UIImage(named: "btn_back_white.png"), forState: UIControlState.Normal);
        backButton.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside);
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        let backBarItem = UIBarButtonItem(customView: backButton);
        navBar.leftBarButtonItem = backBarItem;
        
        textInput.text = "Talk some smack!";
        textInput.textColor = UIColor.lightGrayColor();
        textInput.delegate = self;
        textInput.becomeFirstResponder();
        textInput.selectedTextRange = textInput.textRangeFromPosition(textInput.beginningOfDocument, toPosition: textInput.beginningOfDocument);
    }
    
    func goBack(sender: AnyObject!) {
        self.dismissViewControllerAnimated(false, completion: nil);
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let currentText:NSString = textView.text;
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text);
        if (text == "\n") {
            if (textView.text != "Talk some smack!") {
                textView.resignFirstResponder();
                parent.userChatter = textView.text;
                self.dismissViewControllerAnimated(false, completion: nil);
                
            }
            return false;
        } else if (updatedText.characters.count == 0) {
            textView.text = "Talk some smack!";
            textView.textColor = UIColor.lightGrayColor();
            textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            return false;
        } else if (textView.textColor == UIColor.lightGrayColor() && text.characters.count > 0) {
            textView.text = "";
            textView.textColor = UIColor.blackColor();
        }
        return true;
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        if (textView.textColor == UIColor.lightGrayColor()) {
            textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
        }
    }
}