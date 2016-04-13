//
//  UITableViewCell+Utility.swift
//  higi
//
//  Created by Remy Panicker on 4/6/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

// MARK: - Convenience methods
// [Type safety for stringly-typed](http://techblog.thescore.com/2016/04/04/typed-uitableview-uicollectionview-dequeuing-in-swift/ )

extension UITableViewCell {
    
    /**
     Provides a default identifier for a table view cell. Gaurantees to return a namespaced identifier.
     
     - returns: Default identifier for a table view cell
     */
    class func defaultIdentifier() -> String {
        return NSStringFromClass(self)
    }
}

extension UITableViewHeaderFooterView {
    
    /**
     Provides a default identifier for a table view header/footer view. Gaurantees to return a namespaced identifier.
     
     - returns: Default identifier for a table view header/footer view.
     */
    class func defaultIdentifier() -> String {
        return NSStringFromClass(self)
    }
}