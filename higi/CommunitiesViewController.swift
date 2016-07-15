//
//  CommunitiesViewController.swift
//  higi
//
//  Created by Remy Panicker on 3/25/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class CommunitiesViewController: UIViewController {
    
    struct Storyboard {
        static let name = "Communities"
        
        private struct Scene {
            static let listView = "CommunitiesListView"
            static let loadingView = "CommunityListLoading"
        }
        
        struct Segue {
            static let segmentedPage = "SegmentedPageViewEmbedSegue"
            
            struct DetailView {
                
                struct Segue {
                    static let segmentedPage = "DetailViewSegmentedPageViewEmbedSegue"
                }
                
                static let identifier = "CommunityDetailViewControllerSegue"
                static let joinIdentifier = "CommunityDetailViewControllerJoinSegue"
                
                let community: Community
                let userController: UserController
                var communitySubscriptionDelegate: CommunitySubscriptionDelegate?
                var join: Bool = false
                
                init(community: Community, userController: UserController, communitySubscriptionDelegate: CommunitySubscriptionDelegate?, join: Bool = false) {
                    self.community = community
                    self.userController = userController
                    self.communitySubscriptionDelegate = communitySubscriptionDelegate
                    self.join = join
                }
                
                func userInfo() -> [String: AnyObject] {
                    let subscriptionDelegate: AnyObject = (communitySubscriptionDelegate != nil) ? communitySubscriptionDelegate! : NSNull()
                    return [
                        "community" : community,
                        "userController" : userController,
                        "communitySubscriptionDelegate" : subscriptionDelegate,
                        "join" : join
                    ]
                }
                
                init?(userInfo: AnyObject?) {
                    guard let userInfo = userInfo as? NSDictionary,
                        let community = userInfo["community"] as? Community,
                        let userController = userInfo["userController"] as? UserController,
                        let communitySubscriptionDelegate = userInfo["communitySubscriptionDelegate"] as? CommunitySubscriptionDelegate,
                        let join = userInfo["join"] as? Bool else { return nil }
                    
                    self.community = community
                    self.userController = userController
                    self.communitySubscriptionDelegate = communitySubscriptionDelegate
                    self.join = join
                }
            }
        }
    }
    
    private enum SegmentedControl: Int {
        case Featured
        case Yours
        case Count
    }
    
    private var segmentedPageViewController: SegmentedPageViewController!
    private lazy var featuredCommunitiesViewController: CommunitiesTableViewController = {
        return self.viewController(.Unjoined)
    }()
    private lazy var yourCommunitiesViewController: CommunitiesTableViewController = {
        return self.viewController(.Joined)
    }()
    
    private(set) var userController: UserController!
    
    deinit {
        print("deinit \(self.dynamicType)")
    }
    
    func configure(userController: UserController) {
        self.userController = userController
    }
}

// MARK: - Constructor

private extension CommunitiesViewController {
    
    func viewController(filter: CommunityCollectionRequest.Filter) -> CommunitiesTableViewController {
        let storyboard = UIStoryboard(name: "Communities", bundle: nil)
        let communitiesTableViewController = storyboard.instantiateViewControllerWithIdentifier(CommunitiesViewController.Storyboard.Scene.listView) as! CommunitiesTableViewController
        let controller = CommunitiesController(filter: filter)
        communitiesTableViewController.configure(userController, communitiesController: controller, delegate: self, communitySubscriptionDelegate: self)
        return communitiesTableViewController
    }
}

// MARK: - View Lifecycle

extension CommunitiesViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("COMMUNITIES_VIEW_TITLE", comment: "Title for communities view.")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.setAnimationsEnabled(false)
        self.navigationItem.prompt = nil
        UIView.setAnimationsEnabled(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Flurry.logEvent("CommunityList_Viewed")
    }
}

// MARK: - Navigation

extension CommunitiesViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        typealias Segue = CommunitiesViewController.Storyboard.Segue
        typealias DetailSegue = Segue.DetailView
        if segue.identifier == DetailSegue.identifier || segue.identifier == DetailSegue.joinIdentifier {
            guard let viewController = segue.destinationViewController as? CommunityDetailViewController,
                let userInfo = CommunitiesViewController.Storyboard.Segue.DetailView(userInfo: sender) else {
                    return
            }
            
            viewController.configure(userInfo.community, userController: userInfo.userController, communitySubscriptionDelegate: self)
        } else if segue.identifier == Segue.segmentedPage {
            segmentedPageViewController = segue.destinationViewController as! SegmentedPageViewController
            
            let horizontalMargin: CGFloat = 60.0
            segmentedPageViewController.segmentedControlHorizontalMargin = horizontalMargin
            
            let featuredTitle = NSLocalizedString("COMMUNITIES_VIEW_SEGMENTED_CONTROL_TITLE_FEATURED_COMMUNITIES", comment: "Title for 'Featured' communities segment on segmented control in communities list view.")
            let yoursTitle = NSLocalizedString("COMMUNITIES_VIEW_SEGMENTED_CONTROL_TITLE_YOUR_COMMUNITIES", comment: "Title for your (joined) communities segment on segmented control in communities list view.")
            let titles = [featuredTitle, yoursTitle]
            let viewControllers = [featuredCommunitiesViewController, yourCommunitiesViewController]
            
            segmentedPageViewController.set(viewControllers, titles: titles)
        }
    }
}

// MARK: - Community List Delegate

extension CommunitiesViewController: CommunitiesTableViewControllerDelegate {
    
    func communitiesTableViewControllerDidTapDetail(communitiesTableViewController: CommunitiesTableViewController, communitiesController: CommunitiesController, userController: UserController, community: Community, communitySubscriptionDelegate: CommunitySubscriptionDelegate?) {
        
        let segue = CommunitiesViewController.Storyboard.Segue.DetailView(community: community, userController: userController, communitySubscriptionDelegate: communitySubscriptionDelegate)
        self.performSegueWithIdentifier(CommunitiesViewController.Storyboard.Segue.DetailView.identifier, sender: segue.userInfo())
    }
    
    func communitiesTableViewControllerDidTapJoin(communitiesTableViewController: CommunitiesTableViewController, communitiesController: CommunitiesController, userController: UserController, community: Community, communitySubscriptionDelegate: CommunitySubscriptionDelegate?) {
        
        
    }
}

extension CommunitiesViewController: CommunitySubscriptionDelegate {
    
    func didJoin(community: Community) {
        swap(community, fromViewController: featuredCommunitiesViewController, toViewController: yourCommunitiesViewController)
    }
    
    func didLeave(community: Community) {
        swap(community, fromViewController: yourCommunitiesViewController, toViewController: featuredCommunitiesViewController)
    }
    
    private func swap(community: Community, fromViewController: CommunitiesTableViewController, toViewController: CommunitiesTableViewController) {
        fromViewController.communitiesController.remove([community])
        toViewController.communitiesController.append([community])
        
        dispatch_async(dispatch_get_main_queue(), {
            fromViewController.tableView?.reloadData()
            toViewController.tableView?.reloadData()
        })
    }
}

// MARK: - Tab Bar Scroll

extension CommunitiesViewController: TabBarTopScrollDelegate {
    
    func scrollToTop() {
        if let viewController = segmentedPageViewController.selectedViewController as? TabBarTopScrollDelegate {
            viewController.scrollToTop()
        }
    }
}
