import Foundation
import WebKit

final class TermsAndConditionsViewController: UIViewController {
    
    weak var parent:ChallengeDetailsViewController!;
    var html:String!;
    var joinUrl: String!;
    var responseRequired = false;
    
    @IBOutlet var webView: WKWebView!
    @IBOutlet var acceptButton: UIButton! {
        didSet {
            acceptButton.setTitle(NSLocalizedString("TERMS_AND_CONDITIONS_VIEW_ACCEPT_BUTTON_TITLE", comment: "Title for button to accept terms."), forState: .Normal)
        }
    }
    @IBOutlet var declineButton: UIButton! {
        didSet {
            declineButton.setTitle(NSLocalizedString("TERMS_AND_CONDITIONS_VIEW_DECLINE_BUTTON_TITLE", comment: "Title for button to decline terms."), forState: .Normal)
        }
    }
    @IBOutlet var closeButton: UIButton! {
    didSet {
            closeButton.setTitle(NSLocalizedString("TERMS_AND_CONDITIONS_VIEW_CLOSE_BUTTON_TITLE", comment: "Title for button to close Terms view."), forState: .Normal)
        }
    }
    
    @IBAction func acceptClick(sender: AnyObject) {
        parent.joinAccepted = true;
        self.dismissViewControllerAnimated(true, completion: {
            self.parent.joinChallenge();
        });
    }
    
    @IBAction func declineClick(sender: AnyObject) {
        parent.joinAccepted = false;
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    @IBAction func closeButtonClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);
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