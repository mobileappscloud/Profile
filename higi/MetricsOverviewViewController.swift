//
//  MetricsOverviewViewController.swift
//  higi
//
//  Created by Remy Panicker on 9/8/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class MetricsOverviewViewController: UIViewController {
    
    lazy var metricsViewController: NewMetricsViewController = {
        let storyboard = UIStoryboard(name: "Metrics", bundle: nil)
        let metricsViewController = storyboard.instantiateInitialViewController() as! NewMetricsViewController
        metricsViewController.configure(withUserController: self.userController)
        return metricsViewController
    }()
    
    private var userController: UserController!
}

// MARK: - Dependency Injection

extension MetricsOverviewViewController {
    
    func configure(withUserController userController: UserController) {
        self.userController = userController
    }
}

// MARK: - View Lifecycle

extension MetricsOverviewViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("METRICS_OVERVIEW_VIEW_TITLE", comment: "Title for health metrics overview (primary view for metrics tab).")
    }
}

// MARK: - Segue

extension MetricsOverviewViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }

        guard let destinationViewController = segue.destinationViewController as? MetricRecentSummaryViewController else { return }
        let metric: MetricRecentSummaryViewController.Metric!
        if identifier == Storyboard.Segue.wattsEmbed {
            metric = .watts
        } else if identifier == Storyboard.Segue.bloodPressureEmbed {
            metric = .bloodPressure
        } else if identifier == Storyboard.Segue.pulseEmbed {
            metric = .pulse
        } else if identifier == Storyboard.Segue.weightEmbed {
            metric = .weight
        } else {
            fatalError("Encountered unrecognized segue identifier.")
        }
        destinationViewController.configure(forMetric: metric, userController: userController, delegate: self)
    }
}

// MARK: - Storyboard Ids

extension MetricsOverviewViewController {
 
    struct Storyboard {
        struct Segue {
            static let wattsEmbed = "wattsEmbedSegue"
            static let bloodPressureEmbed = "bloodPressureEmbedSegue"
            static let pulseEmbed = "pulseEmbedSegue"
            static let weightEmbed = "weightEmbedSegue"
        }
    }
}

// MARK: - Metric Recent Summary Delegate

extension MetricsOverviewViewController: MetricRecentSummaryDelegate {

    func didTap(metricRecentSummaryViewController metricRecentSummaryViewController: MetricRecentSummaryViewController) {
        dispatch_async(dispatch_get_main_queue(), {
            self.navigationController?.pushViewController(self.metricsViewController, animated: true)
        })
    }
}
