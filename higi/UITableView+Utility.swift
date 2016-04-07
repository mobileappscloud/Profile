//
//  UITableView+Utility.swift
//  higi
//
//  Created by Remy Panicker on 4/6/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

// MARK: - Convenience methods
// [Type safety for stringly-typed](http://techblog.thescore.com/2016/04/04/typed-uitableview-uicollectionview-dequeuing-in-swift/)

// Cells
extension UITableView {
    
    /**
     Convenience extension which registers a class for use in creating new table cells.
     
     Please refer to documentation for `registerClass:forCellReuseIdentifier:` to determine dequeuing, registration/unregistration specifics.
     
     - parameter class: The class of a cell that you want to use in the table.
     */
    func register<T: UITableViewCell>(cellClass `class`: T.Type) {
        registerClass(`class`, forCellReuseIdentifier: `class`.defaultIdentifier())
    }
    
    /**
     Convenience extension which registers a class for use in creating new table cells.
     
     Please refer to documentation for `registerNib:forCellReuseIdentifier:` to determine dequeuing, registration/unregistration specifics.
     
     - parameter nib: The nib of a cell that you want to use in the table.
     - parameter class: The class of a cell that you want to use in the table.
     */
    func register<T: UITableViewCell>(nib: UINib, forClass `class`: T.Type) {
        registerNib(nib, forCellReuseIdentifier: `class`.defaultIdentifier())
    }
}

// Header / Footer
extension UITableView {
    
    /**
     Convenience extension which registers a class for use in creating new table header/footer views.
     
     Please refer to documentation for `registerClass:forHeaderFooterViewReuseIdentifier:` to determine dequeuing, registration/unregistration specifics.
     
     - parameter class: The class of a table header/footer view that you want to use in the table.
     */
    func register<T: UITableViewHeaderFooterView>(headerFooterClass `class`: T.Type) {
        registerClass(`class`, forHeaderFooterViewReuseIdentifier: `class`.defaultIdentifier())
    }
    
    /**
     Convenience extension which registers a class for use in creating new table header/footer views.
     
     Please refer to documentation for `registerClass:forHeaderFooterViewReuseIdentifier:` to determine dequeuing, registration/unregistration specifics.
     
     - parameter nib: The nib of a table header/footer view that you want to use in the table.
     - parameter class: The class of a table header/footer view that you want to use in the table.
     */
    func register<T: UITableViewHeaderFooterView>(nib: UINib, forHeaderFooterClass `class`: T.Type) {
        registerNib(nib, forHeaderFooterViewReuseIdentifier: `class`.defaultIdentifier())
    }
}

// Dequeuing
extension UITableView {
    
    /**
     Returns a reusable table-view cell object for the specified class and adds it to the table.
     A `UITableViewCell` object with the associated class. This method always returns a valid cell.
     
     - parameter class: The class of a cell that you want to use in the table.
     
     - returns: A `UITableViewCell` object with the associated class; uses the cell's default identifier as the reuse identifier.
     */
    func dequeueReusableCell<T: UITableViewCell>(withClass `class`: T.Type) -> T? {
        return dequeueReusableCellWithIdentifier(`class`.defaultIdentifier()) as? T
    }
    
    /**
     Returns a reusable table-view cell object for the specified class and adds it to the table.
     A `UITableViewCell` object with the associated class. This method always returns a valid cell.
     
     - parameter class: The class of a cell that you want to use in the table.
     - parameter indexPath: The index path specifying the location of the cell.
     
     - returns: A `UITableViewCell` object with the associated class; uses the cell's default identifier as the reuse identifier.
     */
    func dequeueReusableCell<T: UITableViewCell>(withClass `class`: T.Type, forIndexPath indexPath: NSIndexPath) -> T {
        guard let cell = dequeueReusableCellWithIdentifier(`class`.defaultIdentifier(), forIndexPath: indexPath) as? T else {
            fatalError("Error: cell with identifier: \(`class`.defaultIdentifier()) for index path: \(indexPath) is not \(T.self)")
        }
        return cell
    }
    
    /**
     Returns a reusable table-view header/footer object for the specified class and adds it to the table.
     A `UITableViewHeaderFooterView` object with the associated class. This method always returns a valid header/footer view.
     
     - parameter class: The class of a header/footer view that you want to use in the table.
     
     - returns: A `UITableViewHeaderFooterView` object with the associated class; uses the view's default identifier as the reuse identifier.
     */
    func dequeueResuableHeaderFooterView<T: UITableViewHeaderFooterView>(withClass `class`: T.Type) -> T? {
        return dequeueReusableHeaderFooterViewWithIdentifier(`class`.defaultIdentifier()) as? T
    }
}
