import Foundation

class ChatterInputViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textInput: UITextField!
    
    var parent: ChallengeDetailsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
//        self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
        var backButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton;
        backButton.setBackgroundImage(UIImage(named: "btn_back_black.png"), forState: UIControlState.Normal);
        backButton.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside);
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        var backBarItem = UIBarButtonItem(customView: backButton);
        self.navigationItem.leftBarButtonItem = backBarItem;
        self.navigationItem.hidesBackButton = true;
        self.title = "Enter Chatter";
        
        textInput.delegate = self;
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        parent.userChatter = textField.text;
        self.dismissViewControllerAnimated(false, completion: nil);
        return true;
    }
    
    func goBack(sender: AnyObject!) {
        self.navigationController!.popViewControllerAnimated(true);
    }
}