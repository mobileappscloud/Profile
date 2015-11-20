import Foundation

class ConnectDeviceRow: UITableViewCell, UIAlertViewDelegate {

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
        // TODO: Don't switch on hardcoded device name
        if device.name == "higi" {
            if !PersistentSettingsController.boolForKey(.DidShowActivityTrackerAuthorizationRequest) {
                HealthKitManager.requestReadAccessToStepData( { (didRespond, error) in
                    if didRespond {
                        HealthKitManager.hasReadAccessToStepData({ [weak self] (isAuthorized) in
                            if isAuthorized {
                                HealthKitManager.enableBackgroundUpdates()
                            } else {
                                HealthKitManager.disableBackgroundUpdates()
                                dispatch_async(dispatch_get_main_queue(), {
                                    self?.connectedToggle.on = false
                                })
                            }
                        })
                    }
                })
            } else {
                let title = NSLocalizedString("CONNECT_DEVICE_ROW_CONNECT_HEALTHKIT_ALERT_TITLE", comment: "Title for alert displayed when user toggles switch to connect branded activity tracker (HealthKit) ON.")
                let message = NSLocalizedString("CONNECT_DEVICE_ROW_CONNECT_HEALTHKIT_ALERT_MESSAGE", comment: "Message for alert displayed when user toggles switch to connect branded activity tracker (HealthKit) ON.")
                let dismissActionTitle = NSLocalizedString("CONNECT_DEVICE_ROW_CONNECT_HEALTHKIT_ALERT_ACTION_ACKNOWLEDGE_ACTION", comment: "Title for alert action to acknowledge alert displayed when user toggles switch to connect branded activity tracker (HealthKit) ON.")
                let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                let dismissAction = UIAlertAction(title: dismissActionTitle, style: .Default, handler: { [weak self] (action) in
                    dispatch_async(dispatch_get_main_queue(), {
                        self?.connectedToggle.on = false
                    })
                    })
                alert.addAction(dismissAction)
                self.parentController.presentViewController(alert, animated: true, completion: nil)
            }
        } else {
            self.device.connected = true;
            webView = WebViewController(nibName: "WebView", bundle: nil);
            webView.url = "\(HigiApi.webUrl)/mobileDeviceConnect";
            
            let headers = ["Higi-Device-Connect-Url": device.connectUrl!.stringByReplacingOccurrencesOfString("{redirect}", withString: "https://www.google.com".stringByReplacingPercentEscapesUsingEncoding(16)!) as String!, "User-Id": SessionData.Instance.user.userId as String!, "Token": SessionData.Instance.token as String!];
            webView.headers = headers;
            webView.device = device;
            parentController.pushViewController(webView, animated: true);
        }
    }
    
    func disconnectDevice() {
        // TODO: Don't switch on hardcoded device name
        if device.name == "higi" {
            let title = NSLocalizedString("CONNECT_DEVICE_ROW_DISCONNECT_HEALTHKIT_ALERT_TITLE", comment: "Title for alert displayed when user toggles switch to connect branded activity tracker (HealthKit) OFF.")
            let message = NSLocalizedString("CONNECT_DEVICE_ROW_DISCONNECT_HEALTHKIT_ALERT_MESSAGE", comment: "Message for alert displayed when user toggles switch to connect branded activity tracker (HealthKit) OFF.")
            let dismissActionTitle = NSLocalizedString("CONNECT_DEVICE_ROW_DISCONNECT_HEALTHKIT_ALERT_ACTION_ACKNOWLEDGE_ACTION", comment: "Title for alert action to acknowledge alert displayed when user toggles switch to connect branded activity tracker (HealthKit) OFF.")
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: dismissActionTitle, style: .Default, handler: { [weak self] (action) in
                dispatch_async(dispatch_get_main_queue(), {
                    self?.connectedToggle.on = true
                })
                })
            alert.addAction(dismissAction)
            self.parentController.presentViewController(alert, animated: true, completion: nil)
        } else {
            let title = NSLocalizedString("CONNECT_DEVICE_ROW_REMOVE_DEVICE_ALERT_TITLE", comment: "Title for alert displayed prior to disconnecting a device from a higi Profile.")
            let messageFormat = NSLocalizedString("CONNECT_DEVICE_ROW_REMOVE_DEVICE_ALERT_MESSAGE_FORMAT", comment: "Message for alert displayed prior to disconnecting a device from a higi Profile.")
            let message = String(format: messageFormat, arguments: [device.name])
            let confirmTitle = NSLocalizedString("CONNECT_DEVICE_ROW_REMOVE_DEVICE_ALERT_ACTION_TITLE_YES", comment: "Title for alert action to confirm disconnecting a device from a higi Profile.")
            let declineTitle = NSLocalizedString("CONNECT_DEVICE_ROW_REMOVE_DEVICE_ALERT_ACTION_TITLE_NO", comment: "Title for alert action to decline disconnecting a device from a higi Profile.")
            UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: declineTitle, otherButtonTitles: confirmTitle).show();
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        //index 0 == cancel
        if (buttonIndex == 0) {
            connectedToggle.on = true;
        } else {
            let title = NSLocalizedString("CONNECT_DEVICE_ROW_REMOVE_DEVICE_FAILURE_ALERT_TITLE", comment: "Title for alert displayed after failure to remove/disconnect a device from a higi Profile.")
            let disconnectMessage = NSLocalizedString("CONNECT_DEVICE_ROW_REMOVE_DEVICE_DISCONNECT_FAILURE_ALERT_MESSAGE", comment: "Message for alert displayed after failure to disconnect a device from a higi Profile.")
            let removeMessage = NSLocalizedString("CONNECT_DEVICE_ROW_REMOVE_DEVICE_FAILURE_ALERT_MESSAGE", comment: "Message for alert displayed after failure to remove a device from a higi Profile.")
            let dismissTitle = NSLocalizedString("CONNECT_DEVICE_ROW_REMOVE_DEVICE_FAILURE_ALERT_ACTION_TITLE_DISMISS", comment: "Title for alert action to dismiss device remove/disconnect failure alert.")
            
            if (device.disconnectUrl != nil) {
                self.device.connected = false;
                HigiApi().sendDelete(device.disconnectUrl as! String, parameters: nil, success: nil,
                    failure: { operation, error in
                        self.device.connected = true;
                        self.connectedToggle.on = true;
                        UIAlertView(title: title, message: removeMessage, delegate: self, cancelButtonTitle: dismissTitle).show();
                });
            } else {
                UIAlertView(title: title, message: disconnectMessage, delegate: self, cancelButtonTitle: dismissTitle).show();
            }
        }
    }
}