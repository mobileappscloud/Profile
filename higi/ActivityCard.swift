//
//  ActivityCard.swift
//  higi
//
//  Created by Dan Harms on 1/20/15.
//  Copyright (c) 2015 higi, LLC. All rights reserved.
//

import Foundation

class ActivityCard: UIView {
    
    @IBOutlet weak var meterContainer: UIView!
    @IBOutlet weak var attachDevicesButton: UIButton!
    @IBOutlet weak var blankStateImage: UIImageView!
    @IBOutlet weak var loadingContainer: UIView!
    var spinner: CustomLoadingSpinner!
}