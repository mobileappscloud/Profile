import Foundation

class ConnectDeviceRow: UITableViewCell {

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.text = ""
        }
    }
    @IBOutlet weak var connectedToggle: UISwitch!
    
    var device:ActivityDevice!;
    var parentController:UINavigationController!;
    var webView:WebViewController!;
    
    @IBAction func deviceSwitchTouch(sender: UISwitch) {
        let connected = sender.on;
        if (connected) {
            connectDevice();
        } else {
            disconnectDevice();
        }
    }
    
    func connectDevice() {
        self.device.connected = true;
        webView = WebViewController(nibName: "WebView", bundle: nil);
        webView.url = "\(HigiApi.webUrl)/mobileDeviceConnect";

        let headers = ["Higi-Device-Connect-Url": device.connectUrl.stringByReplacingOccurrencesOfString("{redirect}", withString: "https://www.google.com".stringByReplacingPercentEscapesUsingEncoding(16)!) as String!, "User-Id": SessionData.Instance.user.userId as String!, "Token": SessionData.Instance.token as String!];
        webView.headers = headers;
        webView.device = device;
        parentController.pushViewController(webView, animated: true);
    }
    
    func disconnectDevice() {
        let title = NSLocalizedString("CONNECT_DEVICE_ROW_REMOVE_DEVICE_ALERT_TITLE", comment: "Title for alert displayed prior to disconnecting a device from a higi Profile.")
        let messageFormat = NSLocalizedString("CONNECT_DEVICE_ROW_REMOVE_DEVICE_ALERT_MESSAGE_FORMAT", comment: "Message for alert displayed prior to disconnecting a device from a higi Profile.")
        let message = String(format: messageFormat, arguments: [device.name])
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let confirmTitle = NSLocalizedString("CONNECT_DEVICE_ROW_REMOVE_DEVICE_ALERT_ACTION_TITLE_YES", comment: "Title for alert action to confirm disconnecting a device from a higi Profile.")
        let confirmAction = UIAlertAction(title: confirmTitle, style: .Default, handler: { [weak self] (action) in
            self?.attemptToDisconnect()
        })
        alertController.addAction(confirmAction)
        let declineTitle = NSLocalizedString("CONNECT_DEVICE_ROW_REMOVE_DEVICE_ALERT_ACTION_TITLE_NO", comment: "Title for alert action to decline disconnecting a device from a higi Profile.")
        let declineAction = UIAlertAction(title: declineTitle, style: .Cancel, handler: { [weak self] (action) in
            self?.connectedToggle.on = true
        })
        alertController.addAction(declineAction)
        
        self.parentController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func attemptToDisconnect() {
        let title = NSLocalizedString("CONNECT_DEVICE_ROW_REMOVE_DEVICE_FAILURE_ALERT_TITLE", comment: "Title for alert displayed after failure to remove/disconnect a device from a higi Profile.")
        let dismissTitle = NSLocalizedString("CONNECT_DEVICE_ROW_REMOVE_DEVICE_FAILURE_ALERT_ACTION_TITLE_DISMISS", comment: "Title for alert action to dismiss device remove/disconnect failure alert.")
        
        if (device.disconnectUrl != nil) {
            self.device.connected = false;
            HigiApi().sendDelete(device.disconnectUrl as String, parameters: nil, success: nil,
                failure: { operation, error in
                    let removeMessage = NSLocalizedString("CONNECT_DEVICE_ROW_REMOVE_DEVICE_FAILURE_ALERT_MESSAGE", comment: "Message for alert displayed after failure to remove a device from a higi Profile.")
                    let alertController = UIAlertController(title: title, message: removeMessage, preferredStyle: .Alert)
                    let dismissAction = UIAlertAction(title: dismissTitle, style: .Default, handler: { [unowned self] (action) in
                        dispatch_async(dispatch_get_main_queue(), {
                            self.device.connected = true;
                            self.connectedToggle.on = true;
                        })
                        })
                    alertController.addAction(dismissAction)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.parentController.presentViewController(alertController, animated: true, completion: nil)
                    })
            });
        } else {
            let disconnectMessage = NSLocalizedString("CONNECT_DEVICE_ROW_REMOVE_DEVICE_DISCONNECT_FAILURE_ALERT_MESSAGE", comment: "Message for alert displayed after failure to disconnect a device from a higi Profile.")
            let alertController = UIAlertController(title: title, message: disconnectMessage, preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: dismissTitle, style: .Default, handler: nil)
            alertController.addAction(dismissAction)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.parentController.presentViewController(alertController, animated: true, completion: nil)
            })
        }
    }
}