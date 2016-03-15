//
//  NewMetricTableDelegate.swift
//  higi
//
//  Created by Remy Panicker on 2/20/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class NewMetricTableDelegate: NSObject {
    
    var metricDelegate: NewMetricDelegate? = nil
}

extension NewMetricTableDelegate: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let metricDelegate = metricDelegate else { return }
        if metricDelegate.selectedIndex == indexPath.row { return }
        
        metricDelegate.selectedIndex = indexPath.row
        tableView.reloadData()
        
        metricDelegate.tableScrollDelegate?.tableViewDidScroll(tableView, delegate: metricDelegate)
    }
    
    
    /** @internal: Currently, Swift will not allow us to provide a default implementation for `UIScrollView` delegate methods. As a workaround, we can require that the scroll view delegate method be implemented. Within this method, we can have our protocols call our 'default implementation' from our protocol extension.
     */
    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard let metricDelegate = metricDelegate else { return }
        
        guard let tableView = scrollView as? UITableView else { return }
        guard let topCell = tableView.fullyVisibleCells().first else { return }
        guard let indexPath = tableView.indexPathForCell(topCell) else { return }
        if metricDelegate.selectedIndex == indexPath.row { return }
        
        metricDelegate.selectedIndex = indexPath.row
        tableView.reloadData()
        
        metricDelegate.tableViewScrollViewDidScroll(scrollView, metricDelegate: metricDelegate)
    }
}
