//
//  CheckinLocationView.swift
//  higi
//
//  Created by Remy Panicker on 2/2/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class CheckinLocationView: UIView {

    @IBOutlet var view: UIView!
    
    @IBOutlet private var nameLabel: UILabel! {
        didSet {
            nameLabel.text = ""
        }
    }
    
    @IBOutlet private var primaryAddressLabel: UILabel! {
        didSet {
            primaryAddressLabel.text = ""
        }
    }
    
    @IBOutlet private var secondaryAddressLabel: UILabel! {
        didSet {
            secondaryAddressLabel.text = ""
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
        self.view = NSBundle.mainBundle().loadNibNamed("CheckinLocationView", owner: self, options: nil).first as! UIView
        self.addSubview(self.view, pinToEdges: true)
    }
    
    func configure(name: String?, address1: String?, address2: String?) {
        nameLabel.text = name
        primaryAddressLabel.text = address1
        secondaryAddressLabel.text = address2
    }
}
