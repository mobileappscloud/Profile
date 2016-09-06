//
//  ChallengesTableViewController.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 7/27/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class ChallengesTableViewController: UIViewController {
    private var userController: UserController!
    private var challengesController: ChallengesController!
    private var tableType: TableType!
    
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 400
            
            tableView.register(cellClass: UITableViewCell.self)
            tableView.register(nibWithCellClass: ChallengeTableViewCell.self)
            tableView.register(nibWithCellClass: ActivityIndicatorTableViewCell.self)
            tableView.register(nibWithCellClass: PreviousChallengesTableViewCell.self)
        }
    }
    
    lazy private var loadingViewController: UIViewController = {
        let storyboard = UIStoryboard(name: "Challenges", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("ChallengesListLoading")
        return viewController
    }()
    
    @IBOutlet var emptyLabelContainerView: UIView!
    @IBOutlet var emptyLabel: UILabel! {
        didSet {
            emptyLabel.text = emptyTableString
        }
    }
    
    private var emptyTableString: String?
    
    lazy private var blurredLoadingViewController: BlurredLoadingViewController = {
        let storyboard = UIStoryboard(name: "BlurredLoading", bundle: nil)
        return storyboard.instantiateInitialViewController() as! BlurredLoadingViewController
    }()
    
    func configureWith(userController userController: UserController, tableType: TableType, titleString: String? = nil, emptyTableString: String?) {
        self.userController = userController
        self.challengesController = ChallengesController(challengeRepository: userController.challengeRepository)
        self.tableType = tableType
        challengesController.pageSize = tableType.pageSize
        if let titleString = titleString {
            navigationItem.title = titleString
        }
        self.emptyTableString = emptyTableString
    }
    
    private func fetchChallenges() {
        challengesController.fetch(forEntityType: tableType.entityType, entityId: tableType.entityId, challengesType: tableType.challengeType, success: {
            [weak self] in
            self?.handleFetchChallengesSuccess()
        }, failure: {
            [weak self] _ in
            self?.handleFetchChallengesFailure()
        })
    }
    
    private func handleFetchChallengesSuccess() {
        dispatch_async(dispatch_get_main_queue()) {
            self.hidePlaceholderView()
            let sectionSet = NSIndexSet(indexesInRange: NSRange(0..<self.tableView.numberOfSections))
            self.tableView.reloadSections(sectionSet, withRowAnimation: .Automatic)
        }
    }

    private func handleFetchChallengesFailure() {
        dispatch_async(dispatch_get_main_queue()) {
            self.hidePlaceholderView()
            //TODO: Peter Ryszkiewicz: handle failure
        }
    }
}

// MARK: - Lifecycle

extension ChallengesTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        showPlaceholderView()
        fetchChallenges()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true) //FIXME: Might look bad after adding reloadData
        }
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ChallengesTableViewController.Storyboard.Segue.showChallengeDetail || segue.identifier == ChallengesTableViewController.Storyboard.Segue.showChallengeDetailJoin {
            guard let challenge = sender?["challenge"] as? Challenge,
                let userDidJoinChallengeCallback = sender?["userDidJoinChallengeCallback"] as? AnyWrapper<()->()> else { return }
            (segue.destinationViewController as? ChallengeDetailViewController)?.configure(
                withUserController: userController, challenge: challenge, userDidJoinChallengeCallback: userDidJoinChallengeCallback.object
            )
        }
    }
}

