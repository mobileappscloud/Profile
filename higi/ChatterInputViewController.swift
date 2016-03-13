import Foundation

class ChatterInputViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textInput: UITextView!
    
    var parent: ChallengeDetailsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.title = NSLocalizedString("CHATTER_INPUT_VIEW_CONTROLLER_TITLE", comment: "Title for chatter input view controller.")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: Selector("goBack:"))
        
        textInput.text = NSLocalizedString("CHATTER_INPUT_VIEW_TEXT_INPUT_PLACEHOLDER", comment: "Placeholder text to display in chatter input text field.");
        textInput.textColor = UIColor.lightGrayColor();
        textInput.delegate = self;
        textInput.becomeFirstResponder();
        textInput.selectedTextRange = textInput.textRangeFromPosition(textInput.beginningOfDocument, toPosition: textInput.beginningOfDocument);
    }
    
    func goBack(sender: AnyObject!) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let currentText:NSString = textView.text;
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text);
        if (text == "\n") {
            let placeholderText = NSLocalizedString("CHATTER_INPUT_VIEW_TEXT_INPUT_PLACEHOLDER", comment: "Placeholder text to display in chatter input text field.");
            if (textView.text != placeholderText) {
                textView.resignFirstResponder();
                parent.userChatter = textView.text;
                self.dismissViewControllerAnimated(false, completion: nil);
                
            }
            return false;
        } else if (updatedText.characters.count == 0) {
            textView.text = NSLocalizedString("CHATTER_INPUT_VIEW_TEXT_INPUT_PLACEHOLDER", comment: "Placeholder text to display in chatter input text field.");
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