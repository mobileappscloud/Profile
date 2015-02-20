//
//  BaseGraphView.swift
//  higi
//
//  Created by Dan Harms on 7/18/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class GraphView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var graphContainer: UIView!
    @IBOutlet var highlightContainer: UIView!
    @IBOutlet var highlightText: UILabel!
    @IBOutlet var trendText: UILabel!
    
    @IBOutlet var measureValue: UILabel!
    @IBOutlet var measureClass: UILabel!
    @IBOutlet var measureUnit: UILabel!
    @IBOutlet var infoButton: UIButton!
    @IBOutlet var checkinTable: UITableView!
    @IBOutlet var noData: UIView!
    @IBOutlet var noDataGraph: UIImageView!
    @IBOutlet var findStationButton: UIButton!
    @IBOutlet var checkPulseButton: UIButton!
    @IBOutlet weak var checkinContainer: UIView!
    @IBOutlet weak var checkinBlur: UIView!
    @IBOutlet weak var checkinCardContainer: UIView!
    
    @IBOutlet weak var selectedMarker: UIImageView!
    @IBOutlet weak var selectedMarker2: UIImageView!
    
    var checkins: [HigiCheckin] = [];
    
    var graph: BaseCustomGraphHostingView?;
    
    var isPortrait: Bool = false;
    
    var delegate: GraphDelegate!;
    
    var selected = 0;
    
    var infoOverlay: InfoOverlayView!;
    
    var noDataView: UIView!;
    
    class func createViewFromNib(isPortrait: Bool) -> GraphView {
        if (isPortrait) {
            return UINib(nibName: "PortraitGraph", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as GraphView
        } else {
            return UINib(nibName: "LandscapeGraph", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as GraphView
        }
    }
    
    func initializeView(delegate: GraphDelegate, frame: CGRect, checkins: [HigiCheckin], isPortrait: Bool) {
        self.delegate = delegate;
        self.frame = frame;
        self.checkins = checkins;
        self.isPortrait = isPortrait
        self.backgroundColor = delegate.getBackgroundColor();
        if (self.checkins.count > 0) {
            graph = delegate.createGraph(checkins, isPortrait: isPortrait, frame: CGRect(origin: CGPoint(x: 0, y: 0), size: graphContainer.frame.size));
            if (graph != nil) {
                graphContainer.addSubview(graph!);
                graph!.setupWithDefaults();
                setSelectedCheckin(checkins[checkins.count - selected - 1]);
            } else if (isPortrait) {
                measureValue.hidden = true;
                measureClass.hidden = true;
                measureUnit.text = "Learn more about \(delegate.getTitle())";
                noData.hidden = false;
            }
            
            if (isPortrait) {
                noData.frame.size.height = 0;
                measureUnit.text = delegate.getUnit();
                checkinTable.separatorInset = UIEdgeInsetsZero;
                checkinTable.tableHeaderView?.frame = CGRectZero;
                checkinTable.tableFooterView = UIView(frame: CGRectZero);
                if (UIDevice.currentDevice().systemVersion >= "8.0") {
                    var effect = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light));
                    effect.frame = checkinBlur.frame;
                    checkinBlur.addSubview(effect);
                } else {
                    checkinBlur.backgroundColor = UIColor.whiteColor();
                    checkinBlur.alpha = 0.7;
                }
            }
        } else {
            if (isPortrait) {
                measureValue.hidden = true;
                measureClass.hidden = true;
                measureUnit.text = "Learn more about \(delegate.getTitle())";
                trendText.text = "";
                noDataGraph.hidden = false;
                findStationButton.layer.borderWidth = 1.0;
                findStationButton.layer.borderColor = Utility.colorFromHexString("#76C044").CGColor;
                
                checkPulseButton.layer.borderWidth = 1.0;
                checkPulseButton.layer.borderColor = Utility.colorFromHexString("#76C044").CGColor;
            } else {
                highlightContainer.hidden = true;
                trendText.hidden = true;
                noDataGraph.hidden = false;
            }
        }
        
    }
    
    func pointClicked(index: Int) {
        var viewController = Utility.getViewController(self) as BodyStatsViewController?;
        if (viewController != nil && index < checkins.count) {
            viewController!.setSelected(checkins[index]);
        }
    }
    
    func updateTrend(trend: String) {
        trendText.text = trend;
    }
    
    func setRange(mode: Int, delegate: NSObject!) {
        graph!.setRange(mode, delegate: delegate);
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var viewController = Utility.getViewController(self) as BodyStatsViewController!;
        if (viewController != nil) {
            viewController.setSelected(checkins[checkins.count - indexPath.item - 1]);
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("BodyStatCell") as BodyStatCheckinCell!;
        if (cell == nil) {
            cell = UINib(nibName: "CheckinCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as BodyStatCheckinCell;
            cell.parentViewController = Utility.getViewController(self) as BodyStatsViewController!;
            cell.checkinBlur = checkinBlur;
            cell.checkinCardContainer = checkinCardContainer;
            cell.checkinContainer = checkinContainer;
        }
        var checkin = checkins[checkins.count - 1 - indexPath.item];
        var dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "MMMM d, yyyy";
        cell.date.text = dateFormatter.stringFromDate(checkin.dateTime);
        cell.selectionIndicator.hidden = indexPath.item != checkins.count - selected - 1;
        cell.contentView.backgroundColor = indexPath.item == checkins.count - selected - 1 ? UIColor.whiteColor() : Utility.colorFromHexString("#EFEFEF");
        cell.measureValue.text = delegate.getMeasureValue(checkin);
        delegate.cellForCheckin(checkin, cell: cell);
        cell.checkin = checkin;
        return cell;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkins.count;
    }
    
    @IBAction func infoClicked(sender: AnyObject) {
        Flurry.logEvent("BodystatInfo_Pressed");
        var viewController = Utility.getViewController(self) as BaseViewController?;
        if (viewController != nil) {
            viewController!.revealController.shouldRotate = false;
            viewController!.revealController.supportedOrientations = UIInterfaceOrientationMask.Portrait.rawValue;
            viewController!.navigationController!.navigationBarHidden = true;
            viewController!.fakeNavBar.hidden = true;
            infoOverlay = UINib(nibName: "InfoOverlay", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as? InfoOverlayView;
            infoOverlay.frame = viewController!.view.frame;
            if (UIDevice.currentDevice().systemVersion >= "8.0") {
                var effect = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.ExtraLight));
                effect.frame = infoOverlay!.blurLayer.frame;
                infoOverlay.blurLayer.addSubview(effect);
            } else {
                infoOverlay.blurLayer.backgroundColor = UIColor.whiteColor();
                infoOverlay.blurLayer.alpha = 0.95;
            }
            var infoImage = delegate.getInfoImage();
            var height = (infoImage.size.height / infoImage.size.width) * frame.width;
            var newFrame = CGRect(x: 0, y: 0, width: frame.width, height: height);
            infoOverlay.scrollView.contentSize = newFrame.size;
            var imageView = UIImageView(frame: newFrame);
            imageView.image = infoImage;
            infoOverlay.scrollView.addSubview(imageView);
            infoOverlay.closeButton.addTarget(self, action: "closeInfo:", forControlEvents: UIControlEvents.TouchUpInside);
            infoOverlay.alpha = 0;
            UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: {
                
                self.infoOverlay.alpha = 1.0;
                
                }, completion: nil);
            
            viewController?.view.addSubview(infoOverlay);
        }
    }
    
    func closeInfo(sender: AnyObject) {
        var viewController = Utility.getViewController(self) as BaseViewController?;
        if (viewController != nil) {
            viewController!.navigationController!.navigationBarHidden = false;
            viewController!.fakeNavBar.hidden = false;
            if (checkins.count > 0) {
                viewController!.revealController.supportedOrientations = UIInterfaceOrientationMask.Portrait.rawValue | UIInterfaceOrientationMask.LandscapeLeft.rawValue | UIInterfaceOrientationMask.LandscapeRight.rawValue;
                viewController!.revealController.shouldRotate = true;
            }
        }
        infoOverlay.removeFromSuperview();
    }
    
    func setSelectedCheckin(selectedCheckin: HigiCheckin) {
        if (checkins.count == 0) {
            return;
        }
        var selectedIndex = checkins.count - 1;
        for index in 0..<checkins.count {
            if (selectedCheckin.dateTime.compare(checkins[index].dateTime) == NSComparisonResult.OrderedAscending) {
                selectedIndex = index - 1;
                break;
            }
        }
        selectedIndex = max(min(selectedIndex, checkins.count - 1), 0);
        var checkin = checkins[selectedIndex];
        if (isPortrait) {
            var  cell = checkinTable.cellForRowAtIndexPath(NSIndexPath(forItem: checkins.count - selectedIndex - 1, inSection: 0)) as? BodyStatCheckinCell;
            var oldSelected = checkinTable.cellForRowAtIndexPath(NSIndexPath(forItem: checkins.count - selected - 1, inSection: 0)) as? BodyStatCheckinCell;
            if (oldSelected != nil) {
                oldSelected!.selectionIndicator.hidden = true;
                oldSelected!.contentView.backgroundColor = Utility.colorFromHexString("#EFEFEF");
            }
            
            if (cell != nil) {
                cell!.selectionIndicator.hidden = false;
                cell!.selectionStyle = UITableViewCellSelectionStyle.None;
                cell!.contentView.backgroundColor = UIColor.whiteColor();
            } else {
                selected = selectedIndex;
                checkinTable.scrollToRowAtIndexPath(NSIndexPath(forItem: checkins.count - selectedIndex - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false);
            }
            measureValue.text = delegate.getMeasureValue(checkin);
            measureClass.text = delegate.getMeasureClass(checkin);
        } else {
            var dateFormatter = NSDateFormatter();
            dateFormatter.dateFormat = "MMMM d, yyyy";
            var dateString = dateFormatter.stringFromDate(checkin.dateTime);
            var highlightString = "\(dateString) \(checkin.sourceVendorId!) ";
            var boldIndex = countElements(highlightString) - 1;
            
            highlightString += delegate.getHighlightString(checkin);
            
            var attributedText = NSMutableAttributedString(string: highlightString);
            
            var boldAttrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(18)];
            
            var boldRange = NSMakeRange(boldIndex, countElements(highlightString) - boldIndex);
            
            attributedText.setAttributes(boldAttrs, range: boldRange);
            
            highlightText.attributedText = attributedText;
        }
        
        var dateX = CGFloat(checkin.dateTime.timeIntervalSince1970);
        var xRange = (graph!.hostedGraph.defaultPlotSpace as CPTXYPlotSpace).xRange;
        if (Double(dateX) >= xRange.locationDouble && Double(dateX) <= xRange.locationDouble + xRange.lengthDouble) {
            selectedMarker.hidden = false;
            selectedMarker2.hidden = false;
            var markerPoint = delegate.getScreenPoint(self.graph!, checkin: checkin, isPortrait: isPortrait);
            markerPoint.x -= 10;
            markerPoint.y += 10;
            selectedMarker.frame.origin = markerPoint;
            
            
            var markerPoint2 = delegate.getScreenPoint2(self.graph!, checkin: checkin, isPortrait: isPortrait);
            if (markerPoint2 != nil) {
                markerPoint2!.x -= 10;
                markerPoint2!.y += 10;
                selectedMarker2.frame.origin = markerPoint2!;
            } else {
                selectedMarker2.hidden = true;
            }
        } else {
            selectedMarker.hidden = true;
            selectedMarker2.hidden = true;
        }
        selected = selectedIndex;
    }
    @IBAction func gotoFindStation(sender: AnyObject) {
        Flurry.logEvent("NoDataFindStation_Pressed");
        var viewController = Utility.getViewController(self) as BaseViewController?;
        if (viewController != nil) {
            (viewController!.navigationController as MainNavigationController).drawerController?.tableView.selectRowAtIndexPath(NSIndexPath(forItem: 2, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None);
            viewController!.navigationController!.pushViewController(FindStationViewController(nibName: "FindStationView", bundle: nil), animated: true);
        }
    }
    @IBAction func gotoPulse(sender: AnyObject) {
        Flurry.logEvent("NoDataPulse_Pressed");
        var viewController = Utility.getViewController(self) as BaseViewController?;
        if (viewController != nil) {
            (viewController!.navigationController as MainNavigationController).drawerController?.tableView.selectRowAtIndexPath(NSIndexPath(forItem: 3, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None);
            viewController!.navigationController!.pushViewController(PulseHomeViewController(nibName: "PulseHomeView", bundle: nil), animated: true);
        }
    }
}