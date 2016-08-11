//
//  TextInputView.swift
//  higi
//
//  Created by Remy Panicker on 8/1/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

@IBDesignable
final class TextInputView: ReusableXibView {
    
    @IBOutlet var textView: RGPAutoResizingTextView!
    
    @IBOutlet var rightButton: UIButton!
    var buttonHandler: ((sender: UIButton) -> Void)?
}

extension TextInputView {
    
    @objc @IBAction private func didTapRightButton(sender: UIButton) {
        buttonHandler?(sender: sender)
    }
}

// MARK: - Interface Builder

extension TextInputView {
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        textView.placeholder = "Enter text here..."
        textView.text = ""
    }
}