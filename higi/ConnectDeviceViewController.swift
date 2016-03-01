import Foundation
import SafariServices

enum BrandedDevice {
    static let HigiActivityTracker = NSLocalizedString("BRANDED_ACTIVITY_DEVICE_NAME", comment: "Name for branded activity tracker which leverages HealthKit data.")
}

private enum TableSection: Int {
    case BrandedDevice
    case VendorDevice
    case Count
}

class ConnectDeviceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
            let description = NSLocalizedString("BRANDED_ACTIVITY_DEVICE_DESCRIPTION", comment: "Description for branded activity tracker which leverages HealthKit data.")
            let higiTracker = ActivityDevice(name: BrandedDevice.HigiActivityTracker, description: description, imageName: "higi-activity-tracker-icon", connected: false)
            
            HealthKitManager.checkReadAuthorizationForStepData({ isAuthorized in
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
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.title = NSLocalizedString("CONNECT_DEVICE_VIEW_TITLE", comment: "Title for Connect Device view.");
        table.delegate = self;
        table.dataSource = self;
        table.estimatedRowHeight = 70;
        table.registerNib(UINib(nibName: "ConnectDeviceRow", bundle: nil), forCellReuseIdentifier: "ConnectDeviceRow")
        
        populateVendorDevices();
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: nil, usingBlock: { [weak self] (notification) in
            self?.refreshDevices()
        })
    }
    
    private func populateVendorDevices() {
        vendorDevices = sort(Array(SessionController.Instance.devices.values))
    }

    private func sort(vendorDevices: [ActivityDevice]) -> [ActivityDevice] {
        var sortedDevices = vendorDevices;
        sortedDevices.sortInPlace(sortByConnectionThenName);
        return sortedDevices;
    }
    
    private func sortByConnectionThenName(this: ActivityDevice, that: ActivityDevice) -> Bool {
        return this.connected == that.connected ?
            (this.name).compare(that.name as String, options: .CaseInsensitiveSearch) == .OrderedAscending :
            this.connected
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        active = false;
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        active = true;
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
        
        let device = self.device(forIndexPath: indexPath)
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
            HealthKitManager.checkReadAuthorizationForStepData({ [weak self] isAuthorized in
                if let higiTracker = self?.brandedDevices.first {
                    dispatch_async(dispatch_get_main_queue(), {
                        higiTracker.connected = isAuthorized                        
                        self?.table.reloadData()
                    })
                }
                })
        }
        
        ApiUtility.retrieveDevices({
            let devices = Array(SessionController.Instance.devices.values)
            self.vendorDevices = self.sort(devices)
            dispatch_async(dispatch_get_main_queue(), { [weak self] in
                self?.table.reloadData()
                })
        })
        
    }
}

extension ConnectDeviceViewController: UniversalLinkHandler {

    func handleUniversalLink(URL: NSURL, pathType: PathType, parameters: [String]?) {
        guard let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: true) else { return }

        if let queryItems = components.queryItems {
            // If there are query parameters, we need to verify if the user is being routed here from redirect for mobile device connect
            var handleRedirect = false
            for queryItem in queryItems {
                if queryItem.name == "success" || queryItem.name == "device" {
                    handleRedirect = true
                    break
                }
            }
            if handleRedirect {
                handleConnectDeviceRedirect()
            } else {
                navigateToConnectDevice()
            }
        } else {
            navigateToConnectDevice()
        }
    }
    
    private func handleConnectDeviceRedirect() {
        //  We're handling a redirect, thus Safari should have been presented from the Connect Device view controller.
        if #available(iOS 9.0, *) {
            guard let tabBar = Utility.mainTabBarController() else { return }
            guard let safari = tabBar.presentedViewController as? SFSafariViewController else { return }
            safari.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    private func navigateToConnectDevice() {
        guard let mainTabBarController = Utility.mainTabBarController() else { return }
        
        let settingsNavController = mainTabBarController.settingsModalViewController() as! UINavigationController
        
        let connectDeviceViewController = ConnectDeviceViewController(nibName: "ConnectDeviceView", bundle: nil)
        dispatch_async(dispatch_get_main_queue(), {
            // Make sure there are no views presented over the tab bar controller
            mainTabBarController.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
            
            mainTabBarController.presentViewController(settingsNavController, animated: false, completion: {
                dispatch_async(dispatch_get_main_queue(), {
                    settingsNavController.pushViewController(connectDeviceViewController, animated: false)
                })
            })
        })
    }
}
