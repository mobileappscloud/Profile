//
//  MetricBlankStateViewController.swift
//  higi
//
//  Created by Remy Panicker on 1/18/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class MetricBlankStateViewController: UIViewController {
    
    @IBOutlet private var messageLabel: UILabel! {
        didSet {
            self.messageLabel.text = self.message
        }
    }
    
    @IBOutlet private var firstActionImageView: UIImageView!
    @IBOutlet private var firstActionButton: UIButton! {
        didSet {
            firstActionButton.layer.cornerRadius = 4.0
            firstActionButton.backgroundColor = Theme.Color.primary
            let title = NSLocalizedString("METRICS_CARD_VIEW_FIND_STATION_BUTTON_TITLE", comment: "Title to display on button to find a higi Station.")
            firstActionButton.setTitle(title, forState: .Normal)
        }
    }
    
    @IBOutlet private var secondActionImageView: UIImageView!
    @IBOutlet private var secondActionButton: UIButton! {
        didSet {
            secondActionButton.layer.cornerRadius = 4.0
            secondActionButton.backgroundColor = Theme.Color.primary
            let deviceButtonTitle: String
            if HealthKitManager.isHealthDataAvailable() {
                deviceButtonTitle = NSLocalizedString("METRICS_CARD_VIEW_CONNECT_DEVICE_BRANDED_BUTTON_TITLE", comment: "Title to display on button to connect a branded activity device.")
            } else {
                deviceButtonTitle = NSLocalizedString("METRICS_CARD_VIEW_CONNECT_DEVICE_BUTTON_TITLE", comment: "Title to display on button to connect a device.")
            }
            secondActionButton.setTitle(deviceButtonTitle, forState: .Normal)
        }
    }
    
    private var message: String?
    
    private var firstActionHandler: (() -> Void)?
    
    private var secondActionHandler: (() -> Void)?
    
    // MARK: -
    
    @IBAction private func didPressFirstActionButton() {
        firstActionHandler?()
    }
    
    @IBAction private func didPressSecondActionButton() {
        secondActionHandler?()
    }
    
    // MARK: -
    
    /**
     Configures the view with a custom message and custom functionality to be performed for UI Actions.
     
     - parameter message:             Message to describe why view is being displayed.
     - parameter firstActionHandler:  Block to execute when user performs first action
     - parameter secondActionHandler: Block to execute when user performs second action
     */
    func configure(message: String?, firstActionHandler: (() -> Void)?, secondActionHandler: (() -> Void)?) {
        self.message = message
        self.firstActionHandler = firstActionHandler
        self.secondActionHandler = secondActionHandler
    }
}
