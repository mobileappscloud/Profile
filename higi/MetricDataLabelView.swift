//
//  MetricDataLabelView.swift
//  higi
//
//  Created by Remy Panicker on 12/9/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import UIKit

final class MetricDataLabelView: UIView {

    @IBOutlet var view: UIView!
    
    @IBOutlet var textLabel: UILabel! {
        didSet {
            textLabel.text = ""
        }
    }
    @IBOutlet var detailTextLabel: UILabel! {
        didSet {
            detailTextLabel.text = ""
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()        
    }
    
    private func commonInit() {
        self.view = NSBundle.mainBundle().loadNibNamed("MetricDataLabelView", owner: self, options: nil).first as! UIView
        self.addSubview(self.view, pinToEdges: true)
    }
}
