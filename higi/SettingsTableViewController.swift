//
//  SettingsTableViewController.swift
//  higi
//
//  Created by Remy Panicker on 9/24/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import UIKit

private enum TableSection: Int {
    case Main
    case Count
}

private enum MainSectionRow: Int {
    case LocalAuthentication
    case ConnectDevices
    case ShareResultsHistory
    case SeparatorOne
    case Notifications
    case SeparatorTwo
    case ChangePassword
    case SeparatorThree
    case TermsOfUse
    case PrivacyPolicy
    case SeparatorFour
    case LogOut
    case BuildNumber
    case Count
}

/*!
    @internal In order to preserve the appearance of the old settings view,
    the table style is plain instead of grouped. Faux header sections views
    are created to keep the appearance of a white table background.
*/
class SettingsTableViewController: UITableViewController, SwitchTableViewCellDelegate {

    let separatorCellSize: CGFloat = 23.0;
    
    let defaultTableCellReuseIdentifier = "DefaultTableCellReuseIdentifier";
    let switchTableCellReuseIdentifier = "SwitchCellReuseIdentifier";
    
    // MARK: -
    
    let user = SessionData.Instance.user;
    
    // MARK: IB Outlets
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.image = SessionData.Instance.user.profileImage;
            addWhiteBorder(profileImageView);
        }
    };
    @IBOutlet weak var resizeProfileImageButton: UIButton! {
        didSet {
            addWhiteBorder(resizeProfileImageButton);
            resizeProfileImageButton.enabled = SessionData.Instance.user.hasPhoto;
        }
    }
    @IBOutlet weak var newProfileImageButton: UIButton! {
        didSet {
            addWhiteBorder(newProfileImageButton);
        }
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        configureTableView();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        // ???: Why does this need to happen?
        (self.navigationController as! MainNavigationController).drawerController?.selectRowAtIndex(5);
        updateNavBar();
        
        /*! @internal This is left over functionality from the refactor */
        let settingsViewController = self.parentViewController as! SettingsViewController;
        if (settingsViewController.pictureChanged) {
            SessionData.Instance.user.profileImage = user.profileImage;
            SessionData.Instance.user.blurredImage = user.blurredImage;
            profileImageView.image = user.profileImage;
            settingsViewController.backgroundImageView.image = user.blurredImage;
            (self.navigationController as! MainNavigationController).drawerController.refreshData();
        }
    }
    
    // MARK: Configuration
    
    func configureTableView() {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: defaultTableCellReuseIdentifier);
        let switchCellNib = UINib(nibName: "SwitchTableViewCell", bundle: nil);
        tableView.registerNib(switchCellNib, forCellReuseIdentifier: switchTableCellReuseIdentifier);
        
        tableView.tableFooterView = UIView();
    }
    
    func addWhiteBorder(view: UIView) {
        view.layer.borderWidth = 1.0;
        view.layer.borderColor = UIColor.whiteColor().CGColor;
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TableSection.Count.rawValue;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0;
        if let tableSection = TableSection(rawValue: section) {
            switch tableSection {
            case .Main:
                rowCount = MainSectionRow.Count.rawValue;
            default:
                break;
            }
        }
        return rowCount;
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var rowHeight: CGFloat = 0.0;
        if let section = TableSection(rawValue: indexPath.section) {
            switch section {
            case .Main:
                if let row = MainSectionRow(rawValue: indexPath.row) {
                    switch row {
                    case .SeparatorOne:
                        fallthrough
                    case .SeparatorTwo:
                        fallthrough
                    case .SeparatorThree:
                        fallthrough
                    case .SeparatorFour:
                        rowHeight = separatorCellSize;
                    default:
                        rowHeight = UITableViewAutomaticDimension;
                    }
                }
            default:
                break;
            }
        }
        return rowHeight;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!;
        
        if let section = TableSection(rawValue: indexPath.section) {
            switch section {
            case .Main:
                if let row = MainSectionRow(rawValue: indexPath.row) {
                    switch row {
                    case .LocalAuthentication:
                        cell = passcodeCell(indexPath);
                    case .ConnectDevices:
                        cell = defaultCell(indexPath, title: "Connect devices");
                    case .ShareResultsHistory:
                        cell = shareCell(indexPath);
                    case .Notifications:
                        cell = defaultCell(indexPath, title: "Notifications");
                    case .ChangePassword:
                        cell = defaultCell(indexPath, title: "Change password");
                    case .TermsOfUse:
                        cell = defaultCell(indexPath, title: "Terms of Use");
                    case .PrivacyPolicy:
                        cell = defaultCell(indexPath, title: "Privacy Policy");
                    case .LogOut:
                        cell = logOutCell(indexPath);
                    case .BuildNumber:
                        cell = buildNumberCell(indexPath);
                    default:
                        cell = separatorCell(indexPath);
                    }
                }
            default:
                break;
            }
        }
        
        return cell;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        
        if let section = TableSection(rawValue: indexPath.section) {
            switch section {
            case .Main:
                if let row = MainSectionRow(rawValue: indexPath.row) {
                    switch row {
                    case .ConnectDevices:
                        didSelectConnectDevices();
                    case .ShareResultsHistory:
                        didSelectShareResults();
                    case .Notifications:
                        didSelectNotificationsSettings();
                    case .ChangePassword:
                        didSelectChangePassword();
                    case .TermsOfUse:
                        didSelectShowTerms();
                    case .PrivacyPolicy:
                        didSelectShowPrivacy();
                    case .LogOut:
                        didSelectLogOut();
                    default:
                        break;
                    }
                }
            default:
                break;
            }
        }
    }
    
    // MARK: Cell Configuration
    
    func passcodeCell(indexPath: NSIndexPath) -> SwitchTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(switchTableCellReuseIdentifier, forIndexPath: indexPath) as! SwitchTableViewCell;
        cell.delegate = self;
        cell.titleLabel?.font = UIFont.systemFontOfSize(14.0);
        cell.titleLabel?.text = "Protect my data with a passcode";
        let hasPasscode = SessionData.Instance.pin != "";
        cell.switchControl.on = hasPasscode;
        cell.titleLabel?.textColor = hasPasscode ? UIColor.blackColor() : UIColor.lightGrayColor();
        return cell;
    }
    
    func defaultCell(indexPath: NSIndexPath, title: String) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(defaultTableCellReuseIdentifier, forIndexPath: indexPath);
        resetDefaultCell(cell);
        cell.textLabel?.text = title;
        cell.accessoryType = .DisclosureIndicator;
        return cell;
    }
    
    func shareCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(defaultTableCellReuseIdentifier, forIndexPath: indexPath);
        resetDefaultCell(cell);
        cell.textLabel?.text = "Share higi results history";
        cell.accessoryType = .None;
        return cell;
    }
    
    func logOutCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(defaultTableCellReuseIdentifier, forIndexPath: indexPath);
        resetDefaultCell(cell);
        cell.textLabel?.text = "Log Out";
        cell.accessoryType = .None;
        return cell;
    }
    
    func buildNumberCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(defaultTableCellReuseIdentifier, forIndexPath: indexPath);
        cell.selectionStyle = .None;
        cell.textLabel?.text = "Version \(Utility.appVersion()).\(Utility.appBuild())";
        cell.textLabel?.textAlignment = .Center;
        cell.textLabel?.font = UIFont.systemFontOfSize(12.0);
        cell.textLabel?.textColor = UIColor.lightGrayColor();
        cell.accessoryType = .None;
        return cell;
    }
    
    func resetDefaultCell(cell: UITableViewCell) {
        cell.selectionStyle = .Default;
        cell.textLabel?.textAlignment = .Left;
        cell.textLabel?.font = UIFont.systemFontOfSize(14.0);
        cell.textLabel?.textColor = UIColor.blackColor();
    }
    
    func separatorCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(defaultTableCellReuseIdentifier, forIndexPath: indexPath);
        cell.selectionStyle = .None;
        cell.textLabel?.text = "";
        cell.textLabel?.textAlignment = .Left;
        cell.accessoryType = .None;
        return cell;
    }
    
    // MARK: - Switch Cell
    
    func valueDidChangeForSwitchCell(cell: SwitchTableViewCell) {
        let pinCodeViewController = PinCodeViewController(nibName: "PinCodeView", bundle: nil);
        if cell.switchControl.on {
            Flurry.logEvent("CreatePasscode_Pressed");
            pinCodeViewController.newCode = true;
        } else {
            pinCodeViewController.removing = true;
        }
        self.navigationController!.pushViewController(pinCodeViewController, animated: true);
    }
    
    // MARK: - Scroll View
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        updateNavBar();
    }
    
    func updateNavBar() {
        let settingsViewController = self.parentViewController as! SettingsViewController;
        settingsViewController.updateNavBar();
    }
    
    // MARK: - UI Actions
    
    @IBAction func didPressNewProfileImageButton(sender: AnyObject) {
        let profileViewController = ProfileImageViewController(nibName: "ProfileImageView", bundle: nil);
        profileViewController.fromSettings = true;
        self.navigationController!.pushViewController(profileViewController, animated: true);
    }
    
    @IBAction func didPressResizeProfileImageButton(sender: AnyObject) {
        let modifyImageViewController = ModifyImageViewController(nibName: "ModifyImageView", bundle: nil);
        modifyImageViewController.profileImage = SessionData.Instance.user.fullProfileImage;
        modifyImageViewController.resizing = true;
        modifyImageViewController.fromSettings = true;
        self.navigationController!.pushViewController(modifyImageViewController, animated: true);
    }

    func didSelectNotificationsSettings() {
        let notificationSettingsViewController = UIStoryboard(name: "NotificationSettings", bundle: nil).instantiateInitialViewController() as UIViewController!;
        self.navigationController!.pushViewController(notificationSettingsViewController, animated: true);
    }
    
    func didSelectChangePasscode() {
        let pinCodeViewController = PinCodeViewController(nibName: "PinCodeView", bundle: nil);
        pinCodeViewController.modifying = true;
        self.navigationController!.pushViewController(pinCodeViewController, animated: true);
    }
    
    func didSelectChangePassword() {
        self.navigationController!.pushViewController(ChangePasswordViewController(nibName: "ChangePasswordView", bundle: nil), animated: true);
    }
    
    func didSelectShowTerms() {
        pushWebView("https://higi.com/terms");
    }
    
    func didSelectShowPrivacy() {
        pushWebView("https://higi.com/privacy");
    }
    
    func pushWebView(URLString: String) {
        let webController = WebViewController(nibName: "WebView", bundle: nil);
        webController.url = URLString;
        self.navigationController!.pushViewController(webController, animated: true);
    }
    
    func didSelectLogOut() {
        PersistentSettingsController.reset();
        SessionController.Instance.reset();
        SessionData.Instance.reset();
        SessionData.Instance.save();
        let splashViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SplashViewController") ;
        (UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController = splashViewController;
    }
    
    func didSelectConnectDevices() {
        Flurry.logEvent("ConnectDevice_Pressed");
        self.navigationController!.pushViewController(ConnectDeviceViewController(nibName: "ConnectDeviceView", bundle: nil), animated: true);
    }
    
    func didSelectShareResults() {
        Flurry.logEvent("BodystatShare_Pressed");
        let activityItems = ["higi_results.csv", exportData()];
        let shareScreen = UIActivityViewController(activityItems: activityItems, applicationActivities: nil);
        self.presentViewController(shareScreen, animated: true, completion: nil);
    }
    
    // MARK: - Helper
    
    func exportData() -> NSURL {
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "MM/dd/yyy";
        var contents = "Date,Location,Address of higi Station,Systolic Pressure (mmHg),Diastolic Pressure (mmHg),Pulse (bpm),Mean Arterial Pressure (mmHg), Weight (lbs),Body Mass Index\n";
        
        for index in Array((0..<SessionController.Instance.checkins.count).reverse()) {
            let checkin = SessionController.Instance.checkins[index];
            var address = "", systolic = "", diastolic = "", pulse = "", map = "", weight = "", bmi = "";
            var organization = checkin.sourceVendorId!;
            if (checkin.kioskInfo != nil) {
                organization = checkin.kioskInfo!.organizations[0];
                address = "\"\(checkin.kioskInfo!.fullAddress)\"";
            }
            
            if (checkin.systolic != nil && checkin.pulseBpm != nil) {
                systolic = "\(checkin.systolic!)";
                diastolic = "\(checkin.diastolic!)";
                pulse = "\(checkin.pulseBpm!)";
                map = String(format: "%.1f", checkin.map!);
            }
            
            if (checkin.bmi != nil) {
                bmi = String(format: "%.2f", checkin.bmi!);
                weight = "\(Int(checkin.weightLbs!))";
            }
            
            let row = "\(dateFormatter.stringFromDate(checkin.dateTime)),\(organization),\(address),\(systolic),\(diastolic),\(pulse),\(map),\(weight),\(bmi)\n";
            contents += row;
        }
        
        let filePath = getShareFilePath();
        
        do {
            try contents.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
        } catch _ {
        };
        
        return NSURL(fileURLWithPath: filePath);
        
    }
    
    func getShareFilePath() -> String {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] + "higi_results.csv";
    }
}
