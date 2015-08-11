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

class FindStationViewController: BaseViewController, GMSMapViewDelegate, UITableViewDataSource, UITableViewDelegate, EKEventEditViewDelegate, UINavigationControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, ClusterManagerDelegate {
    
    @IBOutlet weak var mapContainer: UIView!
    
    @IBOutlet weak var autoCompleteTable: UITableView!
    @IBOutlet weak var autoCompleteSpinner: UIActivityIndicatorView!
    @IBOutlet weak var noResults: UIImageView!
    @IBOutlet weak var visibleKiosksTable: UITableView!
    @IBOutlet weak var selectedKioskPane: UIView!
    @IBOutlet weak var selectedLogo: UIImageView!
    @IBOutlet weak var selectedName: UILabel!
    @IBOutlet weak var selectedAddress: UILabel!
    @IBOutlet weak var selectedDistance: UILabel!
    
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
    
    var locationManager: CLLocationManager!;
    
    var listOpen = false, autoCompleteOpen = false, selectedPaneOpen = false, reminderMode = true, firstLocation = false;
    
    var mapView: GMSMapView!;
    
    var visibleKiosks: [KioskInfo] = [], autoCompleteResults: [KioskInfo] = [];
    
    var searchField: UITextField!;
    
    var selectedKiosk: KioskInfo?;
    
    var listButton: UIButton!;
    
    var selectedMarker: GMSMarker?;
    
    var currentAutoCompleteTask = NSOperationQueue(), currentVisibleKioskTask = NSOperationQueue();
    
    var autoCompleteY, visibleY, selectedY: CGFloat!;
    
    var clusterManager:GClusterManager = GClusterManager();
    
