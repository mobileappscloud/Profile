//
//  FindStationViewController.swift
//  higi
//
//  Created by Dan Harms on 8/4/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation
import EventKitUI
import MapKit

final class FindStationViewController: UIViewController, GMSMapViewDelegate, UITableViewDataSource, UITableViewDelegate, EKEventEditViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate, ClusterManagerDelegate {
    
    @IBOutlet weak var mapContainer: UIView!
    
    @IBOutlet weak var autoCompleteTable: UITableView!
    @IBOutlet var autoCompleteTableTopLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var autoCompleteSpinner: UIActivityIndicatorView!
    @IBOutlet weak var noResults: UIImageView!
    @IBOutlet weak var visibleKiosksTable: UITableView!
    @IBOutlet var visibleKioskTableTopLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var selectedKioskPane: UIView!
    @IBOutlet var selectedKioskPaneTopLayoutConstraint: NSLayoutConstraint!

    @IBOutlet weak var selectedLogo: UIImageView!
    @IBOutlet weak var selectedName: UILabel!
    @IBOutlet weak var selectedAddress: UILabel!
    @IBOutlet weak var selectedDistance: UILabel!
    
    @IBOutlet weak var mondayLabel: UILabel! {
        didSet {
            mondayLabel.text = NSLocalizedString("FIND_STATION_VIEW_STATION_DETAILS_DAY_OF_WEEK_TITLE_SECOND", comment: "Title for 2nd day of week.");
        }
    }
    @IBOutlet weak var tuesdayLabel: UILabel! {
        didSet {
            tuesdayLabel.text = NSLocalizedString("FIND_STATION_VIEW_STATION_DETAILS_DAY_OF_WEEK_TITLE_THIRD", comment: "Title for 3rd day of week.");
        }
    }
    @IBOutlet weak var wednesdayLabel: UILabel! {
        didSet {
            wednesdayLabel.text = NSLocalizedString("FIND_STATION_VIEW_STATION_DETAILS_DAY_OF_WEEK_TITLE_FOURTH", comment: "Title for 4th day of week.");
        }
    }
    @IBOutlet weak var thursdayLabel: UILabel! {
        didSet {
            thursdayLabel.text = NSLocalizedString("FIND_STATION_VIEW_STATION_DETAILS_DAY_OF_WEEK_TITLE_FIFTH", comment: "Title for 5th day of week.");
        }
    }
    @IBOutlet weak var fridayLabel: UILabel! {
        didSet {
            fridayLabel.text = NSLocalizedString("FIND_STATION_VIEW_STATION_DETAILS_DAY_OF_WEEK_TITLE_SIXTH", comment: "Title for 6th day of week.");
        }
    }
    @IBOutlet weak var saturdayLabel: UILabel! {
        didSet {
            saturdayLabel.text = NSLocalizedString("FIND_STATION_VIEW_STATION_DETAILS_DAY_OF_WEEK_TITLE_SEVENTH", comment: "Title for 7th day of week.");
        }
    }
    @IBOutlet weak var sundayLabel: UILabel! {
        didSet {
            sundayLabel.text = NSLocalizedString("FIND_STATION_VIEW_STATION_DETAILS_DAY_OF_WEEK_TITLE_FIRST", comment: "Title for 1st day of week.");
        }
    }
    
    @IBOutlet weak var mondayHours: UILabel!
    @IBOutlet weak var tuesdayHours: UILabel!
    @IBOutlet weak var wednesdayHours: UILabel!
    @IBOutlet weak var thursdayHours: UILabel!
    @IBOutlet weak var fridayHours: UILabel!
    @IBOutlet weak var saturdayHours: UILabel!
    @IBOutlet weak var sundayHours: UILabel!
    
    @IBOutlet weak var reminderOverlay: UIView!
    @IBOutlet weak var getStarted: UIButton!
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var reminderButton: UIButton!
    
