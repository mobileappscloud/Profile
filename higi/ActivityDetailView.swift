//
//  ActivityDetailView.swift
//  higi
//
//  Created by Remy Panicker on 2/8/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class ActivityDetailView: UIView {

    @IBOutlet private var view: UIView!
    
    @IBOutlet private var activityLabel: UILabel! {
        didSet {
            activityLabel.text = ""
        }
    }
    @IBOutlet private var valueLabel: UILabel! {
        didSet {
            valueLabel.text = ""
        }
    }
    @IBOutlet private var unitLabel: UILabel! {
        didSet {
            unitLabel.text = ""
        }
    }
    
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
        self.view = NSBundle.mainBundle().loadNibNamed("ActivityDetailView", owner: self, options: nil).first as! UIView
        self.addSubview(self.view, pinToEdges: true)
    }
    
    // MARK: - Config
    
    /**
    Configure view for display.
    
    - parameter activity:        Activity title string.
    - parameter value:           Point value for the activity.
    - parameter unit:            Unit label for the point value.
    - parameter shouldEmphasize: Whether the labels should be displayed with emphasis.
    - parameter emphasisColor:   Color to apply to emphasized labels.
    */
    func configure(activity: String?, value: String?, unit: String?, emphasizeActivityAndValue shouldEmphasize: Bool, emphasisColor: UIColor?) {
        activityLabel.text = activity
        valueLabel.text = value
        unitLabel.text = unit
        
        if shouldEmphasize {
            activityLabel.font = UIFont.boldSystemFontOfSize(activityLabel.font.pointSize + 2.0)
            activityLabel.textColor = emphasisColor
            valueLabel.font = UIFont.boldSystemFontOfSize(valueLabel.font.pointSize + 2.0)
            valueLabel.textColor = emphasisColor
            setNeedsLayout()
        }
    }
}
