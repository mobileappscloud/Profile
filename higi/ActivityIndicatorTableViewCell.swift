//
//  ActivityIndicatorTableViewCell.swift
//  higi
//
//  Created by Remy Panicker on 4/10/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class ActivityIndicatorTableViewCell: UITableViewCell {

    @IBOutlet private var activityIndicatorContainer: UIView! {
        didSet {
            activityIndicatorContainer.addSubview(activityIndicator)
            activityIndicator.startAnimating()
        }
    }

    private lazy var activityIndicator: CustomLoadingSpinner = {
        let spinner = CustomLoadingSpinner(frame: CGRectMake(0, 0, 32, 32))
        return spinner
    }()
}
