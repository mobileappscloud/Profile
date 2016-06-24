//
//  TextNotificationCoordinator.swift
//  higi
//
//  Created by Remy Panicker on 6/21/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

/// Convenience object to coordinate presentation/dismissal of a text notification on a source view.
final class TextNotificationCoordinator: NSObject {
    
    weak var sourceView: UIView?
    
    lazy var textViewController: TextViewController = {
        let storyboard = UIStoryboard(name: "Text", bundle: nil)
        let textViewController = storyboard.instantiateInitialViewController() as! TextViewController
        textViewController.view.alpha = 0.9
        textViewController.configure(nil, textColor: Theme.Color.Primary.whiteGray, backgroundColor: Theme.Color.Primary.charcoal)
        textViewController.label.textAlignment = .Center
        return textViewController
    }()
    
    private var textViewTopConstraint: NSLayoutConstraint?
    
    private var autoDismiss = true
    private var autoDismissDelay: NSTimeInterval = defaultAutoDismissDelay
    
    private static let defaultAutoDismissDelay: NSTimeInterval = 2.5
    private static let defaultAnimationDuration: NSTimeInterval = 0.3
    
    func showNotification(autoDismiss: Bool = true, autoDismissDelay: NSTimeInterval = defaultAutoDismissDelay) {
        guard let sourceView = sourceView else { return }
        
        self.autoDismiss = autoDismiss
        self.autoDismissDelay = autoDismissDelay
        
        let notificationView = textViewController.view
        sourceView.addSubview(notificationView)
        
        notificationView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = NSLayoutConstraint(item: notificationView, attribute: .Top, relatedBy: .Equal, toItem: sourceView, attribute: .Top, multiplier: 1.0, constant: -CGRectGetHeight(notificationView.bounds))
        sourceView.addConstraint(topConstraint)
        textViewTopConstraint = topConstraint
        
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[notificationView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["notificationView" : notificationView])
        sourceView.addConstraints(horizontalConstraints)
        
        sourceView.layoutIfNeeded()
        self.textViewTopConstraint?.constant = 0.0
        UIView.animateWithDuration(self.dynamicType.defaultAnimationDuration, animations: {
            sourceView.layoutIfNeeded()
        })
        
        if self.autoDismiss {
            Utility.delay(self.autoDismissDelay, closure: {
                sourceView.layoutIfNeeded()
                self.textViewTopConstraint?.constant = -CGRectGetHeight(notificationView.bounds)
                UIView.animateWithDuration(self.dynamicType.defaultAnimationDuration, animations: {
                    sourceView.layoutIfNeeded()
                    }, completion: { (completed) in
                        var constraints = [topConstraint]
                        constraints.appendContentsOf(horizontalConstraints)
                        notificationView.removeConstraints(constraints)
                        notificationView.removeFromSuperview()
                })
            })
        }
    }
}
