import Foundation

private enum TableSection: Int {
    case BrandedDevice
    case VendorDevice
    case Count
}

class ConnectDeviceViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var headerLabel: UILabel! {
        didSet {
            headerLabel.text = NSLocalizedString("CONNECT_DEVICE_VIEW_HEADER_TEXT", comment: "Text to display in table header on Connect Device view.")
        }
    }

    var brandedDevices: [ActivityDevice] = {
        var devices: [ActivityDevice] = []
        
        if HealthKitManager.isHealthDataAvailable() {
            let name = NSLocalizedString("BRANDED_ACTIVITY_DEVICE_NAME", comment: "Name for branded activity tracker which leverages HealthKit data.")
            let description = NSLocalizedString("BRANDED_ACTIVITY_DEVICE_DESCRIPTION", comment: "Description for branded activity tracker which leverages HealthKit data.")
            let higiTracker = ActivityDevice(name: name, description: description, imageName: "higi-activity-tracker-icon", connected: false)
            
            HealthKitManager.hasReadAccessToStepData({ isAuthorized in
                higiTracker.connected = isAuthorized
            })
            
            devices.append(higiTracker)
        }
        
        return devices
    }()
    
    var vendorDevices: [ActivityDevice] = [];
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
        
        populateVendorDevices();
    }
    
    private func populateVendorDevices() {
        vendorDevices = sort(Array(SessionController.Instance.devices.values))
    }

    private func sort(vendorDevices: [ActivityDevice]) -> [ActivityDevice] {
        var sortedDevices = vendorDevices;
        sortedDevices.sortInPlace(sortByName);
        sortedDevices.sortInPlace(sortByConnected);
        return sortedDevices;
    }
    
    private func sortByName(this: ActivityDevice, that: ActivityDevice) -> Bool {
        return (this.name).compare(that.name as String, options: .CaseInsensitiveSearch) == .OrderedAscending
    }
    
    private func sortByConnected(this: ActivityDevice, that: ActivityDevice) -> Bool {
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
    
    private func device(forIndexPath indexPath: NSIndexPath) -> ActivityDevice {
        var device: ActivityDevice!
        if let section = TableSection(rawValue: indexPath.section) {
            switch section {
            case .BrandedDevice:
                device = brandedDevices[indexPath.row]
            case .VendorDevice:
                device = vendorDevices[indexPath.row]
            case .Count:
                break;
            }
        }
        return device
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let row = tableView.dequeueReusableCellWithIdentifier("ConnectDeviceRow", forIndexPath: indexPath) as! ConnectDeviceRow
        
        let device = self.device(forIndexPath: indexPath)
        
        row.device = device;
        row.parentController = self.navigationController;
        row.logo.image = nil;
        if let iconURL = device.iconUrl {
            row.logo.setImageWithURL(Utility.loadImageFromUrl(iconURL as String));
        } else if let imageName = device.imageName {
            row.logo.image = UIImage(named: imageName as String)
        }
        row.name.text = device.name as String;
        var detailText: String?
        if expandedDeviceDescriptions.contains(device.name) {
            detailText = device.description as String;
        }
        row.descriptionLabel.text = detailText
        row.connectedToggle.on = device.connected;
        
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TableSection.Count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        if let sectionType = TableSection(rawValue: section) {
            switch sectionType {
            case .BrandedDevice:
                rowCount = HealthKitManager.isHealthDataAvailable() ? brandedDevices.count : 0
            case .VendorDevice:
                rowCount = vendorDevices.count
            case .Count:
                break
            }
        }
        return rowCount
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
        
        if brandedDevices.count > 0 {
            HealthKitManager.hasReadAccessToStepData({ [weak self] isAuthorized in
                if let higiTracker = self?.brandedDevices.first {
                    higiTracker.connected = isAuthorized
                    dispatch_async(dispatch_get_main_queue(), {
                        self?.table.reloadData()
                    })
                }
                })
        }
        
        ApiUtility.retrieveDevices({
            let devices = Array(SessionController.Instance.devices.values);
            self.vendorDevices = self.sort(devices)
            self.table.reloadData();
        });
        
    }
}