//
//  MetricRecentSummaryViewController.swift
//  higi
//
//  Created by Remy Panicker on 9/20/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class MetricRecentSummaryViewController: UIViewController {
 
    private lazy var metricGraphCard: MetricsGraphCard = {
        let metricGraphCard: MetricsGraphCard
        if self.metric == Metric.watts {
            metricGraphCard = MetricsGraphCard.instanceFromNib(0, type: self.metric.metricsType)
        } else {
            metricGraphCard = MetricsGraphCard.instanceFromNib(nil, type: self.metric.metricsType)
        }
        metricGraphCard.addGestureRecognizer(self.tapGestureRecognizer)
        return metricGraphCard
    }()
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapGraphCard(_:)))
        return tap
    }()
    
    var delegate: MetricRecentSummaryDelegate?
    
    private let metricRecentSummaryController = MetricRecentSummaryController()
    
    // MARK: Injected
    
    private(set) var metric: Metric!
    
    private(set) var userController: UserController!
}

// MARK: - Dependency Injection

extension MetricRecentSummaryViewController {
 
    func configure(forMetric metric: Metric, userController: UserController, delegate: MetricRecentSummaryDelegate? = nil) {
        self.metric = metric
        self.userController = userController
        
        self.delegate = delegate
    }
}

// MARK: - View Lifecycle

extension MetricRecentSummaryViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
        configureView()
    }
}

extension MetricRecentSummaryViewController {
 
    private func configureView() {
        view.addSubview(metricGraphCard, pinToEdges: true)
    }
}

// MARK: - Data Retrieval

extension MetricRecentSummaryViewController {
    
    private func fetchData() {
        metricRecentSummaryController.fetch(activitiesForMetric: metric, forUser: userController.user, success: { [weak self] in
            self?.fetchSuccess()
            }, failure: { [weak self] (error: ErrorType) in
                self?.fetchFailure(error)
            })
    }
    
    private func fetchSuccess() {
        guard let activity = metricRecentSummaryController.activities.first else { return }
        
        let points = metricRecentSummaryController.points(forMetric: metric)
        let altPoints = metricRecentSummaryController.altPoints(forMetric: metric)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.metricGraphCard.update(withActivity: activity, forMetricType: self.metric.metricsType)
            self.metricGraphCard.graph(points, altPoints: altPoints, type: self.metric.metricsType)
        })
    }
    
    private func fetchFailure(error: ErrorType) {
        
    }
}

// MARK: - UI Action

extension MetricRecentSummaryViewController {
    
    dynamic private func didTapGraphCard(sender: UITapGestureRecognizer) {
        delegate?.didTap(metricRecentSummaryViewController: self)
    }
}

// MARK: - Metric Types

extension MetricRecentSummaryViewController {
    
    enum Metric {
        case watts
        case bloodPressure
        case pulse
        case weight
        
        /// Maps to enum used by legacy views.
        var metricsType: MetricsType {
            get {
                switch self {
                case .watts:
                    return MetricsType.watts
                case .bloodPressure:
                    return MetricsType.bloodPressure
                case .pulse:
                    return MetricsType.pulse
                case .weight:
                    return MetricsType.weight
                }
            }
        }
    }
}

// MARK: - Protocol

protocol MetricRecentSummaryDelegate: class {
    
    func didTap(metricRecentSummaryViewController metricRecentSummaryViewController: MetricRecentSummaryViewController)
}
