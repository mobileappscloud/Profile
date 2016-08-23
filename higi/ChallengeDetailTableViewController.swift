//
//  ChallengeDetailTableViewController.swift
//  higi
//
//  Created by Remy Panicker on 8/20/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class ChallengeDetailTableViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.estimatedRowHeight = 120.0
            tableView.rowHeight = UITableViewAutomaticDimension
            
            tableView.tableFooterView = UIView()
            
            tableView.register(cellClass: UITableViewCell.self)
            tableView.register(nibWithCellClass: ChallengeInfoTableViewCell.self)
        }
    }
    
    // MARK: Dependencies
    
    /// Controller for current authenticated user.
    private(set) var userController: UserController!
    
    /// Controller for challenge details.
    private(set) var challengeDetailController: ChallengeDetailController!
    
    /// View controller to target for presentation of views. This property should be set when this view controller is a child view controller.
    private(set) weak var targetPresentationViewController: UIViewController?
}

// MARK: - Dependency Injection

extension ChallengeDetailTableViewController {
    
    /**
     Configures the view controller with dependencies necessary for the view controller to function properly.
     
     - parameter userController:            Controller for current authenticated user.
     - parameter challengeDetailController: Controller for challenge details.
     */
    func configure(withUserController userController: UserController, challengeDetailController: ChallengeDetailController, targetPresentationViewController: UIViewController?) {
        self.userController = userController
        self.challengeDetailController = challengeDetailController
        self.targetPresentationViewController = targetPresentationViewController
    }
}

// MARK: - Table

private extension ChallengeDetailTableViewController {
    
    enum TableSection: Int {
        case info
        case officialRules
        case community
        case _count
    }
    
    // MARK: Rows
    
    enum InfoSectionRow: Int {
        case content
        case _count
    }
    
    enum OfficialRulesSectionRow: Int {
        case content
        case _count
    }
    
    enum CommunitySectionRow: Int {
        case content
        case _count
    }
    
    // MARK: Cell Accessory
    
    /**
     *  Chevron image which can be tinted.
     */
    struct Chevron {
        
        /// Direction the chevron should be pointing towards.
        enum Direction {
            case up
            case right
            
            /// Name of asset corresponding to chevron facing the specified direction.
            var imageName: String {
                let imageName: String
                switch self {
                case .up:
                    imageName = "chevron-up"
                case .right:
                    imageName = "chevron-right"
                }
                return imageName
            }
            
            /// Height corresponding to chevron facing the specified direction.
            var height: CGFloat {
                let height: CGFloat
                switch self {
                case .up:
                    height = 9.0
                case .right:
                    height = 15.0
                }
                return height
            }
            
            /// Width corresponding to chevron facing the specified direction.
            var width: CGFloat {
                let width: CGFloat
                switch self {
                case .up:
                    width = 15.0
                case .right:
                    width = 9.0
                }
                return width
            }
        }
    }
}

// MARK: - Table Data Source

extension ChallengeDetailTableViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TableSection._count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableSection = TableSection(rawValue: section) else { fatalError("Invalid table section.") }
        
        var rowCount = 0
        switch tableSection {
        case .info:
            rowCount = InfoSectionRow._count.rawValue
            
        case .officialRules:
            rowCount = OfficialRulesSectionRow._count.rawValue
            
        case .community:
            guard challengeDetailController.challenge.community != nil else { break }
            rowCount =   CommunitySectionRow._count.rawValue
            
        case ._count:
            break
        }
        
        return rowCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let tableSection = TableSection(rawValue: indexPath.section) else { fatalError("Invalid table section.") }
        
        var cell: UITableViewCell!
        switch tableSection {
        case .info:
            guard let row = InfoSectionRow(rawValue: indexPath.row) else { break }
            switch row {
            case .content:
                cell = infoCell(forTableView: tableView, atIndexPath: indexPath)
            case ._count:
                break
            }
            
        case .officialRules:
            guard let row = OfficialRulesSectionRow(rawValue: indexPath.row) else { break }
            switch row {
            case .content:
                cell = officialRulesCell(forTableView: tableView, atIndexPath: indexPath)
            case ._count:
                break
            }
            
        case .community:
            guard let row = CommunitySectionRow(rawValue: indexPath.row) else { break }
            switch row {
            case .content:
                cell = communityCell(forTableView: tableView, atIndexPath: indexPath)
            case ._count:
                break
            }
            
        case ._count:
            break
        }
        
        if let cell = cell {
            return cell
        } else {
            fatalError("Method must produce a valid cell!")
        }
    }
}

// MARK: - Cell Configuration

extension ChallengeDetailTableViewController {
    
    // MARK: Info
    
