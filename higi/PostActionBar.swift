//
//  PostActionBar.swift
//  higi
//
//  Created by Remy Panicker on 6/27/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

@IBDesignable
final class PostActionBar: ReusableXibView {
    
    struct Action {
        
        enum Type {
            case HighFive
            case Comment
            case Share
            case HighFivers
            case Commenters
        }
        
        let type: Type
        let title: String
        var imageName: String?
        
        var handler: ((sender: UIButton, action: Action) -> Void)?
    }
    
    @IBOutlet var stackViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet private var horizontalStackView: UIStackView! {
        didSet {
            self.removeAllButtons()
        }
    }
    
    private var buttonActionMap: [UIButton : Action] = [:]
}

// MARK: - Configuration

extension PostActionBar {
    
    private func removeAllButtons() {
        for subview in horizontalStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
        buttonActionMap = [:]
    }
    
    func configure(actions: [Action]) {
        removeAllButtons()
        
        for action in actions {
            let button = UIButton(type: .Custom)
            
            var buttonColor: UIColor = Theme.Color.primary
            
            if let imageName = action.imageName {
                if let image = UIImage(named: imageName)?.imageWithRenderingMode(.AlwaysTemplate) {
                    button.setImage(image, forState: .Normal)
                    
                    let imageWidth = image.size.width
                    let margin: CGFloat = -10
                    let inset: CGFloat = imageWidth + margin
                    button.titleEdgeInsets.right = -inset
                    
                    buttonColor = Theme.Color.Primary.pewter
                }
            }
            
            button.tintColor = buttonColor
            button.setTitleColor(buttonColor, forState: .Normal)
            
            button.setTitle(action.title, forState: .Normal)
            button.titleLabel?.font = UIFont.systemFontOfSize(13.0)
            
            button.addTarget(self, action: #selector(didTapButton), forControlEvents: .TouchUpInside)
            
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
        
        handler(sender: sender, action: action)
    }
}

// MARK: - Interface Builder Designable

extension PostActionBar {
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        let highFive = Action(type: .HighFive, title: "High-Five", imageName: nil, handler: nil)
        let reply = Action(type: .Comment, title: "Reply", imageName: nil, handler: nil)
        let share = Action(type: .Share, title: "Share", imageName: nil, handler: nil)
        
        let highFiveCount = Action(type: .HighFivers, title: "312", imageName: "action-bar-high-five-icon", handler: nil)
        let commentCount = Action(type: .HighFivers, title: "17", imageName: "action-bar-comment-icon", handler: nil)
        
        self.configure([highFive, reply, share, highFiveCount, commentCount])
    }
}
