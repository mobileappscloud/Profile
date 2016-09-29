//
//  MetricPlotViewController.swift
//  higi
//
//  Created by Remy Panicker on 12/3/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import UIKit

final class MetricPlotViewController: UIViewController {
    
    @IBOutlet private var graphContainer: UIView!
    
    private(set) var graphHostingView: CPTGraphHostingView!
    
    var delegate: NewMetricDelegate?
}

// MARK: - View Lifecycle

extension MetricPlotViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGraphContainer()
    }
}

// MARK: - View Configuration

private extension MetricPlotViewController {
    
    func configureGraphContainer() {
        guard let delegate = delegate else { return }
        
        let graphHostView = CPTGraphHostingView(frame: self.graphContainer.bounds)
        let graph = delegate.graph(self.graphContainer.bounds)
        graphHostView.hostedGraph = graph
        
        graphContainer.addSubview(graphHostView, pinToEdges: true)
        
        graphHostView.allowPinchScaling = true
        
        self.graphHostingView = graphHostView
    }
}

// MARK: - Hotfix: Graph Reload
// This is a quick hack around an existing issue where the graph would not render plot points after calling -reloadData if the graph did not initially have plot points.

extension MetricPlotViewController {
    
    func resetGraph() {
        self.graphHostingView.removeFromSuperview()
        configureGraphContainer()
    }
}
