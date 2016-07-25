//
//  ReusableXibView.swift
//  higi
//
//  Created by Remy Panicker on 7/25/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

/// Create a subclass of this class to create a reusable xib.

/// **Warning:** The subclass must have the same name as the xib.
class ReusableXibView: UIView {
    
    /// View necessary for xib reuse
    @IBOutlet private var view: UIView!
    
    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    /**
     This method contains core functionality which ensures view is properly added. If this method is overridden, `super` must be called.
     */
    func commonInit() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let className = NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!
        let unarchivedContents = bundle.loadNibNamed(className, owner: self, options: nil)
        
        if let customView = unarchivedContents.first as? UIView {
            view = customView
            addSubview(view, pinToEdges: true)
        }
    }
}
