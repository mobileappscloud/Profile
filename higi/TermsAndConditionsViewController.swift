import Foundation

class TermsAndConditionsViewController: UIViewController, UIWebViewDelegate {
    
    var html:String!;
    var responseRequired = false;
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var closeButton: UIButton!;
    
    @IBAction func closeButtonClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        if (responseRequired) {
            closeButton.hidden = true;
        } else {
            
        }
        
        webView.loadHTMLString(html, baseURL: nil)
    }
}