    @IBOutlet weak var topHelp: UIView!
    @IBOutlet weak var bottomHelp: UIView!
    @IBOutlet weak var bottomHelpBackground: UIImageView!
    
    let distanceFormatter: MKDistanceFormatter = {
        let distanceFormatter = MKDistanceFormatter();
        distanceFormatter.unitStyle = .Abbreviated;
        return distanceFormatter;
    }()

    
    var locationManager: CLLocationManager!;
    
    var listOpen = false, autoCompleteOpen = false, selectedPaneOpen = false, reminderMode = true, firstLocation = false;
    
    var mapView: GMSMapView!;
    
    var visibleKiosks: [KioskInfo] = [], autoCompleteResults: [KioskInfo] = [];
    
    var searchField: UITextField!;
    
    var selectedKiosk: KioskInfo?;
    
    var listButton: UIButton!;
    
    var selectedMarker: GMSMarker?;
    
    var currentAutoCompleteTask = NSOperationQueue(), currentVisibleKioskTask = NSOperationQueue();
    
    var clusterManager:GClusterManager = GClusterManager();
    
    var universalLinkObserver: NSObjectProtocol? = nil
    
    /// Height of navigation bar and status bar in portrait orientation
    private let topBarHeight: CGFloat = 64.0

    /// Height of kiosk info header contained within the selectedKioskPane plus vertical spacing
    private let kioskInfoHeight: CGFloat = 70.0 + 6.0
    private let selectedPaneHeight: CGFloat = 323.0
    
    private var myLocationContainerBottomConstraint: NSLayoutConstraint!
    
