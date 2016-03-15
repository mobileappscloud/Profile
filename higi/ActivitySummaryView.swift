//
//  ActivitySummaryView.swift
//  higi
//
//  Created by Remy Panicker on 3/14/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class ActivitySummaryView: UIView {

    @IBOutlet private var view: UIView!
    
    @IBOutlet private var dateLabel: UILabel! {
        didSet {
            dateLabel.text = ""
        }
    }
    
    @IBOutlet private var meterContainerView: UIView! 
    
    @IBOutlet private var dataLabelView: MetricDataLabelView!
    
    lazy private var pointsMeter: PointsMeter = {
        let rect = self.meterContainerView.bounds
        let pointsMeter = PointsMeter.create(rect, thickArc: true)
        pointsMeter.userInteractionEnabled = false
        self.meterContainerView.addSubview(pointsMeter)
        return pointsMeter
    }()
    
    var delegate: ActivitySummaryViewDelegate?
    
    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    private func commonInit() {
        self.view = NSBundle.mainBundle().loadNibNamed("ActivitySummaryView", owner: self, options: nil).first as! UIView
        self.addSubview(self.view, pinToEdges: true)
    }
}

// MARK: - UI Action

extension ActivitySummaryView {
    
    @IBAction func didTapMeterButton(sender: UIButton) {
        delegate?.didTapMeterButton(self)
    }
}

// MARK: - Config

extension ActivitySummaryView {

    func config(dateString: String, activitySummary: HigiActivitySummary, unit: String?) {
        dateLabel.text = dateString
        
        pointsMeter.setActivities(activitySummary)
        pointsMeter.points.hidden = true
        
        dataLabelView.textLabel.text = pointsMeter.points.text
        dataLabelView.detailTextLabel.text = unit
        dataLabelView.setNeedsLayout()
        
        Utility.delay(0.1, closure: {
            self.pointsMeter.drawArc(true)
        })
        meterContainerView.setNeedsLayout()
    }
}

// MARK: - Protocol

protocol ActivitySummaryViewDelegate {
    
    func didTapMeterButton(activitySummaryView: ActivitySummaryView)
}
