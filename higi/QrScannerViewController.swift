import AVFoundation
import CoreVideo
import CoreMedia

class QrScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var instructionLabel: UILabel! {
        didSet {
            instructionLabel.text = NSLocalizedString("QR_SCANNER_VIEW_INSTRUCTION_LABEL_TEXT", comment: "Text instructing user to scan QR code.");
        }
    }
    @IBOutlet weak var explanatoryLabel: UILabel! {
        didSet {
            explanatoryLabel.text = NSLocalizedString("QR_SCANNER_VIEW_EXPLANATORY_LABEL_TEXT", comment: "Text offering user a chance to view an explanation of QR scanned check-ins.");

        }
    }
    @IBOutlet weak var blankStateErrorTitle: UILabel! {
        didSet {
            blankStateErrorTitle.text = NSLocalizedString("QR_SCANNER_VIEW_BLANK_STATE_ERROR_TITLE", comment: "Title for blank state error.");
        }
    }
    @IBOutlet weak var blankStateErrorMessage: UILabel! {
        didSet {
            blankStateErrorMessage.text = NSLocalizedString("QR_SCANNER_VIEW_BLANK_STATE_ERROR_MESSAGE", comment: "Message for blank state error.");
        }
    }
    @IBOutlet weak var blankStateLayer: UIView!
    @IBOutlet weak var userLayer: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var settingsButton: UIButton! {
        didSet {
            settingsButton.setTitle(NSLocalizedString("QR_SCANNER_VIEW_SETTINGS_BUTTON_TITLE", comment: "Title for settings button on QR Scanner view."), forState: .Normal);
        }
    }
    
    var captureSession:AVCaptureSession?;
    
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?;
    
    var fakeNavBar:UIView!;
    
    let navBarHeight:CGFloat = 64;
    
    var invalidQrAlert:UIAlertView!;
    
    var readingQrInput = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        self.title = NSLocalizedString("QR_SCANNER_VIEW_TITLE", comment: "Title for QR Scanner view.")
        
        initBackButton();
        infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "infoClicked:"));
        
        let title = NSLocalizedString("QR_SCANNER_VIEW_INVALID_QR_ALERT_TITLE", comment: "Title for alert displayed when an invalid QR code is scanned.")
        let message = NSLocalizedString("QR_SCANNER_VIEW_INVALID_QR_ALERT_MESSAGE", comment: "Message for alert displayed when an invalid QR code is scanned.")
        let dismissTitle = NSLocalizedString("QR_SCANNER_VIEW_INVALID_QR_ALERT_ACTION_TITLE_DISMISS", comment: "Title for action to dismiss alert displayed when an invalid QR code is scanned.")
        invalidQrAlert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: dismissTitle);
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        checkPermissionsAndInitScanner();
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        captureSession?.stopRunning();
    }
    
    func initBackButton() {
        let backButton = UIButton(type: UIButtonType.Custom);
        backButton.setBackgroundImage(UIImage(named: "btn_back_white.png"), forState: UIControlState.Normal);
        backButton.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside);
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        let backBarItem = UIBarButtonItem(customView: backButton);
        self.navigationItem.leftBarButtonItem = backBarItem;
        self.navigationItem.hidesBackButton = true;
    }
    
    func checkPermissionsAndInitScanner() {
        if AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) ==  AVAuthorizationStatus.Authorized {
            initVideoCapture();
        } else {
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
                if granted == true {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.initVideoCapture();
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.showBlankState();
                    });
                }
            });
        }
    }
    
    func initVideoCapture() {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo);
        var error:NSError?;
        let deviceInput: AnyObject!
        do {
            deviceInput = try AVCaptureDeviceInput(device: device)
        } catch let error1 as NSError {
            error = error1
            deviceInput = nil
        };
        if error != nil {
            let title = NSLocalizedString("QR_SCANNER_VIEW_UNSUPPORTED_DEVICE_ALERT_TITLE", comment: "Title for alert displayed when an unsupported device is detected.")
            let message = NSLocalizedString("QR_SCANNER_VIEW_UNSUPPORTED_DEVICE_ALERT_MESSAGE", comment: "Message for alert displayed when an unsupported device is detected")
            let dismissTitle = NSLocalizedString("QR_SCANNER_VIEW_UNSUPPORTED_DEVICE_ALERT_ACTION_TITLE_DISMISS", comment: "Title for action to dismiss alert displayed when an unsupported device is detected")
            UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: dismissTitle).show();
        } else {
            captureSession = AVCaptureSession();
            captureSession?.addInput(deviceInput as! AVCaptureInput);
            let captureMetadataOutput = AVCaptureMetadataOutput();
            captureSession?.addOutput(captureMetadataOutput);
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue());
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode];
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill;
            videoPreviewLayer?.frame = view.layer.bounds;
            videoPreviewLayer?.frame.origin.y = navBarHeight;
            videoPreviewLayer?.frame.size.height = view.layer.bounds.size.height - navBarHeight;
            self.view.layer.addSublayer(videoPreviewLayer!);
            captureSession?.startRunning();
            view.bringSubviewToFront(userLayer);
        }
    }
    
    func showBlankState() {
        //it is impossible to actually send the user to the settings app before iOS8
        if (UIDevice.currentDevice().systemVersion < "8.0") {
            self.settingsButton.hidden = true;
        }
        self.blankStateLayer.hidden = false;
        self.userLayer.hidden = true;
    }

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if !readingQrInput && metadataObjects != nil && metadataObjects.count > 0 {
            let output = metadataObjects[0] as! AVMetadataMachineReadableCodeObject;
            if output.type == AVMetadataObjectTypeQRCode {
                if let code = output.stringValue {
                    if performQrAction(code) {
                        readingQrInput = true;
                        goBack(nil);
                    }
                }
            }
        }
    }
    
    func performQrAction(code:String) -> Bool {
        switch(Array(code.characters)[0]) {
        case "0":
            self.attemptCheckInResultUpload(code);
            return true;

        case "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "-", ":", "$", " ", "*":
            if !invalidQrAlert.visible {
                invalidQrAlert.show();
            }
        default:
            if !invalidQrAlert.visible {
                invalidQrAlert.show();
            }
        }
        return false;
    }
    
    func attemptCheckInResultUpload(code: String) {
        dispatch_async(dispatch_get_main_queue(), {
            let title = NSLocalizedString("QR_SCANNER_VIEW_CHECK_IN_UPLOADING_ALERT_TITLE", comment: "Title for alert displayed when a check-in upload begins.");
            let message = NSLocalizedString("QR_SCANNER_VIEW_CHECK_IN_UPLOADING_ALERT_MESSAGE", comment: "Message for alert displayed when a check-in upload begins.");
            let dismissTitle = NSLocalizedString("QR_SCANNER_VIEW_CHECK_IN_UPLOADING_ALERT_ACTION_TITLE_DISMISS", comment: "Title for action to dismiss alert displayed when a check-in upload begins.");
            UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: dismissTitle).show();
        });
        SessionController.Instance.showQrCheckinCard = true;
        self.sendCheckinResults(code);
    }
    
    func sendCheckinResults(code:String) {
        let userId = SessionData.Instance.user.userId;
        let contents = NSMutableDictionary();
        contents["qrValue"] = code;
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
            HigiApi().sendPost("\(HigiApi.higiApiUrl)/data/user/\(userId)/qrCheckin", parameters: contents, success: { (operation, responseObject) in
                self.clearNotification();
                let notification = NSLocalizedString("LOCAL_NOTIFICATION_SCANNED_CHECK_IN_SUCCESS_MESSAGE", comment: "Message to display via local notification when a scanned check-in is successfully uploaded.");
                self.showNotification(notification);
                NSNotificationCenter.defaultCenter().postNotificationName(ApiUtility.QR_CHECKIN, object: nil, userInfo: ["success": true]);
                }, failure: { (operation, error) in
                    if operation.response.statusCode != 400 {
                        self.clearNotification();
                        let notification = NSLocalizedString("LOCAL_NOTIFICATION_SCANNED_CHECK_IN_ISSUE_MESSAGE", comment: "Message to display via local notification when a scanned check-in encounters an issue while being uploaded.");
                        self.showNotification(notification);
                        NSNotificationCenter.defaultCenter().postNotificationName(ApiUtility.QR_CHECKIN, object: nil, userInfo: ["success": false]);
                    } else {
                        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(10 * Double(NSEC_PER_SEC)))
                        dispatch_after(delayTime, dispatch_get_main_queue()) {
                            self.sendCheckinResults(code);
                        }
                    }
            });
        };
    }
    
    func requestMobileLoginCode(code:String) {
        
    }
    
    func showNotification(message: String) {
        dispatch_async(dispatch_get_main_queue(), {
            let notification = UILocalNotification();
            notification.fireDate = NSDate();
            notification.alertBody = message;
            notification.applicationIconBadgeNumber = -1;
            notification.userInfo = ["ID": 99];
            UIApplication.sharedApplication().scheduleLocalNotification(notification);
        });
    }
    
    func clearNotification() {
        dispatch_async(dispatch_get_main_queue(), {
            UIApplication.sharedApplication().cancelAllLocalNotifications();
        });
    }
    
    func goBack(sender: AnyObject!) {
        if let nav = self.navigationController {
            nav.popViewControllerAnimated(false);
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        goBack(self);
    }
    
    @IBAction func settingsButtonClick(sender: AnyObject) {
        if (UIDevice.currentDevice().systemVersion >= "8.0") {
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!);
        }
    }
    
    func infoClicked(sender: AnyObject) {
        let title = NSLocalizedString("QR_SCANNER_VIEW_EXPLANATION_ALERT_TITLE", comment: "Title for alert displayed when a user requests more info about scanned check-ins.");
        let message = NSLocalizedString("QR_SCANNER_VIEW_EXPLANATION_ALERT_MESSAGE", comment: "Message for alert displayed when a user requests more info about scanned check-ins.");
        let dismissTitle = NSLocalizedString("QR_SCANNER_VIEW_EXPLANATION_ALERT_ACTION_TITLE_DISMISS", comment: "Title for action to dismiss alert displayed when a user requests more info about scanned check-ins.");
        UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: dismissTitle).show();
    }
}