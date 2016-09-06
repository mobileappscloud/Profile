//
//  UIView+Utility.swift
//  higi
//
//  Created by Remy Panicker on 4/7/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension UIView {
    
    func addSubview(subview: UIView, pinToEdges: Bool) {
        self.addSubview(subview)
        guard pinToEdges else { return }
        subview.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[subview]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview" : subview]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[subview]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview" : subview]))
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
}