// MARK: - UITableViewDataSource
extension ChallengesTableViewController: UITableViewDataSource {
    var separatorCount: Int {
        return challengesController.challenges.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if challengesController.challenges.isEmpty && (tableType.entityType != .communities || tableType.challengeType == .Finished) {
            emptyLabelContainerView.hidden = true // TODO: modify this once we get assets for empty tables
        } else {
            emptyLabelContainerView.hidden = true // TODO: same as above
        }
        return TableSection._count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        guard let sectionType = TableSection(rawValue: section) else {
            return rowCount
        }
        
        switch sectionType {
        case .Challenges:
            rowCount = challengesController.challenges.count + separatorCount
        case .PreviousChallenges:
            if tableType.entityType == .communities && tableType.challengeType == .Current {
                rowCount = PreviousChallengesRowType._count.rawValue
            }
        case .InfiniteScroll:
            if let _ = challengesController.paging?.next {
                rowCount = 1
            }
        case ._count:
            break
        }
        
        return rowCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let sectionType = TableSection(rawValue: indexPath.section) else {
            fatalError("Invalid table section")
        }
        
        var cell: UITableViewCell!
        var selectionStyle: UITableViewCellSelectionStyle?
        switch sectionType {
        case .Challenges:
            let rowType = ChallengesRowType(indexPath: indexPath)
            switch rowType {
            case .Content:
                let challenge = challengeForIndexPath(indexPath)
                let challengeViewModel = ChallengeTableViewCellModel(challenge: challenge, hideCommunityInfo: tableType.entityType == .communities)
                let challengeCell = tableView.dequeueReusableCell(withClass: ChallengeTableViewCell.self, forIndexPath: indexPath)
                challengeCell.configure(withModel: challengeViewModel, joinButtonTappedCallback: {
                    [unowned challengeCell, unowned self] in
                    if challenge.isDirectlyJoinable {
                        self.segueToChallengeDetailJoinFor(challengeCell: challengeCell, challenge: challenge)
                    } else if challenge.isJoinableAfterCommunityIsJoined {
                        self.showJoinCommunityAlertFor(challengeCell: challengeCell, challenge: challenge)
                    } else {
                        //TODO: Log bad state
                    }
                }, userPhoto: userController.user.photo)
                cell = challengeCell
                
            case .Separator:
                let separatorCell = tableView.dequeueReusableCell(withClass: UITableViewCell.self, forIndexPath: indexPath)
                separatorCell.backgroundColor = Theme.Color.Primary.whiteGray
                cell = separatorCell
                
            case ._count:
                break
            }
            
        case .PreviousChallenges:
            let rowType = PreviousChallengesRowType(indexPath: indexPath)
            switch rowType {
            case .Content:
                cell = tableView.dequeueReusableCell(withClass: PreviousChallengesTableViewCell.self, forIndexPath: indexPath)
                selectionStyle = .Default
            case .Separator:
                let separatorCell = tableView.dequeueReusableCell(withClass: UITableViewCell.self, forIndexPath: indexPath)
                separatorCell.backgroundColor = Theme.Color.Primary.whiteGray
                cell = separatorCell
            case ._count:
                break
            }
           
        case .InfiniteScroll:
            let rowType = InfiniteScrollRowType(indexPath: indexPath)
            switch rowType {
            case .ActivityIndicator:
                cell = tableView.dequeueReusableCell(withClass: ActivityIndicatorTableViewCell.self, forIndexPath: indexPath)
            case ._count:
                break
            }
            
        case ._count:
            break
        }
        
        guard cell != nil else {
            fatalError("Method must produce a cell!")
        }
        
        cell.selectionStyle = selectionStyle ?? .None
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension ChallengesTableViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var rowHeight: CGFloat = 0.0
        guard let sectionType = TableSection(rawValue: indexPath.section) else { return rowHeight }
        
        switch sectionType {
            
        case .Challenges:
            let rowType = ChallengesRowType(indexPath: indexPath)
            rowHeight = rowType.defaultHeight()
            
        case .PreviousChallenges:
            let rowType = PreviousChallengesRowType(indexPath: indexPath)
            rowHeight = rowType.defaultHeight()
            
        case .InfiniteScroll:
            let rowType = InfiniteScrollRowType(indexPath: indexPath)
            rowHeight = rowType.defaultHeight()
            
        case ._count:
            break
        }
        
        return rowHeight
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let sectionType = TableSection(rawValue: indexPath.section) else { return }
        
        switch sectionType {
            
        case .InfiniteScroll:
            let rowType = InfiniteScrollRowType(indexPath: indexPath)
            switch rowType {
            case .ActivityIndicator:
                fetchNextChallenges()
            case ._count:
                break
            }
            
        case .PreviousChallenges:
            break
        case .Challenges:
            break
        case ._count:
            break
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let sectionType = TableSection(rawValue: indexPath.section) else { return }
        
        switch sectionType {
        case .InfiniteScroll:
            break
        case .PreviousChallenges:
            let previousChallengesVC = UIStoryboard(name: "Challenges", bundle: nil).instantiateViewControllerWithIdentifier(ChallengesViewController.Storyboard.Identifier.ChallengesTableViewController) as! ChallengesTableViewController
            let challengesTableType = ChallengesTableViewController.TableType(challengeType: .Finished, entityType: .communities, entityId: tableType.entityId, pageSize: 10)
            let emptyTableString = NSLocalizedString("CHALLENGES_VIEW_PREVIOUS_TABLE_EMPTY_TEXT", comment: "Text for when there are no previous challenges for the Previous Challenges table.")
            previousChallengesVC.configureWith(userController: userController, tableType: challengesTableType, titleString: NSLocalizedString("CHALLENGES_VIEW_PREVIOUS_CHALLENGES_TITLE_TEXT", comment: "Title text for Previous Challenges in the challenge table view."), emptyTableString: emptyTableString)
            navigationController?.pushViewController(previousChallengesVC, animated: true)
            
        case .Challenges:
            if let challengeCell = tableView.cellForRowAtIndexPath(indexPath) as? ChallengeTableViewCell {
                let challenge = challengeForIndexPath(indexPath)
                let wrappedFunction = AnyWrapper(object: challengeCell.userDidJoinChallenge)
                self.performSegueWithIdentifier(ChallengesTableViewController.Storyboard.Segue.showChallengeDetail, sender: [
                    "challenge": challenge,
                    "userDidJoinChallengeCallback": wrappedFunction
                ])
            }
        case ._count:
            break
        }
    }
}

// MARK: - Helpers

extension ChallengesTableViewController {
    private func challengeForIndexPath(indexPath: NSIndexPath) -> Challenge {
        return challengesController.challenges[indexPath.row / ChallengesRowType._count.rawValue]
    }
    
