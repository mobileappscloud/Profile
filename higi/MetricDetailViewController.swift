//
//  MetricDetailViewController.swift
//  higi
//
//  Created by Remy Panicker on 1/29/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class MetricDetailViewController: UIViewController {
    
    @IBOutlet var headerView: MetricCheckinSummaryView!
    
    @IBOutlet private var graphicContainerView: UIView!
    
    @IBOutlet private var infoScrollView: UIScrollView!
    
    @IBOutlet private var scrollableContentView: UIView!
    
    var dismissByTappingHeader = true
    var dismissBySwipingHeader = true
    var dismissWhenNotVerticallyCompact = true
    
    lazy private var tapGestureRecognizer: UITapGestureRecognizer = {
       let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: Selector("tapped:"))
        return tap
    }()
    
    lazy private var swipeGestureRecognizer: UISwipeGestureRecognizer = {
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = .Down
        swipe.addTarget(self, action: Selector("swiped:"))
        return swipe
    }()
    
    var themeColor: UIColor? = Theme.Color.primary
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if dismissByTappingHeader {
            self.headerView.addGestureRecognizer(tapGestureRecognizer)
        }
        if dismissBySwipingHeader {
            self.headerView.addGestureRecognizer(swipeGestureRecognizer)
        }
    }
}

extension MetricDetailViewController {
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        if self.traitCollection.verticalSizeClass != .Compact && dismissWhenNotVerticallyCompact {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

// MARK: - Gesture Recognizer Actions

extension MetricDetailViewController {
    /**
     Selector for swipe gesture recognizer.
     
     - parameter swipe: Swipe gesture recognizer.
     */
    func swiped(swipe: UISwipeGestureRecognizer) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     Selector for tap gesture recognizer.
     
     - parameter tap: Tap gesture recognizer.
     */
    func tapped(tap: UITapGestureRecognizer) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - Configure Graphic Container

extension MetricDetailViewController {
    
    func configureMeter(activities: HigiActivitySummary) {
        var screenBounds = UIScreen.mainScreen().bounds
        screenBounds.size.width = (screenBounds.size.width/2) * 0.6
        screenBounds.size.height = screenBounds.width
        
        let verticalPadding = screenBounds.height * 0.2
        let horizontalPadding = screenBounds.width * 0.2
        let meter = PointsMeter.create(CGRect(x: 0.0, y: 0.0, width: screenBounds.width - horizontalPadding, height: screenBounds.height - verticalPadding), thickArc: true)
        meter.setLightArc()
        meter.setDarkText()
        
        meter.setActivities(activities)
        
        graphicContainerView.addSubview(meter)
        meter.translatesAutoresizingMaskIntoConstraints = false
        graphicContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-hPad-[meter]-hPad-|", options: NSLayoutFormatOptions(), metrics: ["hPad" : horizontalPadding/2], views: ["meter" : meter]))
        graphicContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-vPad-[meter]-vPad-|", options: NSLayoutFormatOptions(), metrics: ["vPad" : verticalPadding/2], views: ["meter" : meter]))
        graphicContainerView.setNeedsLayout()
        
        meter.drawArc(true)
    }
    
    func configureGauge(value: Double, displayValue: String?, displayUnit: String?, ranges: [MetricGauge.Range], valueName: String, valueColor: UIColor, checkin: HigiCheckin?) {
        
        let screenBounds = UIScreen.mainScreen().bounds
        var gaugeFrame = screenBounds
        gaugeFrame.size.width = (screenBounds.size.width/2) * 0.6
        gaugeFrame.size.height = gaugeFrame.width
        
        let gauge = MetricGauge.gauge(gaugeFrame, value: value, displayValue: displayValue, displayUnit: displayUnit, ranges: ranges, valueName: valueName, valueColor: valueColor, checkin: checkin)
        
        self.graphicContainerView.addSubview(gauge, pinToEdges: true)
        
        guard let checkin = checkin else { return }
        
        var title: String?
        var address1: String?
        var address2: String?
        if let device = checkin.sourceVendorId {
            title = device as String
        }
        if let kioskInfo = checkin.kioskInfo {
            title = kioskInfo.organizations.first as? String
            address1 = "\(kioskInfo.address1)"
            address2 = "\(kioskInfo.cityStateZip)"
        }
        gauge.checkinView.configure(title, address1: address1, address2: address2)
    }
}

// MARK: Configure Info Container

extension MetricDetailViewController {
    
    func configureInfoContainer(headerView: UIView?, imageNamed: String) {
        
        guard let image = UIImage(named: imageNamed) else { return }
        let aspectRatio = image.size.width/image.size.height
        
        let imageWidth = scrollableContentView.bounds.width
        let imageHeight = imageWidth/aspectRatio
        
        let verticalSpacing: CGFloat = 15.0
        let imageView = UIImageView(frame: CGRect(x: 0.0, y: verticalSpacing, width: imageWidth, height: imageHeight))
        imageView.contentMode = .ScaleAspectFill
        imageView.image = image
        
        if let headerView = headerView {
            scrollableContentView.addSubview(headerView)
            headerView.translatesAutoresizingMaskIntoConstraints = false
            scrollableContentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[headerView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["headerView" : headerView]))
            
            scrollableContentView.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            scrollableContentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[imageView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["imageView" : imageView]))
            
            scrollableContentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[headerView]-10-[imageView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["imageView" : imageView, "headerView" : headerView]))
        } else {
            scrollableContentView.addSubview(imageView, pinToEdges: true)
            
        }
        
        imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Height, relatedBy: .Equal, toItem: imageView, attribute: .Width, multiplier: 1/aspectRatio, constant: 0.0))
        
        scrollableContentView.setNeedsUpdateConstraints()
    }
}