//
//  SegmentedPageViewController.swift
//  segment-page-view
//
//  Created by Remy Panicker on 6/6/16.
//  Copyright © 2016 higi SH llc. All rights reserved.
//

import UIKit

final class SegmentedPageViewController: UIViewController {

    @IBOutlet private var segmentedControlContainer: UIView!
    @IBOutlet private(set) var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.backgroundColor = Theme.Color.Primary.white
            segmentedControl.tintColor = Theme.Color.Primary.pewter
            
            segmentedControl.selectedSegmentIndex = self.dynamicType.SegmentedControlNoSelection
            segmentedControl.removeAllSegments()
    
            segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), forControlEvents:.ValueChanged)
        }
    }
    private static let segmentedControlHorizontalMarginDefault: CGFloat = 20.0
    
    /// Value to use for the segmented control leading and trailing constraint constant. Refer to `segmentedControlHorizontalMarginDefault` for the default leading/trailing constraint constant.
    var segmentedControlHorizontalMargin: CGFloat = segmentedControlHorizontalMarginDefault {
        didSet {
            segmentedControlLeadingConstraint.constant = segmentedControlHorizontalMargin
            segmentedControlTrailingConstraint.constant = segmentedControlHorizontalMargin
        }
    }
    
    @IBOutlet private var segmentedControlLeadingConstraint: NSLayoutConstraint! {
        didSet {
            if segmentedControlHorizontalMargin != self.dynamicType.segmentedControlHorizontalMarginDefault {
                segmentedControlLeadingConstraint.constant = segmentedControlHorizontalMargin
            }
        }
    }
    @IBOutlet private var segmentedControlTrailingConstraint: NSLayoutConstraint! {
        didSet {
            if segmentedControlHorizontalMargin != self.dynamicType.segmentedControlHorizontalMarginDefault {
                segmentedControlTrailingConstraint.constant = segmentedControlHorizontalMargin
            }
        }
    }
    
    private static let SegmentedControlNoSelection = -1
    
    @IBOutlet private var childViewContainer: UIView!
    
    private(set) var viewControllers: [UIViewController] = []
    private(set) var titles: [String] = []
    
    var selectedIndex: Int = SegmentedControlNoSelection
    
    var selectedViewController: UIViewController? {
        get {
            return viewControllers.indices.contains(selectedIndex) ? viewControllers[selectedIndex] : nil
        }
    }
    
    weak var delegate: SegmentedPageViewControllerDelegate?
}

// MARK: - View Lifecycle

extension SegmentedPageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
}

// MARK: - Configuration

extension SegmentedPageViewController {
    
    func set(viewControllers: [UIViewController], titles: [String], selectedIndex: Int = 0) {
        if viewControllers.count != titles.count {
            fatalError("View controller array is not the same size as title array.")
        }
        
        self.viewControllers = viewControllers
        self.titles = titles
        self.selectedIndex = selectedIndex
        
        configure()
    }
    
    private func configure() {
        if segmentedControl == nil { return }
        if childViewContainer == nil { return }
        
        configureSegmentedControl()
        configureChildViewControllers()
        update(self.dynamicType.SegmentedControlNoSelection, toIndex: selectedIndex)
    }
    
    private func configureSegmentedControl() {
        segmentedControl.removeAllSegments()
        for index in 0..<titles.count {
            let title = titles[index]
            segmentedControl.insertSegmentWithTitle(title, atIndex: index, animated: false)
        }
        if segmentedControl.selectedSegmentIndex != selectedIndex {
            segmentedControl.selectedSegmentIndex = selectedIndex
        }
    }
    
    private func configureChildViewControllers() {
        for childViewController in childViewControllers {
            childViewController.removeFromParentViewController()
        }
        
        // Uncomment this section to instantiate all view controllers for responsiveness
        /**
        for viewController in viewControllers {
            addChildViewController(viewController)
            addSubview(viewController.view, pinToEdges: true)
            childViewContainer.sendSubviewToBack(viewController.view)
            viewController.didMoveToParentViewController(self)
            
            // Removes child view controllers and their subviews, but keeps them in memory
            viewController.willMoveToParentViewController(nil)
            viewController.removeFromParentViewController()
            viewController.didMoveToParentViewController(nil)
        }
        */
    }
    
    private func addSubview(subview: UIView, pinToEdges: Bool) {
        let view = childViewContainer
        
        view.addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[subview]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview" : subview]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[subview]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview" : subview]))
    }
}

// MARK: - UI Action

extension SegmentedPageViewController {
    
    @objc private func segmentedControlValueChanged(sender: UISegmentedControl) {
        update(selectedIndex, toIndex: sender.selectedSegmentIndex)
    }
    
    private func update(fromIndex: Int, toIndex: Int) {
        if toIndex == self.dynamicType.SegmentedControlNoSelection { return }
        
        selectedIndex = toIndex
        
        var previousViewController: UIViewController?
        if viewControllers.indices.contains(fromIndex) {
            previousViewController = viewControllers[fromIndex]
        }
        
        let selectedViewController = viewControllers[toIndex]
        
        if let previousViewController = previousViewController {
            previousViewController.willMoveToParentViewController(nil)
            self.view.willRemoveSubview(previousViewController.view)
            previousViewController.removeFromParentViewController()
            previousViewController.view.removeFromSuperview()
            previousViewController.didMoveToParentViewController(nil)
        }
        
        self.addChildViewController(selectedViewController)
        addSubview(selectedViewController.view, pinToEdges: true)
        selectedViewController.didMoveToParentViewController(self)
        
        delegate?.segmentedPageViewControllerDidChange(self, selectedSegmentIndex: toIndex, visibleViewController: selectedViewController)
    }
}

// MARK - Protocol

protocol SegmentedPageViewControllerDelegate: class {
    
    func segmentedPageViewControllerDidChange(segmentedPageViewController: SegmentedPageViewController, selectedSegmentIndex: Int, visibleViewController: UIViewController)
}