    private func infoCell(forTableView tableView: UITableView, atIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ChallengeInfoTableViewCell.self, forIndexPath: indexPath)
        let challenge = challengeDetailController.challenge
        cell.configure(withChallengeDescription: challenge.sanitizedShortDescription, goalDescription: challenge.goalDescription)
        cell.selectionStyle = .None
        return cell
    }
   
    // MARK: Official Rules
    
    private func officialRulesCell(forTableView tableView: UITableView, atIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = basicCell(forTableView: tableView, indexPath: indexPath)
        let font = UIFont.systemFontOfSize(16.0)
        let text = NSLocalizedString("CHALLENGE_DETAIL_TABLE_CELL_OFFICIAL_RULES_TEXT", comment: "Text for official rules cell in challenge detail table.")
        configure(textLabelForCell: cell, withFont: font, text: text)
        cell.textLabel?.textColor = Theme.Color.Challenge.Detail.Segment.officialRulesText
        addChevronAccessory(facing: .up, toCell: cell)
        return cell
    }
    
    // MARK: Community
    
    private func communityCell(forTableView tableView: UITableView, atIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let community = challengeDetailController.challenge.community else { fatalError("Attempted to create a community cell without a community.") }
        let cell = basicCell(forTableView: tableView, indexPath: indexPath)
        let font = UIFont.systemFontOfSize(12.0)
        let text = community.name
        configure(textLabelForCell: cell, withFont: font, text: text)
        if community.isMember {
            cell.selectionStyle = .Default
            addChevronAccessory(facing: .right, toCell: cell)
        }
        return cell
    }
    
    // MARK: Convenience
    
    private func reset(cell cell: UITableViewCell) {
        cell.imageView?.image = nil
        cell.accessoryType = .None
        cell.accessoryView = nil
        cell.textLabel?.text = nil
        cell.tintColor = Theme.Color.Challenge.Detail.Segment.defaultTint
        cell.selectionStyle = .None
    }
    
    private func basicCell(forTableView tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self, forIndexPath: indexPath)
        reset(cell: cell)
        return cell
    }
    
    private func configure(textLabelForCell cell: UITableViewCell, withFont font: UIFont, text: String) {
        cell.textLabel?.text = text
        cell.textLabel?.font = font
    }

    private func addChevronAccessory(facing direction: Chevron.Direction, toCell cell: UITableViewCell) {
        let image = UIImage(named: direction.imageName)?.imageWithRenderingMode(.AlwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = Theme.Color.Challenge.Detail.Segment.chevron
        imageView.bounds.size = CGSize(width: direction.width, height: direction.height)
        cell.accessoryView = imageView
    }
}

// MARK: - Table Delegate

extension ChallengeDetailTableViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        guard let tableSection = TableSection(rawValue: indexPath.section) else { return }
        
        if tableSection == .officialRules {
            guard let row = OfficialRulesSectionRow(rawValue: indexPath.row) else { return }
            if row == .content {
                navigateToTermsAndConditions()
            }
        } else if tableSection == .community {
            guard let row = CommunitySectionRow(rawValue: indexPath.row) else { return }
            if row == .content {
                navigateToCommunityDetail()
            }
        }
    }
}

// MARK: - Action

extension ChallengeDetailTableViewController {
    
    private func navigateToTermsAndConditions() {
        let challenge = challengeDetailController.challenge
        guard let terms = challenge.terms else { return }
        guard targetPresentationViewController != nil else { return }
        
        let termsViewController = TermsAndConditionsViewController(nibName: "TermsAndConditionsView", bundle: nil);
        termsViewController.configure(withHTML: terms, viewingDelegate: self)
        let navigationController = UINavigationController(rootViewController: termsViewController)
        
        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            self?.targetPresentationViewController?.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
            })
    }
    
    private func navigateToCommunityDetail() {
        let storyboardName = CommunitiesViewController.Storyboard.name
        let detailIdentifier = CommunitiesViewController.Storyboard.Scene.Detail.identifier
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        guard let community = challengeDetailController.challenge.community,
            let communityDetailViewController = storyboard.instantiateViewControllerWithIdentifier(detailIdentifier) as? CommunityDetailViewController else { return }
        
        communityDetailViewController.configure(community, userController: userController, communitySubscriptionDelegate: nil)
        
        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            self?.targetPresentationViewController?.navigationController?.presentViewController(communityDetailViewController, animated: true, completion: nil)
            })
    }
}

// MARK: - Terms and Conditions Delegate

extension ChallengeDetailTableViewController: TermsAndConditionsViewingDelegate {
    
    func closeTerms() {
        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            self?.dismissViewControllerAnimated(true, completion: nil)
        })
    }
}
