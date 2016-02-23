//
//  MetricDetailPreviewViewController.swift
//  higi
//
//  Created by Remy Panicker on 2/2/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class MetricDetailPreviewViewController: UIViewController {

    @IBOutlet var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var headerView: MetricCheckinSummaryView!
}

protocol MetricDetailPreviewDisplay {
    
    func highlightedColor() -> UIColor
    
    func configure(dateString: String, primaryMetricValue: String, primaryMetricUnit: String, secondaryMetricValue: String?, secondaryMetricUnit: String?)
}