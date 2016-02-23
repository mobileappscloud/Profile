//
//  MetricCheckinSummaryView.swift
//  higi
//
//  Created by Remy Panicker on 2/1/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class MetricCheckinSummaryView: UIView {

    @IBOutlet private var view: UIView!
    
    @IBOutlet private var dateLabel: UILabel! {
        didSet {
            dateLabel.text = ""
        }
    }
    @IBOutlet private var secondaryMetricDataLabelView: MetricDataLabelView!
    @IBOutlet private var primaryMetricDataLabelView: MetricDataLabelView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    private func commonInit() {
        self.view = NSBundle.mainBundle().loadNibNamed("MetricCheckinSummaryView", owner: self, options: nil).first as! UIView
        self.addSubview(self.view, pinToEdges: true)
    }
    
    func configureDisplay(date: String?, primaryMetricValue: String?, primaryMetricUnit: String?, secondaryMetricValue: String?, secondaryMetricUnit: String?, boldValueColor: UIColor?) {
        
        dateLabel.text = date
        
        primaryMetricDataLabelView.textLabel.text = primaryMetricValue
        primaryMetricDataLabelView.detailTextLabel.text = primaryMetricUnit
        
        secondaryMetricDataLabelView.textLabel.text = secondaryMetricValue
        secondaryMetricDataLabelView.detailTextLabel.text = secondaryMetricUnit
        
        if let boldValueColor = boldValueColor {
            let labels = [dateLabel, primaryMetricDataLabelView.textLabel, secondaryMetricDataLabelView.textLabel]
            
            for label in labels {
                label.font = UIFont.boldSystemFontOfSize(label.font.pointSize)
                label.textColor = boldValueColor
            }
        }
    }
}
