//
//  UITableView+Utility.swift
//  higi
//
//  Created by Remy Panicker on 4/6/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension UITableView {
    /**
     Gets a collection of all table view cell's which are completely visible without obstruction.
     
     - returns: Array of table view cells which are completely visible without obstruction.
     */
    func fullyVisibleCells() -> [UITableViewCell] {
        var fullyVisibleCells: [UITableViewCell] = self.visibleCells
        if !fullyVisibleCells.isEmpty && !self.isFullyVisible(fullyVisibleCells.first) {
            fullyVisibleCells.removeFirst()
        }
        if !fullyVisibleCells.isEmpty && !self.isFullyVisible(fullyVisibleCells.last) {
            fullyVisibleCells.removeLast()
        }
        return fullyVisibleCells
    }
    
    /**
     Determines if a table view cell is fully visible within a table view's bounds. Said another way, this method determines if a cell's frame is fully contained within a table view's bounds.
     
     **Note:** This method does not take external factors into account when determining cell visisbility. This method does not gaurantee that the cell is visible on screen. For example, if a subview is covering the table view or if the table view is hidden, the cell may not be visible.
     
     - parameter cell: Table view cell to evaluate.
     
     - returns: `true` if the cell's frame is contained completely within the table view's bounds.
     */
    func isFullyVisible(cell: UITableViewCell?) -> Bool {
        guard let cell = cell else { return false }
        guard let superview = self.superview else { return false }
        guard let indexPath = self.indexPathForCell(cell) else { return false }
        
        let cellRect = self.rectForRowAtIndexPath(indexPath)
        let convertedCellRect = self.convertRect(cellRect, toView: superview)
        return CGRectContainsRect(self.frame, convertedCellRect)
    }
}

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
     Convenience extension which registers a nib for use in creating new table cells.
     
     Please refer to documentation for `registerNib:forCellReuseIdentifier:` to determine dequeuing, registration/unregistration specifics.
     
     - parameter nib: The nib of a cell that you want to use in the table.
     - parameter class: The class of a cell that you want to use in the table.
     */
    func register<T: UITableViewCell>(nib: UINib, forClass `class`: T.Type) {
        registerNib(nib, forCellReuseIdentifier: `class`.defaultIdentifier())
    }
    
    /**
     Convenience extension which registers a nib for use in creating new table cells.
     
     Please refer to documentation for `registerNib:forCellReuseIdentifier:` to determine dequeuing, registration/unregistration specifics.
     
     - parameter class: The class of a cell that you want to use in the table.
     - parameter bundle: The bundle in which to search for the nib file. Default value is `nil` which searches for the file in the main bundle.
     
     **NOTE: The name of the cell class must match the name of the xib file.**
     */
    func register<T: UITableViewCell>(nibWithCellClass `class`: T.Type, bundle: NSBundle? = nil) {
        let className = String(`class`.self)
        let nib = UINib(nibName: className, bundle: bundle)
        register(nib, forClass: `class`)
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
     Convenience extension which registers a nib for use in creating new table header/footer views.
     
     Please refer to documentation for `registerNib:forHeaderFooterViewReuseIdentifier:` to determine dequeuing, registration/unregistration specifics.
     
     - parameter nib: The nib of a table header/footer view that you want to use in the table.
     - parameter class: The class of a table header/footer view that you want to use in the table.
     */
    func register<T: UITableViewHeaderFooterView>(nib: UINib, forHeaderFooterClass `class`: T.Type) {
        registerNib(nib, forHeaderFooterViewReuseIdentifier: `class`.defaultIdentifier())
    }
    
    /**
     Convenience extension which registers a nib for use in creating new table header/footer views.
     
     Please refer to documentation for `registerNib:forHeaderFooterViewReuseIdentifier:` to determine dequeuing, registration/unregistration specifics.
     
     - parameter class: The class of a table header/footer view that you want to use in the table.
     - parameter bundle: The bundle in which to search for the nib file. Default value is `nil` which searches for the file in the main bundle.
     
     **NOTE: The name of the cell class must match the name of the xib file.**
     */
    func register<T: UITableViewHeaderFooterView>(nibWithHeaderFooterClass `class`: T.Type, bundle: NSBundle? = nil) {
        let className = String(`class`.self)
        let nib = UINib(nibName: className, bundle: bundle)
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