    private func segueToChallengeDetailJoinFor(challengeCell challengeCell: ChallengeTableViewCell, challenge: Challenge) {
        let wrappedFunction = AnyWrapper(object: challengeCell.userDidJoinChallenge)
        performSegueWithIdentifier(ChallengesTableViewController.Storyboard.Segue.showChallengeDetailJoin, sender: [
            "challenge": challenge,
            "userDidJoinChallengeCallback": wrappedFunction
        ])
    }
    
    private func showJoinCommunityAlertFor(challengeCell challengeCell: ChallengeTableViewCell, challenge: Challenge) {
        guard let community = challenge.community else { return }
        let communityMembershipTitleString = NSLocalizedString("CHALLENGES_DETAIL_JOIN_COMMUNITY_COMMUNITY_MEMBERSHIP_TITLE", comment: "Text for the title of the join community message to the user, Community Membership.")
        let communityMembershipMessageFormat = NSLocalizedString("CHALLENGES_DETAIL_JOIN_COMMUNITY_MESSAGE_FORMAT", comment: "Format for the join community message displayed to the user.")
        let communityMembershipMessageString = String(format: communityMembershipMessageFormat, arguments: [community.name])
        let alertViewController = UIAlertController(title: communityMembershipTitleString, message: communityMembershipMessageString, preferredStyle: .Alert)
        let cancelString = NSLocalizedString("CHALLENGES_DETAIL_JOIN_COMMUNITY_CANCEL_STRING", comment: "Text for the cancel button of the join community prompt to the user.")
        let cancelAction = UIAlertAction(title: cancelString, style: .Cancel, handler: nil)
        let okString = NSLocalizedString("CHALLENGES_DETAIL_JOIN_COMMUNITY_OK_STRING", comment: "Text for the OK button of the join community prompt to the user.")
        let failureHandler = {
            [weak self] (error: ErrorType) in
            dispatch_async(dispatch_get_main_queue()) {
                self?.blurredLoadingViewController.hide()
                //TODO: Peter Ryszkiewicz
            }
        }
        let okAction = UIAlertAction(title: okString, style: .Default) { (_) in
            self.blurredLoadingViewController.show(self)
            self.joinCommunity(community: community, success: {
                [weak self] in
                self?.challengesController.refreshChallenge(challenge, success: { _ in // refresh challenge to obtain the joinUrl, now that it should be joinable
                    dispatch_async(dispatch_get_main_queue()) {
                        self?.tableView.reloadData()
                        self?.blurredLoadingViewController.hide()
                        self?.segueToChallengeDetailJoinFor(challengeCell: challengeCell, challenge: challenge)
                    }
                }, failure: failureHandler)
            }, failure: failureHandler)
        }
        alertViewController.addAction(cancelAction)
        alertViewController.addAction(okAction)
        presentViewController(alertViewController, animated: true, completion: nil)
    }
    
