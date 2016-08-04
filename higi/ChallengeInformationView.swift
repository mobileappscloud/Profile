//
//  ChallengeInformationView.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 7/28/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

@IBDesignable
final class ChallengeInformationView: ReusableXibView {    
    @IBOutlet var upperLabel: UILabel!
    @IBOutlet var lowerLabel: UILabel!
    
    @IBOutlet var goalProgressView: ChallengeProgressView!
    
    @IBOutlet var rightImageContainer: UIView!
    @IBOutlet var rightImageView: UIImageView!
}
