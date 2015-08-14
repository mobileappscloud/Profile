import AVFoundation
import CoreVideo
import CoreMedia

class QrScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession:AVCaptureSession?;
    
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?;
    
    var qrCodeFrameView:UIView?;
    
    @IBOutlet weak var messageLabel: UILabel!
    
    var fakeNavBar:UIView!;
    
    let navBarHeight:CGFloat = 64;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        self.title = "Scan QR Code";
        
        initBackButton();
        initVideoCapture();
        initPreviewLayer();
        initQrView();
        view.bringSubviewToFront(messageLabel);
    }
    
    func initBackButton() {
        var backButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton;
        backButton.setBackgroundImage(UIImage(named: "btn_back_white.png"), forState: UIControlState.Normal);
        backButton.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside);
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        var backBarItem = UIBarButtonItem(customView: backButton);
        self.navigationItem.leftBarButtonItem = backBarItem;
        self.navigationItem.hidesBackButton = true;
    }
    
    func initVideoCapture() {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo);
        var error:NSError?;
        let deviceInput: AnyObject! = AVCaptureDeviceInput.deviceInputWithDevice(device, error: &error);
        if (error != nil) {
            var alertView:UIAlertView = UIAlertView(title: "Device Error", message: "Device not Supported for this Application", delegate: nil, cancelButtonTitle: "Ok Done");
            alertView.show();
            return;
        }
        captureSession = AVCaptureSession();
        captureSession?.addInput(deviceInput as! AVCaptureInput);
        let captureMetadataOutput = AVCaptureMetadataOutput();
        captureSession?.addOutput(captureMetadataOutput);
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue());
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode];
    }
    
    func initPreviewLayer() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill;
        videoPreviewLayer?.frame = view.layer.bounds;
        videoPreviewLayer?.frame.origin.y = navBarHeight;
        videoPreviewLayer?.frame.size.height = view.layer.bounds.size.height - navBarHeight - messageLabel.frame.size.height;
        self.view.layer.addSublayer(videoPreviewLayer);
        captureSession?.startRunning();
    }
    
    func initQrView() {
        qrCodeFrameView = UIView();
        qrCodeFrameView?.layer.borderColor = Utility.colorFromHexString("#76C043").CGColor;
        qrCodeFrameView?.layer.borderWidth = 5;
        view.addSubview(qrCodeFrameView!);
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        captureSession?.startRunning();
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        captureSession?.stopRunning();
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRectZero;
            messageLabel.text = "No QR code is detected";
        } else {
            let output = metadataObjects[0] as! AVMetadataMachineReadableCodeObject;
            if (output.type == AVMetadataObjectTypeQRCode) {
                let qrCode = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(output as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject;
                qrCodeFrameView?.frame = qrCode.bounds;
                if (output.stringValue != nil) {
                    let code = output.stringValue;
                    messageLabel.text = code;
                    //TODO do something with code
                    //goBack(self);
                }
            }
        }
    }
    
    func goBack(sender: AnyObject!) {
        self.dismissViewControllerAnimated(false, completion: nil);
    }
}