    private func joinCommunity(community community: Community, success: () -> (), failure: (error: ErrorType) -> ()) {
        challengesController.updateSubscription(community, subscribeAction: .Join, user: userController.user, success: { (community) in
            success()
        }, failure: {error in
            failure(error: error ?? Error.joinCommunity)
        })
    }
}

//MARK: - Errors

extension ChallengesTableViewController {
    enum Error: ErrorType {
        case unknown
        case joinCommunity
    }
}

// MARK: - Paging

extension ChallengesTableViewController {
    private func fetchNextChallenges() {
        guard let _ = challengesController.paging?.next else { return }
        
        challengesController.fetchNext(fetchNextSuccess, failure: fetchNextFailure)
    }
    
    private func fetchNextSuccess() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
    private func fetchNextFailure(error: ErrorType) {
        
    }
}

// MARK: - Loading View

extension ChallengesTableViewController {
    func showPlaceholderView() {
        addChildViewController(loadingViewController)
        loadingViewController.view.alpha = 1.0
        tableView.addSubview(loadingViewController.view)
        loadingViewController.view.frame = tableView.bounds
        loadingViewController.didMoveToParentViewController(self)
    }
    
    func hidePlaceholderView() {
        loadingViewController.willMoveToParentViewController(nil)
        tableView.willRemoveSubview(loadingViewController.view)
        UIView.animateWithDuration(0.2, animations: {
            self.loadingViewController.view.alpha = 0.0
        }, completion: { (success) in
            self.loadingViewController.view.removeFromSuperview()
            self.loadingViewController.didMoveToParentViewController(nil)
        })
    }
}

// MARK: - Table Enums

extension ChallengesTableViewController {
    struct TableType {
        let challengeType: ChallengesController.ChallengeType?
        let entityType: ChallengeCollectionRequest.EntityType
        let entityId: String
        let pageSize: Int
    }
    
    enum TableSection: Int  {
        case Challenges
        case PreviousChallenges
        case InfiniteScroll
        case _count
    }
    
    enum ChallengesRowType: Int {
        case Content
        case Separator
        case _count
        
        init(indexPath: NSIndexPath) {
            self = ChallengesRowType(rawValue: indexPath.row % ChallengesRowType._count.rawValue)!
        }
        
        func defaultHeight() -> CGFloat {
            switch self {
            case .Content:
                return UITableViewAutomaticDimension
            case .Separator:
                return 17.0
            case ._count:
                return 0.0
            }
        }
    }
    
    enum PreviousChallengesRowType: Int {
        case Content
        case Separator
        case _count
        
        init(indexPath: NSIndexPath) {
            self = PreviousChallengesRowType(rawValue: indexPath.row % PreviousChallengesRowType._count.rawValue)!
        }
        
        func defaultHeight() -> CGFloat {
            switch self {
            case .Content:
                return 44.0
            case .Separator:
                return 17.0
            case ._count:
                return 0.0
            }
        }
    }
    
    enum InfiniteScrollRowType: Int {
        case ActivityIndicator
        case _count
        
        init(indexPath: NSIndexPath) {
            self = InfiniteScrollRowType(rawValue: indexPath.row % InfiniteScrollRowType._count.rawValue)!
        }
        
        func defaultHeight() -> CGFloat {
            switch self {
            case .ActivityIndicator:
                return 70.0
            case ._count:
                return 0.0
            }
        }
    }
    
    struct Storyboard {
        static let name = "Challenges"
        
        struct Segue {
            static let showChallengeDetail = "ShowChallengeDetail"
            static let showChallengeDetailJoin = "ShowChallengeDetailJoin"
        }
    }
}
