//
//  PostContentTapGestureRecognizerDelegate.swift
//  higi
//
//  Created by Remy Panicker on 7/7/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class PostContentTapGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        guard let view = touch.view,
            let label = view as? TTTAttributedLabel
            else {
                return true
        }
        
        if let link = label.linkAtPoint(touch.locationInView(label)), let result = link.result {
            if result.numberOfRanges > 0 {
                return false
            }
        }
        
        return true
    }
}
