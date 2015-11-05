import Foundation

class ConnectDeviceViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var headerLabel: UILabel! {
        didSet {
            headerLabel.text = NSLocalizedString("CONNECT_DEVICE_VIEW_HEADER_TEXT", comment: "Text to display in table header on Connect Device view.")
        }
    }
    
    var devices:[ActivityDevice] = [];
    var expandedDeviceDescriptions: Set<NSString> = Set()
    
    var backButton:UIButton!;
    
    var active = false, viewLoading = true;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        (self.navigationController as! MainNavigationController).revealController.panGestureRecognizer().enabled = false;
        backButton = UIButton(type: .Custom);
        backButton.setBackgroundImage(UIImage(named: "btn_back_white.png"), forState: UIControlState.Normal);
        backButton.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside);
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        let backBarItem = UIBarButtonItem(customView: backButton);
        self.navigationItem.leftBarButtonItem = backBarItem;
        self.navigationItem.hidesBackButton = true;
        
        shouldShowDailyPoints = false;
        
        self.title = NSLocalizedString("CONNECT_DEVICE_VIEW_TITLE", comment: "Title for Connect Device view.");
        table.delegate = self;
        table.dataSource = self;
        table.estimatedRowHeight = 70;
        table.registerNib(UINib(nibName: "ConnectDeviceRow", bundle: nil), forCellReuseIdentifier: "ConnectDeviceRow")
        
        populateDevices();
    }
    
    func populateDevices() {
        let serverDevices = SessionController.Instance.devices;
        for (deviceName, device) in serverDevices {
            devices.append(device);
        }
        devices.sortInPlace(sortByConnected);
    }
    
    func sortByConnected(this: ActivityDevice, that: ActivityDevice) -> Bool {
        return this.connected;
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        active = false;
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        active = true;
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateNavbar();
    }
    
    func updateNavbar() {
        if (active) {
            let scrollY = table.contentOffset.y;
            if (scrollY >= 0) {
                headerImage.frame.origin.y = -scrollY / 2;
                let alpha = min(scrollY / 75, 1);
                self.fakeNavBar.alpha = alpha;
                self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 1.0 - alpha, alpha: 1.0)];
                if (alpha < 0.5) {
                    toggleButton!.setBackgroundImage(UIImage(named: "nav_ocmicon"), forState: UIControlState.Normal);
                    toggleButton!.alpha = 1 - alpha;
                    self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
                    backButton.setBackgroundImage(UIImage(named: "btn_back_white.png"), forState: UIControlState.Normal);
                } else {
                    toggleButton!.setBackgroundImage(UIImage(named: "nav_ocmicon_inverted"), forState: UIControlState.Normal);
                    toggleButton!.alpha = alpha;
                    self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
                    backButton.setBackgroundImage(UIImage(named: "btn_back_black.png"), forState: UIControlState.Normal);
                }
            } else {
                self.fakeNavBar.alpha = 0;
                self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 1)];
                self.headerImage.frame.origin.y = 0;
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var row = tableView.dequeueReusableCellWithIdentifier("ConnectDeviceRow", forIndexPath: indexPath) as! ConnectDeviceRow
        
        let device = devices[indexPath.row]
        row.device = device;
        row.parentController = self.navigationController;
        row.logo.image = nil;
        row.logo.setImageWithURL(Utility.loadImageFromUrl(device.iconUrl as String));
        row.name.text = device.name as String;
        var detailText: String?
        if expandedDeviceDescriptions.contains(device.name) {
            detailText = device.description as String;
        }
        row.descriptionLabel.text = detailText
        row.connectedToggle.on = device.connected;
        row.device = device;
        row.clipsToBounds = true;
        row.selectionStyle = .None
        return row;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        tableView.beginUpdates()
        
        let device = devices[indexPath.row]
        if expandedDeviceDescriptions.contains(device.name) {
            expandedDeviceDescriptions.remove(device.name)
        } else {
            expandedDeviceDescriptions.insert(device.name)
        }
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        
        tableView.endUpdates()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count;
    }
    
    func goBack(sender: AnyObject!) {
        self.navigationController!.popViewControllerAnimated(true);
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        // we dont want to refresh on the first go around
        if (viewLoading) {
            viewLoading = false;
        } else {
            refreshDevices();
        }
    }
    
    func refreshDevices() {
        table.reloadData();
        ApiUtility.retrieveDevices({
            self.devices = Array(SessionController.Instance.devices.values);
            self.devices.sortInPlace(self.sortByConnected);
            self.table.reloadData();
        });
        
    }
}