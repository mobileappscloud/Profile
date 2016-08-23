import Foundation
import WebKit

final class TermsAndConditionsViewController: UIViewController {
    private weak var delegate: TermsAndConditionsDelegate?
    private var html: String?
    private var responseRequired = false
    
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
        delegate?.acceptTerms(withValue: true)
    }
    
    @IBAction func declineClick(sender: AnyObject) {
        delegate?.acceptTerms(withValue: false)
    }
    
    @IBAction func closeButtonClick(sender: AnyObject) {
        delegate?.closeTerms()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if responseRequired {
            closeButton.hidden = true
            acceptButton.hidden = false
            declineButton.hidden = false
        } else {
            acceptButton.hidden = true
            declineButton.hidden = true
        }
        guard let html = html else {
            return
        }
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    func configure(delegate delegate: TermsAndConditionsDelegate, html: String?, responseRequired: Bool) {
        self.delegate = delegate
        self.html = html
        self.responseRequired = responseRequired
    }
}

protocol TermsAndConditionsDelegate: class {
    func acceptTerms(withValue accepted: Bool)
    func closeTerms()
}
