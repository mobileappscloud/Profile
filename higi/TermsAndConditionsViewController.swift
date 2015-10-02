import Foundation

class TermsAndConditionsViewController: UIViewController, UIWebViewDelegate {
    
    var parent:ChallengeDetailsViewController!;
    var html:String!;
    var joinUrl: String!;
    var responseRequired = false;
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!;
    
    @IBAction func acceptClick(sender: AnyObject) {
        parent.joinAccepted = true;
        self.dismissViewControllerAnimated(false, completion: {
            self.parent.joinChallenge(self.joinUrl);
        });
    }
    
    @IBAction func declineClick(sender: AnyObject) {
        parent.joinAccepted = false;
        self.dismissViewControllerAnimated(false, completion: nil);
    }
    
    @IBAction func closeButtonClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil);
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait;
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        if (responseRequired) {
            closeButton.hidden = true;
            acceptButton.hidden = false;
            declineButton.hidden = false;
        } else {
            acceptButton.hidden = true;
            declineButton.hidden = true;
        }
        
        webView.loadHTMLString(html, baseURL: nil)
    }
}