    override func viewDidLoad()  {
        super.viewDidLoad();
        self.fakeNavBar.alpha = 1.0;
        self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
        (self.navigationItem.leftBarButtonItem!.customView! as! UIButton).setBackgroundImage(UIImage(named: "nav_ocmicon_inverted"), forState: UIControlState.Normal);
        listButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30));
        listButton.setBackgroundImage(UIImage(named: "map_listviewicon"), forState: UIControlState.Normal);
        listButton.addTarget(self, action: "toggleList:", forControlEvents: UIControlEvents.TouchUpInside);
        var listBarItem = UIBarButtonItem();
        listBarItem.customView = listButton;
        self.navigationItem.rightBarButtonItem = listBarItem;
        self.revealController.panGestureRecognizer().enabled = false;
        self.shouldShowDailyPoints = false;
        
        searchField = UITextField(frame: CGRect(x: 0, y: 0, width: 95, height: 40));
        searchField.font = UIFont.systemFontOfSize(12);
        searchField.placeholder = "Search by store name, city, zip";
        searchField.leftViewMode = UITextFieldViewMode.Always;
        searchField.leftView = UIImageView(image: UIImage(named: "search_icon"));
        searchField.leftView!.frame = CGRect(x: 0, y: 5, width: 30, height: 20);
        searchField.leftView!.contentMode = UIViewContentMode.ScaleAspectFit;
        searchField.clearButtonMode = UITextFieldViewMode.WhileEditing;
        searchField.delegate = self;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        (self.navigationController as! MainNavigationController).drawerController?.selectRowAtIndex(3);

        mapContainer.frame = CGRect(x: 64, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - 64);
        
        searchField.addTarget(self, action: "textFieldChanged", forControlEvents: UIControlEvents.EditingChanged);
        self.navigationItem.titleView = searchField;
        
        var fontSize = mondayHours.font.pointSize;
        var formatter = NSDateFormatter();
        formatter.dateFormat = "EEEE";
        var dayString: String = formatter.stringFromDate(NSDate());
        switch dayString {
        case "Monday":
            mondayHours.font = UIFont.boldSystemFontOfSize(fontSize);
        case "Tuesday":
            tuesdayHours.font = UIFont.boldSystemFontOfSize(fontSize);
        case "Wednesday":
            wednesdayHours.font = UIFont.boldSystemFontOfSize(fontSize);
        case "Thursday":
            thursdayHours.font = UIFont.boldSystemFontOfSize(fontSize);
        case "Friday":
            fridayHours.font = UIFont.boldSystemFontOfSize(fontSize);
        case "Saturady":
            saturdayHours.font = UIFont.boldSystemFontOfSize(fontSize);
        case "Sunday":
            sundayHours.font = UIFont.boldSystemFontOfSize(fontSize);
        default:
            // Do nothing
            var i = 0;
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
                
                var stretchedImage = UIImage(named: "bg_tap_reminder")!;
                stretchedImage = stretchedImage.resizableImageWithCapInsets(UIEdgeInsets(top: 40, left: 5, bottom: 160, right: 100));
                bottomHelpBackground.image = stretchedImage;
            }
        }
        
        autoCompleteTable.tableFooterView = UIView(frame: CGRectZero);
        visibleKiosksTable.tableFooterView = UIView(frame: CGRectZero);
        
        selectedY = self.view.frame.height - 70;
        visibleY = self.view.frame.height;
        autoCompleteY = self.view.frame.height;
        
        setupMap();
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveApiNotification:", name: ApiUtility.KIOSKS, object: nil);
        
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil);
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        if (UIDevice.currentDevice().systemVersion >= "8.0") {
            locationManager = CLLocationManager();
            locationManager.requestWhenInUseAuthorization();
            locationManager.delegate = self;
        }
        
        if (SessionController.Instance.kioskList != nil) {
            populateClusterManager();
        }
    }
    
    override func receiveApiNotification(notification: NSNotification) {
        populateClusterManager();
        clusterManager.cluster();
        updateKioskPositions();
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        var height = self.view.frame.height;
        if (visibleY > self.view.frame.height) {
            selectedY = self.view.frame.height - 70;
            visibleY = self.view.frame.height;
            autoCompleteY = self.view.frame.height;
            mapView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 64);
        }
        autoCompleteTable.frame.size.height = self.view.frame.size.height - 64;
        autoCompleteTable.frame.origin.y = autoCompleteY;
        visibleKiosksTable.frame.size.height = self.view.frame.size.height - 64;
        visibleKiosksTable.frame.origin.y = visibleY;
        selectedKioskPane.frame.origin = CGPoint(x: 0, y: selectedY);
    }
    
    override func viewDidDisappear(animated: Bool) {
        currentVisibleKioskTask.cancelAllOperations();
        super.viewDidDisappear(animated)
    }
    
    func setupMap() {
        var camera = GMSCameraPosition.cameraWithLatitude(41.888254, longitude: -87.637681, zoom: 11);
        mapView = GMSMapView.mapWithFrame(CGRect(origin: CGPoint(x: 0, y: 0), size: mapContainer.frame.size), camera: camera);
        mapView.myLocationEnabled = true;
        mapView.settings.myLocationButton = true;

        clusterManager = GClusterManager(mapView: mapView, algorithm: NonHierarchicalDistanceBasedAlgorithm(), renderer: HigiClusterRenderer(mapView: mapView))
        mapView.delegate = clusterManager;
        clusterManager.delegate = self;
        
        var myLocationButton = mapView.subviews.last as! UIView;
        myLocationButton.frame.origin.x = 10;
        mapContainer.addSubview(mapView);
    }
    
    func populateClusterManager() {
        if (SessionController.Instance.kioskList == nil) {
            return;
        }
        for kiosk in SessionController.Instance.kioskList {
            let item = ClusterKiosk();
            item.setPosition(kiosk.position!);
            item.setData(["kiosk": kiosk]);
            clusterManager.addItem(item);
        }
        updateKioskPositions();
    }
    
    func updateKioskPositions() {
        if (SessionController.Instance.kioskList == nil) {
            return;
        }
        currentVisibleKioskTask.cancelAllOperations();
        searchField.resignFirstResponder();
        visibleKiosks = [];
        var bounds = GMSCoordinateBounds(region: self.mapView!.projection.visibleRegion());
        
        currentVisibleKioskTask.addOperationWithBlock({
            
            for i in 0..<SessionController.Instance.kioskList.count {
                var kiosk = SessionController.Instance.kioskList[i];
                if (kiosk.group == "retired" || kiosk.group == "removed") {
                    continue;
                }
                if (bounds.containsCoordinate(kiosk.position!)) {
                    self.visibleKiosks.append(kiosk);

                }
                if ((self.currentVisibleKioskTask.operations[0] as! NSOperation).cancelled) {
                    return;
                }
            }
            if ((self.currentVisibleKioskTask.operations[0] as! NSOperation).cancelled) {
                return;
            }
            self.visibleKiosks.sort { self.calcDistance($0.position!) < self.calcDistance($1.position!) };
            if ((self.currentVisibleKioskTask.operations[0] as! NSOperation).cancelled) {
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
            (self.navigationItem.rightBarButtonItem!.customView! as! UIButton).setBackgroundImage(UIImage(named: "map_listviewicon.png"), forState: UIControlState.Normal);
        } else {
            (self.navigationItem.rightBarButtonItem!.customView! as! UIButton).setBackgroundImage(UIImage(named: "map_mapviewicon.png"), forState: UIControlState.Normal);
        }
        if (listOpen) {
            UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
                
                self.visibleKiosksTable.frame.origin.y = self.view.frame.size.height;
                
                }, completion: nil);
        } else {
            UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
                
                self.visibleKiosksTable.frame.origin.y = 64;
                
                }, completion: nil);
        }
        listOpen = !listOpen;
    }
    
    func calcDistance(position: CLLocationCoordinate2D) -> Double {
        if (mapView.myLocation != nil) {
            var kioskPos = CLLocation(latitude: position.latitude, longitude: position.longitude);
            return kioskPos.distanceFromLocation(mapView.myLocation) * 0.000621371;
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
        if (count(searchField.text) == 0) {
            noResults.hidden = true;
            autoCompleteTable.reloadData();
            if (autoCompleteOpen) {
                toggleAutoCompleteTable();
            }
        } else {
            currentAutoCompleteTask.addOperationWithBlock( {
                let size = count(self.searchField.text);
                for kiosk in SessionController.Instance.kioskList {
                    if (kiosk.group == "retired" || kiosk.group == "removed") {
                        continue;
                    }
                    if ((self.currentAutoCompleteTask.operations[0] as! NSOperation).cancelled && size != count(self.searchField.text)) {
                        return;
                    }
                    if (kiosk.organizations[0].lowercaseString.rangeOfString(self.searchField.text.lowercaseString) != nil) {
                        self.autoCompleteResults.append(kiosk);
                    } else if (kiosk.fullAddress.lowercaseString.rangeOfString(self.searchField.text.lowercaseString) != nil) {
                        self.autoCompleteResults.append(kiosk);
                    }
                }
                if ((self.currentAutoCompleteTask.operations[0] as! NSOperation).cancelled && size != count(self.searchField.text)) {
                    return;
                }
                self.autoCompleteResults.sort { self.calcDistance($0.position!) < self.calcDistance($1.position!) };
                if ((self.currentAutoCompleteTask.operations[0] as! NSOperation).cancelled && size != count(self.searchField.text)) {
                    return;
                }
                if (size == count(self.searchField.text)) {
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
        
        var distance = calcDistance(kiosk.position!);
        if (distance >= 0) {
            var formattedDistance = distance >= 10 ? "\(Int(distance))" : String(format: "%.1f", distance);
            cell.distance.text = "\(formattedDistance) mi";
        } else {
            cell.distance.text = "";
        }
        return cell;
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchField.resignFirstResponder();
    }
    
    @IBAction func toggleSelectedPane(sender: AnyObject!) {
        var diff: CGFloat = 0.0;
        var bottom: CGFloat = self.view.frame.size.height - 70.0;
        var top: CGFloat = self.view.frame.size.height - 280.0;
        if (selectedPaneOpen) {
            diff = selectedKioskPane.frame.origin.y - bottom;
            self.selectedY = bottom;
            UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
                
                self.selectedKioskPane.frame.origin.y = bottom;
                
                }, completion: nil);
        } else {
            diff = selectedKioskPane.frame.origin.y - top;
            self.selectedY = top;
            UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
                
                self.selectedKioskPane.frame.origin.y = top;
                
                }, completion: nil);
        }
        mapView.animateWithCameraUpdate(GMSCameraUpdate.scrollByX(0.0, y: diff * 0.5));
        selectedPaneOpen = !selectedPaneOpen;
    }
    
    @IBAction func selectedPaneDragged(sender: UIPanGestureRecognizer) {
        var bottom: CGFloat = self.view.frame.size.height - 70.0;
        var top: CGFloat = self.view.frame.size.height - 280.0;
        if (sender.state == UIGestureRecognizerState.Ended) {
            if (selectedPaneOpen) {
                if (selectedKioskPane.frame.origin.y > top + 45) {
                    toggleSelectedPane(nil);
                } else  {
                    selectedPaneOpen = false;
                    toggleSelectedPane(nil);
                }
            } else {
                if (selectedKioskPane.frame.origin.y < bottom - 45) {
                    toggleSelectedPane(nil);
                } else  {
                    selectedPaneOpen = true;
                    toggleSelectedPane(nil);
                }
            }
        } else if (sender.state != UIGestureRecognizerState.Began) {
            var translation = sender.translationInView(self.view).y;
            selectedKioskPane.frame.origin.y += translation;
            if (selectedKioskPane.frame.origin.y < top) {
                translation += top - selectedKioskPane.frame.origin.y;
                selectedKioskPane.frame.origin.y = top;
                selectedY = top;
            } else if (selectedKioskPane.frame.origin.y > bottom) {
                selectedKioskPane.frame.origin.y = bottom;
                selectedY = bottom;
                 translation -= selectedKioskPane.frame.origin.y - bottom;
            }
            mapView.moveCamera(GMSCameraUpdate.scrollByX(0, y: -translation * 0.5));
        }
        sender.setTranslation(CGPointZero, inView: self.view);
    }
    
    func toggleAutoCompleteTable() {
        if (!autoCompleteOpen) {
            if (listOpen) {
                toggleList(nil);
            }
            listButton.hidden = true;
            self.autoCompleteY = 64;
            UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
                
                self.autoCompleteTable.frame.origin.y = 64;
                
                }, completion: nil);
        } else {
            noResults.hidden = true;
            autoCompleteSpinner.hidden = true;
            autoCompleteY = self.view.frame.height;
            UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
                
                self.autoCompleteTable.frame.origin.y = self.view.frame.height;
                
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
            selectedKioskPane.hidden = false;
            (mapView.subviews.last as! UIView).frame.origin.y -= 70;
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
            mondayHours.text = kiosk.hours!.valueForKey("Mon") as? String? ?? "Closed";
            tuesdayHours.text = kiosk.hours!.valueForKey("Tue") as? String? ?? "Closed";
            wednesdayHours.text = kiosk.hours!.valueForKey("Wed") as? String? ?? "Closed";
            thursdayHours.text = kiosk.hours!.valueForKey("Thu") as? String? ?? "Closed";
            fridayHours.text = kiosk.hours!.valueForKey("Fri") as? String? ?? "Closed";
            saturdayHours.text = kiosk.hours!.valueForKey("Sat") as? String? ?? "Closed";
            sundayHours.text = kiosk.hours!.valueForKey("Sun") as? String? ?? "Closed";
        } else {
            mondayHours.text = "Not available";
            tuesdayHours.text = "Not available";
            wednesdayHours.text = "Not available";
            thursdayHours.text = "Not available";
            fridayHours.text = "Not available";
            saturdayHours.text = "Not available";
            sundayHours.text = "Not available";
        }
        var distance = calcDistance(kiosk.position!);
        if (distance >= 0) {
            var formattedDistance = distance >= 10 ? "\(Int(distance))" : String(format: "%.1f", distance);
            selectedDistance.text = "\(formattedDistance) mi";
        } else {
            selectedDistance.text = "";
        }
    }
    
    func getKioskLogoUrl(kiosk: KioskInfo!) -> NSURL {
        var modifiedName = kiosk.organizations[0];
        modifiedName = modifiedName.stringByReplacingOccurrencesOfString(" ", withString: "_").stringByReplacingOccurrencesOfString("'", withString: "").stringByReplacingOccurrencesOfString("&", withString: "");
        return NSURL(string: "http://az646341.vo.msecnd.net/retailer-icons/\(modifiedName)_100.png")!;
    }
    
    @IBAction func startReminder(sender: AnyObject) {
        reminderOverlay.hidden = true;
        self.fakeNavBar.alpha = 1;
        self.navigationController!.navigationBarHidden = false;
        populateClusterManager();
    }
    
    @IBAction func cancelReminder(sender: AnyObject) {
        self.navigationController!.navigationBarHidden = false;
        self.navigationController!.popViewControllerAnimated(true);
    }
    
    @IBAction func setReminder(sender: AnyObject) {
        bottomHelp.hidden = true;
        var eventStore = EKEventStore();
        eventStore.requestAccessToEntityType(EKEntityTypeEvent, completion: { granted, error in
            if (granted) {
                var eventController = EKEventEditViewController();
                var event = EKEvent(eventStore: eventStore);
                var calendar = eventStore.defaultCalendarForNewEvents;
                if (calendar != nil) {
                    event.calendar = calendar;
                    event.startDate = NSDate();
                    event.endDate = NSDate();
                    event.title = "Check in to a higi Station!";
                    event.location = self.selectedKiosk!.fullAddress as String;
                    eventController.event = event;
                    eventController.eventStore = eventStore;
                    eventController.editViewDelegate = self;
                    self.presentViewController(eventController, animated: true, completion: nil);
                } else {
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        UIAlertView(title: "Cannot find calendar", message: "We could not find your default calendar", delegate: nil, cancelButtonTitle: "OK").show();
                    });
                }
            } else {
            
            }
        });
    }
    
    func eventEditViewController(controller: EKEventEditViewController!, didCompleteWithAction action: EKEventEditViewAction) {
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
        autoCompleteY = self.view.frame.height;
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
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer != self.revealController.panGestureRecognizer() && otherGestureRecognizer != self.revealController.panGestureRecognizer();
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // Handled by observeValueForKeyPath for 7.1 compatibility
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<()>) {
        if (!firstLocation && keyPath == "myLocation") {
            firstLocation = true;
            mapView.camera = GMSCameraPosition.cameraWithTarget(mapView.myLocation.coordinate, zoom: 11);
            updateKioskPositions();
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        mapView.removeObserver(self, forKeyPath: "myLocation");
        firstLocation = false;
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
}