    lazy private var dismissBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(didTapDoneButton(_:)))
    }()
    
    lazy private var stationController: StationController = {
        return StationController()
    }()
    
    override func viewDidLoad()  {
        super.viewDidLoad();
        
        stationController.fetch({ [weak self] in
            self?.stationFetchUpdateHandler()
            }, failure: {

        })
        
        listButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30));
        listButton.setBackgroundImage(UIImage(named: "map-list-view-icon")!.imageWithRenderingMode(.AlwaysTemplate), forState: UIControlState.Normal);
        listButton.addTarget(self, action: #selector(FindStationViewController.toggleList(_:)), forControlEvents: UIControlEvents.TouchUpInside);
        let listBarItem = UIBarButtonItem();
        listBarItem.customView = listButton;
        self.navigationItem.leftBarButtonItem = listBarItem;
        self.navigationItem.rightBarButtonItem = dismissBarButtonItem
        
        searchField = UITextField(frame: CGRect(x: 0, y: 0, width: 95, height: 40));
        searchField.textColor = Theme.Color.Primary.white
        searchField.tintColor = Theme.Color.Primary.white
        searchField.font = UIFont.systemFontOfSize(12);
        searchField.placeholder = NSLocalizedString("FIND_STATION_VIEW_SEARCH_FIELD_PLACEHOLDER_TEXT", comment: "Placeholder text for search field on Find Station view.");
        searchField.leftViewMode = UITextFieldViewMode.Always;
        searchField.leftView = UIImageView(image: UIImage(named: "search-icon")!.imageWithRenderingMode(.AlwaysTemplate));
        searchField.leftView!.frame = CGRect(x: 0, y: 5, width: 30, height: 20);
        searchField.leftView!.contentMode = UIViewContentMode.ScaleAspectFit;
        searchField.clearButtonMode = UITextFieldViewMode.WhileEditing;
        searchField.delegate = self;
        
        searchField.addTarget(self, action: #selector(FindStationViewController.textFieldChanged), forControlEvents: UIControlEvents.EditingChanged);
        self.navigationItem.titleView = searchField;
        
        // TODO: l10n, this should be based on day of week, but will require some significant effort to refactor.
        //       Implementing trivial solution which will continue to switch on string for the time being.
        let fontSize = mondayHours.font.pointSize;
        let formatter = NSDateFormatter();
        formatter.dateFormat = "EEEE";
        let dayString: String = formatter.stringFromDate(NSDate());
        
        let sunday = NSLocalizedString("FIND_STATION_VIEW_STATION_DETAILS_DAY_OF_WEEK_TITLE_FIRST", comment: "Title for 1st day of week.");
        let monday = NSLocalizedString("FIND_STATION_VIEW_STATION_DETAILS_DAY_OF_WEEK_TITLE_SECOND", comment: "Title for 2nd day of week.");
        let tuesday = NSLocalizedString("FIND_STATION_VIEW_STATION_DETAILS_DAY_OF_WEEK_TITLE_THIRD", comment: "Title for 3rd day of week.");
        let wednesday = NSLocalizedString("FIND_STATION_VIEW_STATION_DETAILS_DAY_OF_WEEK_TITLE_FOURTH", comment: "Title for 4th day of week.");
        let thursday = NSLocalizedString("FIND_STATION_VIEW_STATION_DETAILS_DAY_OF_WEEK_TITLE_FIFTH", comment: "Title for 5th day of week.");
        let friday = NSLocalizedString("FIND_STATION_VIEW_STATION_DETAILS_DAY_OF_WEEK_TITLE_SIXTH", comment: "Title for 6th day of week.");
        let saturday = NSLocalizedString("FIND_STATION_VIEW_STATION_DETAILS_DAY_OF_WEEK_TITLE_SEVENTH", comment: "Title for 7th day of week.");

        switch dayString {
        case monday:
            mondayHours.font = UIFont.boldSystemFontOfSize(fontSize);
        case tuesday:
            tuesdayHours.font = UIFont.boldSystemFontOfSize(fontSize);
        case wednesday:
            wednesdayHours.font = UIFont.boldSystemFontOfSize(fontSize);
        case thursday:
            thursdayHours.font = UIFont.boldSystemFontOfSize(fontSize);
        case friday:
            fridayHours.font = UIFont.boldSystemFontOfSize(fontSize);
        case saturday:
            saturdayHours.font = UIFont.boldSystemFontOfSize(fontSize);
        case sunday:
            sundayHours.font = UIFont.boldSystemFontOfSize(fontSize);
        default:
            break;
        }
        
        if (reminderMode) {
            reminderButton.hidden = false;
            getStarted.layer.borderWidth = 1;
            getStarted.layer.borderColor = Utility.colorFromHexString("#CCCCCC").CGColor;
            cancel.layer.borderWidth = 1;
            cancel.layer.borderColor = Utility.colorFromHexString("#CCCCCC").CGColor;
            
            if (!SessionData.Instance.seenReminder) {
                topHelp.layer.borderWidth = 1;
                topHelp.layer.borderColor = Utility.colorFromHexString("#9A9A9A").CGColor;
                topHelp.hidden = false;
                
                var stretchedImage = UIImage(named: "background-tap-reminder")!;
                stretchedImage = stretchedImage.resizableImageWithCapInsets(UIEdgeInsets(top: 40, left: 5, bottom: 160, right: 100));
                bottomHelpBackground.image = stretchedImage;
            }
        }
        
        autoCompleteTable.tableFooterView = UIView(frame: CGRectZero);
        visibleKiosksTable.tableFooterView = UIView(frame: CGRectZero);
        autoCompleteTable.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        visibleKiosksTable.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        setupMap();
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FindStationViewController.receiveApiNotification(_:)), name: ApiUtility.KIOSKS, object: nil);
        
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil);
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        
        locationManager = CLLocationManager();
        locationManager.requestAlwaysAuthorization();
        locationManager.delegate = self;
        
        if stationController.stations.count != 0 {
            populateClusterManager()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        clusterManager.removeItems()
    }
    
    private func stationFetchUpdateHandler() {
        populateClusterManager();
        clusterManager.cluster();
        updateKioskPositions();
    }

    override func viewDidDisappear(animated: Bool) {
        currentVisibleKioskTask.cancelAllOperations();
        super.viewDidDisappear(animated)
    }
    
    func myLocationContainer() -> UIView {
        return mapView.subviews.last!
    }
    
    func setupMap() {
        let camera = GMSCameraPosition.cameraWithLatitude(41.888254, longitude: -87.637681, zoom: 11);
        mapView = GMSMapView.mapWithFrame(CGRect(origin: CGPoint(x: 0, y: 0), size: mapContainer.frame.size), camera: camera);
        mapView.myLocationEnabled = true;
        mapView.settings.myLocationButton = true;

        clusterManager = GClusterManager(mapView: mapView, algorithm: NonHierarchicalDistanceBasedAlgorithm(), renderer: HigiClusterRenderer(mapView: mapView))
        mapView.delegate = clusterManager;
        clusterManager.delegate = self;
        
        mapContainer.addSubview(mapView, pinToEdges: true)

        myLocationContainer().translatesAutoresizingMaskIntoConstraints = false
        
        mapView.addConstraint(NSLayoutConstraint(item: myLocationContainer(), attribute: .Height, relatedBy: .Equal, toItem: .None, attribute: .NotAnAttribute, multiplier: 1.0, constant: 56.0))
        
        mapView.addConstraint(NSLayoutConstraint(item: myLocationContainer(), attribute: .Width, relatedBy: .Equal, toItem: mapView, attribute: .Width, multiplier: 1.0, constant: 0.0))
        
        mapView.addConstraint(NSLayoutConstraint(item: myLocationContainer(), attribute: .Trailing, relatedBy: .Equal, toItem: mapView, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        
        
        myLocationContainerBottomConstraint = NSLayoutConstraint(item: myLocationContainer(), attribute: .Bottom, relatedBy: .Equal, toItem: mapView, attribute: .Bottom, multiplier: 1.0, constant: -5.0)
        mapView.addConstraint(myLocationContainerBottomConstraint)
    }
    
    func populateClusterManager() {
        if (stationController.stations.count == 0) {
            return;
        }
        for kiosk in stationController.stations {
            if (kiosk.status == "Deployed") {
                let item = ClusterKiosk();
                item.setPosition(kiosk.position!);
                item.setData(["kiosk": kiosk]);
                clusterManager.addItem(item);
            }
        }
        updateKioskPositions();
    }
    
    func updateKioskPositions() {
        if (stationController.stations.count == 0) {
            return;
        }
        currentVisibleKioskTask.cancelAllOperations();
        searchField.resignFirstResponder();
        visibleKiosks = [];
        let bounds = GMSCoordinateBounds(region: self.mapView!.projection.visibleRegion());
        
        currentVisibleKioskTask.addOperationWithBlock({
            
            for kiosk in self.stationController.stations {
                
                if (kiosk.status != "Deployed") {
                    continue;
                }
                if (bounds.containsCoordinate(kiosk.position!)) {
                    self.visibleKiosks.append(kiosk);

                }
                if ((self.currentVisibleKioskTask.operations[0] ).cancelled) {
                    return;
                }
            }
            if ((self.currentVisibleKioskTask.operations[0] ).cancelled) {
                return;
            }
            self.visibleKiosks.sortInPlace { self.distanceFromCurrentLocation($0.location!) < self.distanceFromCurrentLocation($1.location!) };
            if ((self.currentVisibleKioskTask.operations[0] ).cancelled) {
                return;
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.visibleKiosksTable.reloadData();
                if (self.visibleKiosks.count == 0) {
                    self.listButton.hidden = true;
                } else {
                    self.listButton.hidden = false;
                }
            });
        });
    }
    
    func toggleList(sender: AnyObject!) {
        
        searchField.resignFirstResponder();
        
        if (listOpen) {
            (self.navigationItem.leftBarButtonItem!.customView! as! UIButton).setBackgroundImage(UIImage(named: "map-list-view-icon")!.imageWithRenderingMode(.AlwaysTemplate), forState: UIControlState.Normal);
        } else {
            (self.navigationItem.leftBarButtonItem!.customView! as! UIButton).setBackgroundImage(UIImage(named: "map-view-icon")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal);
        }
        
        let offset = listOpen ? self.view.frame.height : 0
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.visibleKioskTableTopLayoutConstraint.constant = offset
            }, completion: nil);
        
        listOpen = !listOpen;
    }
    
    func distanceFromCurrentLocation(location: CLLocation) -> Double {
        if (mapView.myLocation != nil) {
            return location.distanceFromLocation(mapView.myLocation);
        } else {
            return -1;
        }
    }
    
    func textFieldChanged() {
        if (!self.autoCompleteOpen) {
            self.toggleAutoCompleteTable();
        }
        autoCompleteSpinner.hidden = false;
        currentAutoCompleteTask.cancelAllOperations();
        autoCompleteResults = [];
        if (searchField.text!.characters.count == 0) {
            noResults.hidden = true;
            autoCompleteTable.reloadData();
            if (autoCompleteOpen) {
                toggleAutoCompleteTable();
            }
        } else {
            currentAutoCompleteTask.addOperationWithBlock( {
                let size = self.searchField.text!.characters.count;
                for kiosk in self.stationController.stations {
                    if (kiosk.status != "Deployed") {
                        continue;
                    }
                    if ((self.currentAutoCompleteTask.operations[0]).cancelled && size != self.searchField.text!.characters.count) {
                        return;
                    }
                    if (kiosk.organizations[0].lowercaseString.rangeOfString(self.searchField.text!.lowercaseString) != nil) {
                        self.autoCompleteResults.append(kiosk);
                    } else if (kiosk.fullAddress.lowercaseString.rangeOfString(self.searchField.text!.lowercaseString) != nil) {
                        self.autoCompleteResults.append(kiosk);
                    }
                }
                if ((self.currentAutoCompleteTask.operations[0]).cancelled && size != self.searchField.text!.characters.count) {
                    return;
                }
                self.autoCompleteResults.sortInPlace { self.distanceFromCurrentLocation($0.location!) < self.distanceFromCurrentLocation($1.location!) };
                if ((self.currentAutoCompleteTask.operations[0]).cancelled && size != self.searchField.text!.characters.count) {
                    return;
                }
                if (size == self.searchField.text!.characters.count) {
                    dispatch_async(dispatch_get_main_queue(), {
                    
                        self.autoCompleteSpinner.hidden = true;
                        if (self.autoCompleteResults.count == 0 && self.autoCompleteOpen) {
                            self.noResults.hidden = false;
                        } else {
                            self.noResults.hidden = true;
                        }
                        self.autoCompleteTable.reloadData();
                    });
                }
            });
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == autoCompleteTable) {
            return autoCompleteResults.count;
        } else if (tableView == visibleKiosksTable) {
            return visibleKiosks.count;
        }
        return 0;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        if (tableView == autoCompleteTable) {
            if (indexPath.item < autoCompleteResults.count) {
                setSelectedKiosk(autoCompleteResults[indexPath.item]);
                searchField.text = "";
                toggleAutoCompleteTable();
            }
        } else if (tableView == visibleKiosksTable) {
            if (indexPath.item < visibleKiosks.count) {
                setSelectedKiosk(visibleKiosks[indexPath.item]);
                toggleList(nil);
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: KioskListCell!;
        var kiosk: KioskInfo!;
        if (tableView == autoCompleteTable) {
            cell = autoCompleteTable.dequeueReusableCellWithIdentifier("KioskListCell") as! KioskListCell!;
            if (indexPath.item >= autoCompleteResults.count) {   // Results are out of date
                return cell ?? UINib(nibName: "KioskListCellView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! KioskListCell;
            }
            kiosk = autoCompleteResults[indexPath.item];
        } else if (tableView == visibleKiosksTable) {
            cell = visibleKiosksTable.dequeueReusableCellWithIdentifier("KioskListCell") as! KioskListCell!;
            if (indexPath.item >= visibleKiosks.count) {
                return cell ?? UINib(nibName: "KioskListCellView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! KioskListCell;
            }
            kiosk = visibleKiosks[indexPath.item];
        }
        if (cell == nil) {
            cell = UINib(nibName: "KioskListCellView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! KioskListCell;
        }
        cell.name.text = kiosk.organizations[0] as String;
        cell.name.sizeToFit();
        cell.address.text = kiosk.fullAddress as String;
        cell.logo.image = nil;
        cell.logo.setImageWithURL(getKioskLogoUrl(kiosk));
        
        let distance = distanceFromCurrentLocation(kiosk.location!);
        if (distance >= 0) {
            cell.distance.text = distanceFormatter.stringFromDistance(distance);
        } else {
            cell.distance.text = "";
        }
        return cell;
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchField.resignFirstResponder();
    }
    
    @IBAction func toggleSelectedPane(sender: AnyObject!) {
        selectedPaneOpen = !selectedPaneOpen
        updateSelectedPanePosition()
    }
    
    private func updateSelectedPanePosition(adjustMapWithDifference adjustMap: Bool = true) {
        let offset = selectedPaneOpen ? self.view.frame.height - self.selectedPaneHeight : self.view.frame.height - self.kioskInfoHeight
        let diff = selectedKioskPaneTopLayoutConstraint.constant - offset
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.selectedKioskPaneTopLayoutConstraint.constant = offset
            }, completion: nil)
        
        if adjustMap {
            mapView.animateWithCameraUpdate(GMSCameraUpdate.scrollByX(0.0, y: diff))
        }
    }
    
    @IBAction func selectedPaneDragged(sender: UIPanGestureRecognizer) {
        let openOffset = self.view.frame.height - self.kioskInfoHeight
        let closedOffset = self.view.frame.height - self.selectedPaneHeight

        if (sender.state == UIGestureRecognizerState.Ended) {
            if selectedPaneOpen {
                selectedPaneOpen = selectedKioskPaneTopLayoutConstraint.constant <= self.view.frame.height - selectedPaneHeight + (selectedPaneHeight * 0.3)
            } else {
                selectedPaneOpen = selectedKioskPaneTopLayoutConstraint.constant <= self.view.frame.height - kioskInfoHeight - (kioskInfoHeight * 0.3)
            }
            updateSelectedPanePosition(adjustMapWithDifference: false)

        } else if (sender.state != UIGestureRecognizerState.Began) {
            let translation = sender.translationInView(self.view).y

            let origin = selectedKioskPaneTopLayoutConstraint.constant + translation
            
            if closedOffset...openOffset ~= origin {
                selectedKioskPaneTopLayoutConstraint.constant = origin
                mapView.moveCamera(GMSCameraUpdate.scrollByX(0, y: -translation * 0.5))
            }
        }
        
        sender.setTranslation(CGPointZero, inView: self.view);
    }
    
    func toggleAutoCompleteTable() {
        if (!autoCompleteOpen) {
            if (listOpen) {
                toggleList(nil);
            }
            listButton.hidden = true;

            UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
                
                self.autoCompleteTableTopLayoutConstraint.constant = 0
                
                }, completion: nil);
        } else {
            noResults.hidden = true;
            autoCompleteSpinner.hidden = true;
            
            UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
                
                self.autoCompleteTableTopLayoutConstraint.constant = self.view.frame.height;
                
                }, completion: { complete in
                    self.listButton.hidden = false;
            });
        }
        autoCompleteOpen = !autoCompleteOpen;
    }
    
    func setSelectedKiosk(kiosk: KioskInfo) {
        clusterManager.setSelectedMarker(kiosk.position!);
        
        mapView.animateToCameraPosition(GMSCameraPosition(target: kiosk.position!, zoom: max(mapView.camera.zoom, 14), bearing: mapView.camera.bearing, viewingAngle: mapView.camera.viewingAngle));
        
        searchField.resignFirstResponder();
        if (selectedKioskPane.hidden) {
            let diff = selectedPaneOpen ? self.view.frame.height - self.selectedPaneHeight : self.view.frame.height - self.kioskInfoHeight
            self.selectedKioskPaneTopLayoutConstraint.constant = diff
            selectedKioskPane.hidden = false;

            let buttonOffset = -(kioskInfoHeight)
            if myLocationContainerBottomConstraint.constant != buttonOffset {
                myLocationContainerBottomConstraint.constant = buttonOffset
                mapView.setNeedsLayout()
            }
            
            if (!SessionData.Instance.seenReminder && reminderMode) {
                topHelp.hidden = true;
                bottomHelp.hidden = false;
                SessionData.Instance.seenReminder = true;
                SessionData.Instance.save();
            }
        }
        selectedKiosk = kiosk;
        selectedLogo.image = nil;
        selectedLogo.setImageWithURL(getKioskLogoUrl(kiosk));
        selectedName.text = kiosk.organizations[0] as String;
        selectedAddress.text = kiosk.fullAddress as String;
        if (kiosk.hours != nil) {
           let closed = NSLocalizedString("FIND_STATION_VIEW_STATION_DETAIL_STORE_HOURS_CLOSED", comment: "Text to display when station is closed.");
            
            mondayHours.text = kiosk.hours!.valueForKey("Mon") as? String? ?? closed;
            tuesdayHours.text = kiosk.hours!.valueForKey("Tue") as? String? ?? closed;
            wednesdayHours.text = kiosk.hours!.valueForKey("Wed") as? String? ?? closed;
            thursdayHours.text = kiosk.hours!.valueForKey("Thu") as? String? ?? closed;
            fridayHours.text = kiosk.hours!.valueForKey("Fri") as? String? ?? closed;
            saturdayHours.text = kiosk.hours!.valueForKey("Sat") as? String? ?? closed;
            sundayHours.text = kiosk.hours!.valueForKey("Sun") as? String? ?? closed;
        } else {
            let notAvailable = NSLocalizedString("FIND_STATION_VIEW_STATION_DETAIL_STORE_HOURS_NOT_AVAILABLE", comment: "Text to display when station hours of availability is not available.");
            mondayHours.text = notAvailable;
            tuesdayHours.text = notAvailable;
            wednesdayHours.text = notAvailable;
            thursdayHours.text = notAvailable;
            fridayHours.text = notAvailable;
            saturdayHours.text = notAvailable;
            sundayHours.text = notAvailable;
        }
        
        let distance = distanceFromCurrentLocation(kiosk.location!);
        if (distance >= 0) {
            selectedDistance.text = distanceFormatter.stringFromDistance(distance);
        } else {
            selectedDistance.text = "";
        }
    }
    
    func getKioskLogoUrl(kiosk: KioskInfo!) -> NSURL {
        var modifiedName = kiosk.organizations[0];
        modifiedName = modifiedName.stringByReplacingOccurrencesOfString(" ", withString: "_").stringByReplacingOccurrencesOfString("'", withString: "").stringByReplacingOccurrencesOfString("&", withString: "");
        return NSURL(string: "https://az646341.vo.msecnd.net/retailer-icons/\(modifiedName)_100.png")!;
    }
    
    @IBAction func startReminder(sender: AnyObject) {
        reminderOverlay.hidden = true;
        self.navigationController!.navigationBarHidden = false;
        populateClusterManager();
    }
    
    @IBAction func cancelReminder(sender: AnyObject) {
        self.navigationController!.navigationBarHidden = false;
        self.navigationController!.popViewControllerAnimated(true);
    }
    
    @IBAction func setReminder(sender: AnyObject) {
        bottomHelp.hidden = true;
        let eventStore = EKEventStore();
        eventStore.requestAccessToEntityType(EKEntityType.Event, completion: { granted, error in
            if (granted) {
                let eventController = EKEventEditViewController();
                let event = EKEvent(eventStore: eventStore);
                if let calendar: EKCalendar = eventStore.defaultCalendarForNewEvents {
                    event.calendar = calendar;
                    event.startDate = NSDate();
                    event.endDate = NSDate();
                    event.title = NSLocalizedString("FIND_STATION_VIEW_CHECK_IN_REMINDER_CALENDAR_EVENT_TITLE", comment: "Title of calendar reminder to check in to a higi station.");
                    event.location = self.selectedKiosk!.fullAddress as String;
                    eventController.event = event;
                    eventController.eventStore = eventStore;
                    eventController.editViewDelegate = self;
                    self.presentViewController(eventController, animated: true, completion: nil);
                } else {
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        let alertTitle = NSLocalizedString("FIND_STATION_VIEW_CHECK_IN_REMINDER_CALENDAR_NOT_FOUND_ALERT_TITLE", comment: "Title of alert displayed when the calendar can not be found.")
                        let alertMessage = NSLocalizedString("FIND_STATION_VIEW_CHECK_IN_REMINDER_CALENDAR_NOT_FOUND_ALERT_MESSAGE", comment: "Message of alert displayed when the calendar can not be found.")
                        let cancelActionTitle = NSLocalizedString("FIND_STATION_VIEW_CHECK_IN_REMINDER_CALENDAR_NOT_FOUND_ALERT_ACTION_CANCEL_TITLE", comment: "Title of cancel alert action displayed when the calendar can not be found.")
                        
                        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
                        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .Default, handler: nil)
                        alertController.addAction(cancelAction)
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    });
                }
            } else {
            
            }
        });
    }
    
    func eventEditViewController(controller: EKEventEditViewController, didCompleteWithAction action: EKEventEditViewAction) {
        controller.dismissViewControllerAnimated(true, completion: nil);
    }
    
    @IBAction func closeTopHelp(sender: AnyObject) {
        topHelp.hidden = true;
    }
    
    @IBAction func closeBottomHelp(sender: AnyObject) {
        bottomHelp.hidden = true;
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        autoCompleteResults = [];
        autoCompleteTable.reloadData();
        toggleAutoCompleteTable();
        textField.resignFirstResponder();
        return true;
    }
    
    func markerSelected(marker: GMSMarker) {
        setSelectedKiosk(marker.userData.valueForKey("kiosk") as! KioskInfo);
        updateKioskPositions();
    }
    
    func clusterSelected(cluster: GMSMarker!) {
        mapView.animateWithCameraUpdate(GMSCameraUpdate.setTarget(cluster.position, zoom: mapView.camera.zoom * 1.25));
        updateKioskPositions();
    }
    
    func onMapPan() {
        updateKioskPositions();
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // Handled by observeValueForKeyPath for 7.1 compatibility
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<()>) {
        if (!firstLocation && keyPath == "myLocation") {
            firstLocation = true;
            mapView.camera = GMSCameraPosition.cameraWithTarget(mapView.myLocation.coordinate, zoom: 11);
            updateKioskPositions();
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
}

extension FindStationViewController {
    
    func didTapDoneButton(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension FindStationViewController: UniversalLinkHandler {
    
    func handleUniversalLink(URL: NSURL, pathType: PathType, parameters: [String]?) {
        FindStationViewController.navigateToStationLocator(nil)
    }
    
    class func navigateToStationLocator(presentedViewController: UIViewController?) {
        guard let mainTabBarController = Utility.mainTabBarController() else { return }
        
        let findStation = FindStationViewController(nibName: "FindStationView", bundle: nil)
        let findStationNav = UINavigationController(rootViewController: findStation)
        dispatch_async(dispatch_get_main_queue(), {
            InterfaceOrientation.force(.Portrait)
            
            presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
            
            mainTabBarController.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
            mainTabBarController.presentViewController(findStationNav, animated: true, completion: nil)
        })
    }
}
