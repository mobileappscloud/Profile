import Foundation

class TermsAndConditionsViewController: UIViewController, UIWebViewDelegate {
    
    var parent:ChallengeDetailsViewController!;
    var html:String!;
    var joinUrl: String!;
    var responseRequired = false;
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var acceptButton: UIButton! {
        didSet {
            acceptButton.setTitle(NSLocalizedString("TERMS_AND_CONDITIONS_VIEW_ACCEPT_BUTTON_TITLE", comment: "Title for button to accept terms."), forState: .Normal)
        }
    }
    @IBOutlet weak var declineButton: UIButton! {
        didSet {
            declineButton.setTitle(NSLocalizedString("TERMS_AND_CONDITIONS_VIEW_DECLINE_BUTTON_TITLE", comment: "Title for button to decline terms."), forState: .Normal)
        }
    }
    @IBOutlet weak var closeButton: UIButton! {
    didSet {
            closeButton.setTitle(NSLocalizedString("TERMS_AND_CONDITIONS_VIEW_CLOSE_BUTTON_TITLE", comment: "Title for button to close Terms view."), forState: .Normal)
        }
    }
    
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