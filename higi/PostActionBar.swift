//
//  PostActionBar.swift
//  higi
//
//  Created by Remy Panicker on 6/27/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

@IBDesignable
final class PostActionBar: UIView {
    
    struct Action {
        let title: String
        var handler: ((sender: UIButton) -> Void)?
    }
    
    /// View necessary for xib reuse
    @IBOutlet private var view: UIView!
    
    @IBOutlet private var horizontalStackView: UIStackView! {
        didSet {
            self.removeAllButtons()
        }
    }
    
    private var buttonActionMap: [UIButton : Action] = [:]

    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    private func commonInit() {
        let bundle = NSBundle(forClass: self.dynamicType)
        self.view = bundle.loadNibNamed("PostActionBar", owner: self, options: nil).first as! UIView
        self.addSubview(self.view, pinToEdges: true)
    }
}

// MARK: - Configuration

extension PostActionBar {
    
    private func removeAllButtons() {
        for subview in horizontalStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
    }
    
    func configure(actions: [Action]) {
        removeAllButtons()
        
        for action in actions {
            let button = UIButton(type: .System)
            
            let attributes = [
                NSForegroundColorAttributeName : Theme.Color.primary,
                NSFontAttributeName : UIFont.systemFontOfSize(14.0)
            ]
            let attributedTitle = NSAttributedString(string: action.title, attributes: attributes)
            button.setAttributedTitle(attributedTitle, forState: .Normal)
            
            buttonActionMap[button] = action
            
            horizontalStackView.addArrangedSubview(button)
        }
    }
}

// MARK: - Button Handling

extension PostActionBar {
    
    @objc private func didTapButton(sender: UIButton) {
        guard let action = buttonActionMap[sender],
            let handler = action.handler else { return }
        
        handler(sender: sender)
    }
}

// MARK: - Interface Builder Designable

extension PostActionBar {
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        let highFive = Action(title: "High-Five", handler: nil)
        let reply = Action(title: "Reply", handler: nil)
        let share = Action(title: "Share", handler: nil)
        
        self.configure([highFive, reply, share])
    }
}
