//
//  NewMetricDelegates.swift
//  higi
//
//  Created by Remy Panicker on 12/16/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import Foundation

protocol NewMetricDelegate: MetricGraphDelegate, MetricTableDelegate, MetricDetailPreviewDelegate, MetricDetailDisplayDelegate {
    
    var selectedIndex: Int { get set }
    
    func hasData() -> Bool
    
    var metricColor: UIColor { get }
}

// MARK: - Detail Preview 

protocol MetricDetailPreviewDelegate {
    
    func updateDetailPreview(detailPreview: MetricCheckinSummaryView)
}

extension MetricDetailPreviewDelegate {
    
    func updateDetailPreview(detailPreview: MetricCheckinSummaryView) {
        
    }
}

// MARK: - Detail

protocol MetricDetailDisplayDelegate {
    
    func configure(viewController: MetricDetailViewController)
}

// MARK: - Table

protocol MetricTableDelegate: MetricTableViewConfigurator, UITableViewDataSource {
    
    var tableDelegate: UITableViewDelegate? { get set }
    
    /** Object to coordinate table view delegatation with external objects.
    
    Example: When a table view cell is selected, this delegate should notify the plot so that it can also be updated to reflect changes in the table view.
    */
    var tableScrollDelegate: MetricTableScrollDelegate? { get set }
}

// MARK: Table Protocol Extensions

extension MetricTableDelegate {
    
    func tableViewScrollViewDidScroll(scrollView: UIScrollView, metricDelegate: NewMetricDelegate) {
        guard let tableView = scrollView as? UITableView else {
            return
        }
        self.tableScrollDelegate?.tableViewDidScroll(tableView, delegate: metricDelegate)
    }
}

extension MetricTableDelegate {
    
    func configureMetricTableViewCell(cell: MetricTableViewCell, indexPath: NSIndexPath, selected: Bool, timeInterval: NSTimeInterval, primaryMetricValue: String?, primaryMetricUnit: String?, secondaryMetricValue: String?, secondaryMetricUnit: String?) {
        
        let date = NSDate(timeIntervalSince1970: timeInterval)
        let dateString = Utility.mediumStyleDateFormatter.stringFromDate(date)
        
        cell.checkinSummaryView.configureDisplay(dateString, primaryMetricValue: primaryMetricValue, primaryMetricUnit: primaryMetricUnit, secondaryMetricValue: secondaryMetricValue, secondaryMetricUnit: secondaryMetricUnit, boldValueColor: nil)
        
        let color = UIColor(red: 67.0/255.0, green: 206.0/255.0, blue: 198.0/255.0, alpha: 0.3)
        let backgroundColor = selected ? color : UIColor.clearColor()
        cell.backgroundColor = backgroundColor
                
        cell.selectionStyle = .None
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
    }
}

protocol MetricTableScrollDelegate {
    
    func tableViewDidScroll(tableView: UITableView, delegate: NewMetricDelegate)
}

// MARK: - Graph

protocol MetricGraphDelegate {
    
    var plotSymbol: CPTPlotSymbol? { get set }
    var selectedPlotSymbol: CPTPlotSymbol? { get set }
    var selectedAltPlotSymbol: CPTPlotSymbol? { get set }
    var unselectedAltPlotSymbol: CPTPlotSymbol? { get set }
    
    var plotForwardDelegate: MetricPlotForwardDelegate? { get set }
    
    func graph(frame: CGRect) -> CPTXYGraph
}
