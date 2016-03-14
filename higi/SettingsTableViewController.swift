//
//  SettingsTableViewController.swift
//  higi
//
//  Created by Remy Panicker on 9/24/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import UIKit
import SafariServices

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
        
        /*! @internal This is left over functionality from the refactor */
        guard let settingsViewController = self.parentViewController as? SettingsViewController else { return }
        SessionData.Instance.user.profileImage = user.profileImage
        SessionData.Instance.user.blurredImage = user.blurredImage
        profileImageView.image = user.profileImage
        settingsViewController.backgroundImageView.image = user.blurredImage
    }
    
    // MARK: Configuration
    
    func configureTableView() {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: defaultTableCellReuseIdentifier);
        tableView.registerClass(SwitchTableViewCell.self, forCellReuseIdentifier: switchTableCellReuseIdentifier);
        
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
                        cell = defaultCell(indexPath, title: NSLocalizedString("SETTINGS_TABLE_VIEW_CELL_TITLE_CONNECT_DEVICES", comment: "Title for connect device table view cell."));
                    case .ShareResultsHistory:
                        cell = shareCell(indexPath);
                    case .Notifications:
                        cell = defaultCell(indexPath, title: NSLocalizedString("SETTINGS_TABLE_VIEW_CELL_TITLE_NOTIFICATIONS", comment: "Title for notifications table view cell."));
                    case .ChangePassword:
                        cell = defaultCell(indexPath, title: NSLocalizedString("SETTINGS_TABLE_VIEW_CELL_TITLE_CHANGE_PASSWORD", comment: "Title for change password table view cell."));
                    case .TermsOfUse:
                        cell = defaultCell(indexPath, title: NSLocalizedString("SETTINGS_TABLE_VIEW_CELL_TITLE_TERMS", comment: "Title for terms of use table view cell."));
                    case .PrivacyPolicy:
                        cell = defaultCell(indexPath, title: NSLocalizedString("SETTINGS_TABLE_VIEW_CELL_TITLE_PRIVACY_POLICY", comment: "Title for privacy policy table view cell."));
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
        cell.textLabel?.font = UIFont.systemFontOfSize(14.0);
        cell.textLabel?.text = NSLocalizedString("SETTINGS_TABLE_VIEW_CELL_TITLE_PASSCODE", comment: "Title for passcode table view cell.")
        let hasPasscode = SessionData.Instance.pin != "";
        cell.switchControl.on = hasPasscode;
        cell.textLabel?.textColor = hasPasscode ? UIColor.blackColor() : UIColor.lightGrayColor();
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
        cell.textLabel?.text = NSLocalizedString("SETTINGS_TABLE_VIEW_CELL_TITLE_SHARE", comment: "Title for share higi results table view cell.")
        cell.accessoryType = .None;
        return cell;
    }
    
    func logOutCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(defaultTableCellReuseIdentifier, forIndexPath: indexPath);
        resetDefaultCell(cell);
        cell.textLabel?.text = NSLocalizedString("SETTINGS_TABLE_VIEW_CELL_TITLE_LOG_OUT", comment: "Title for log out table view cell.")
        cell.accessoryType = .None;
        return cell;
    }
    
    func buildNumberCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(defaultTableCellReuseIdentifier, forIndexPath: indexPath);
        cell.selectionStyle = .None;
        let format = NSLocalizedString("SETTINGS_TABLE_VIEW_CELL_TITLE_VERSION_FORMAT", comment: "Format of title for app version table view cell.")
        cell.textLabel?.text = String(format: format, arguments: [Utility.appVersion(), Utility.appBuild()])
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
        let modifyNav = UINavigationController(rootViewController: modifyImageViewController)
        
        self.navigationController?.presentViewController(modifyNav, animated: true, completion: nil)
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
        if #available(iOS 9.0, *) {
            let URL = NSURL(string: URLString)!
            let safariViewController = SFSafariViewController(URL: URL, entersReaderIfAvailable: false)
            self.navigationController?.presentViewController(safariViewController, animated: true, completion: nil)
        } else {
            let webController = WebViewController(nibName: "WebView", bundle: nil);
            webController.url = URLString;
            self.navigationController!.pushViewController(webController, animated: true);
        }
    }
    
    func didSelectLogOut() {
        PersistentSettingsController.reset();
        SessionController.Instance.reset();
        SessionData.Instance.reset();
        SessionData.Instance.save();
        HealthKitManager.disableBackgroundUpdates()
        
        let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate);
        appDelegate.stopLocationManager();
        
        let hostViewController = UIStoryboard(name: "Host", bundle: nil).instantiateInitialViewController()
        appDelegate.window?.rootViewController = hostViewController
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

        var contents = NSLocalizedString("EXPORT_DATA_CSV_DATA_TITLES", comment: "Titles for the various values of a user's data which can be exported.");
        
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
            
            let row = "\(Constants.displayDateFormatter.stringFromDate(checkin.dateTime)),\(organization),\(address),\(systolic),\(diastolic),\(pulse),\(map),\(weight),\(bmi)\n";
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
