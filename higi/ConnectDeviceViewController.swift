import Foundation

class ConnectDeviceViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var table: UITableView!
    
    var devices:[ActivityDevice] = [];
    
    var backButton:UIButton!;
    
    var active = false, viewLoading = true;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        (self.navigationController as! MainNavigationController).revealController.panGestureRecognizer().enabled = false;
        backButton = UIButton(type: UIButtonType.Custom);
        backButton.setBackgroundImage(UIImage(named: "btn_back_white.png"), forState: UIControlState.Normal);
        backButton.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside);
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        let backBarItem = UIBarButtonItem(customView: backButton);
        self.navigationItem.leftBarButtonItem = backBarItem;
        self.navigationItem.hidesBackButton = true;
        
        shouldShowDailyPoints = false;
        
        self.title = "Connect a device";
        table.delegate = self;
        table.dataSource = self;
        table.rowHeight = 70;
        
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
        var row = tableView.dequeueReusableCellWithIdentifier("ConnectDeviceRow") as! ConnectDeviceRow!;
        if (row == nil) {
            row = UINib(nibName: "ConnectDeviceRow", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ConnectDeviceRow;
        }
        let device = devices[indexPath.row]
        row.device = device;
        row.parentController = self.navigationController;
        row.logo.image = nil;
        row.logo.setImageWithURL(Utility.loadImageFromUrl(device.iconUrl as String));
        row.name.text = device.name as String;
        row.connectedToggle.on = device.connected;
        row.device = device;
        return row;
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