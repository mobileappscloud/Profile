//
//  UIImageView+Utility.swift
//  higi
//
//  Created by Remy Panicker on 4/7/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension UIImageView {
    
    /**
     Convenience method which cross dissolves an image into view.
     
     - parameter image:      The image to display.
     - parameter transition: Whether or not the image should transition into view.
     */
    func setImage(image: UIImage?, transition: Bool = false) {
        if !transition {
            self.image = image
            return
        }
        
        UIView.transitionWithView(self,
                                  duration:0.3,
                                  options: [.TransitionCrossDissolve, .AllowUserInteraction],
                                  animations: { self.image = image },
                                  completion: nil)
    }
}
