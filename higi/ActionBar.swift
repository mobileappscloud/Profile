//
//  ActionBar.swift
//  higi
//
//  Created by Remy Panicker on 6/27/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

@IBDesignable
final class ActionBar: ReusableXibView {
    
    @IBOutlet var stackViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet private var horizontalStackView: UIStackView! {
        didSet {
            self.removeAllButtons()
        }
    }
    
    private var buttonActionMap: [UIButton : Action] = [:]
    
    func buttonAction(forActionType type: Action.Types) -> (button: UIButton, action: Action)? {
        var targetButton: UIButton?
        var targetAction: Action?
        
        for button in buttonActionMap.keys {
            guard let action = buttonActionMap[button] else { continue }
            if action.type != type { continue }
            
            targetButton = button
            targetAction = action
            break
        }
        
        if let targetAction = targetAction,
            let targetButton = targetButton {
            return (targetButton, targetAction)
        } else {
            return nil
        }
    }
    
    weak var actionItemDelegate: ActionBarItemDelegate?
}

// MARK: Action

extension ActionBar {
    
    struct Action {
        
        enum Types {
            case Like
            case Unlike
            case Comment
            case Reply
            case Share
            case Likers
            case Commenters
        }
        
        let type: Types
        let title: String?
        let isBold: Bool
        let tintColor: UIColor
        
        var imageName: String?
    }
}

// MARK: - Configuration

extension ActionBar {
    
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
            
            if let imageName = action.imageName,
                let image = UIImage(named: imageName)?.imageWithRenderingMode(.AlwaysTemplate) {
                button.setImage(image, forState: .Normal)
                
                let imageWidth = image.size.width
                let margin: CGFloat = -10
                let inset: CGFloat = imageWidth + margin
                button.titleEdgeInsets.right = -inset
            }
            
            button.tintColor = action.tintColor
            button.setTitleColor(action.tintColor, forState: .Normal)
            
            button.setTitle(action.title, forState: .Normal)
            let size: CGFloat = 12.0
            button.titleLabel?.font = action.isBold ? UIFont.boldSystemFontOfSize(size) : UIFont.systemFontOfSize(size)
            
            button.addTarget(self, action: #selector(didTapButton), forControlEvents: .TouchUpInside)
            
            buttonActionMap[button] = action
            
            horizontalStackView.addArrangedSubview(button)
        }
    }
}

// MARK: - Button Handling

extension ActionBar {
    
    @objc private func didTapButton(sender: UIButton) {
        guard let action = buttonActionMap[sender] else { return }
        
        actionItemDelegate?.didTap(sender, forAction: action, inActionBar: self)
    }
}

// MARK: - Interface Builder Designable

extension ActionBar {
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        let highFive = Action(type: .Like, title: "High-Five", isBold: true, tintColor: Theme.Color.primary, imageName: nil)
        let reply = Action(type: .Comment, title: "Reply", isBold: false, tintColor: Theme.Color.primary, imageName: nil)
        let share = Action(type: .Share, title: "Share", isBold: false, tintColor: Theme.Color.primary, imageName: nil)
        
        let highFiveCount = Action(type: .Likers, title: "312", isBold: false, tintColor: Theme.Color.primary, imageName: "action-bar-high-five-icon")
        let commentCount = Action(type: .Commenters, title: "17", isBold: false, tintColor: Theme.Color.primary, imageName: "action-bar-comment-icon")
        
        self.configure([highFive, reply, share, highFiveCount, commentCount])
    }
}

// MARK: - Protocols

/// Protocol which signifies that a class displays an action bar as a subview.
protocol ActionBarDisplaying: class {
    
    var actionBar: ActionBar! { get set }
}

/// Protocol which designates a class for handling button taps for an action item within the action bar.
protocol ActionBarItemDelegate: class {

    func didTap(button: UIButton, forAction action: ActionBar.Action, inActionBar actionBar: ActionBar)
}

/// Protocol which ensures that a class has a property which conforms to `TableCellActionBarItemDelegate`. Typically a cell with an action bar would conform to this protocol.
protocol TableCellActionBarItemDelegating: class {
    
    weak var cellActionBarItemDelegate: TableCellActionBarItemDelegate? { get set }
}

/// Protocol which designates a class for handling button taps for an action item within an action bar placed in a table cell. This is a convenience protocol which forwards calls from `ActionBarItemDelegate` with additional information.
protocol TableCellActionBarItemDelegate: class {
    
    func didTap<T: UITableViewCell where T: ActionBarDisplaying>(button: UIButton, forAction action: ActionBar.Action, inActionBar actionBar: ActionBar, cell: T)
}

// Extension which forwards a button tap tap from button in an action bar to a table cell's delegate which conforms to `TableCellActionBarItemDelegate`.
extension ActionBarItemDelegate where Self: UITableViewCell, Self: ActionBarDisplaying, Self: TableCellActionBarItemDelegating {
    
    func didTap(button: UIButton, forAction action: ActionBar.Action, inActionBar actionBar: ActionBar) {
        cellActionBarItemDelegate?.didTap(button, forAction: action, inActionBar: actionBar, cell: self)
    }
}
