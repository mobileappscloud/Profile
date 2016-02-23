//
//  MetricPlotViewController.swift
//  higi
//
//  Created by Remy Panicker on 12/3/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import UIKit

final class MetricPlotViewController: UIViewController {
    
    var delegate: NewMetricDelegate?
    
    @IBOutlet private var graphContainer: UIView!
    var graphHostingView: CPTGraphHostingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let delegate = self.delegate {
            let graphHostView = CPTGraphHostingView(frame: self.graphContainer.bounds)
            let graph = delegate.graph(self.graphContainer.bounds)
            graphHostView.hostedGraph = graph
            
            graphContainer.addSubview(graphHostView, pinToEdges: true)
            
            graphHostView.allowPinchScaling = true
            
            self.graphHostingView = graphHostView
        }
    }
}
