//
//  ActivityTableViewCell.swift
//  higi
//
//  Created by Remy Panicker on 3/14/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class ActivityTableViewCell: UITableViewCell {
    
    static let cellReuseIdentifier = "ActivityTableViewCellReuseIdentifier"
    
    @IBOutlet var summaryView: ActivitySummaryView! {
        didSet {
            summaryView.delegate = self
        }
    }
    
    var meterButtonHandler: (() -> Void)?
}

extension ActivityTableViewCell: ActivitySummaryViewDelegate {
    
    func didTapMeterButton(activitySummaryView: ActivitySummaryView) {
        meterButtonHandler?()
    }
}
