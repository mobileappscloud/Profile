import Foundation

class ChatterInputViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var navBar: UINavigationItem!

    @IBOutlet weak var textInput: UITextView!
    var parent: ChallengeDetailsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad();
//        let a = (self.navigationController as MainNavigationController);
//        let b = (self.navigationController as MainNavigationController).revealController;
//        let c = (self.navigationController as MainNavigationController).revealController.panGestureRecognizer();
//        (self.navigationController as MainNavigationController).revealController.panGestureRecognizer().enabled = false;
        var backButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton;
        backButton.setBackgroundImage(UIImage(named: "btn_back_white.png"), forState: UIControlState.Normal);
        backButton.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside);
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        var backBarItem = UIBarButtonItem(customView: backButton);
        navBar.leftBarButtonItem = backBarItem;
//        self.navigationItem.leftBarButtonItem = backBarItem;
//        self.title = "Enter Chatter";
        
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
        let a = textView.textColor == UIColor.lightGrayColor();
        let b = countElements(updatedText);
        
        if (text == "\n") {
            textView.resignFirstResponder();
            parent.userChatter = textView.text;
            self.dismissViewControllerAnimated(false, completion: nil);
            return false;
        } else if (countElements(updatedText) == 0) {
            textView.text = "Talk some smack!";
            textView.textColor = UIColor.lightGrayColor();
            textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            return false;
        } else if (textView.textColor == UIColor.lightGrayColor() && countElements(text) > 0) {
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