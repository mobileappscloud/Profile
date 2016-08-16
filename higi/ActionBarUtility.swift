//
//  ActionBarUtility.swift
//  higi
//
//  Created by Remy Panicker on 7/27/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ActionBarUtility {
    
    private static func actionTypes(forContent content: ContentInteractable) -> [ActionBar.Action.Types] {
        
        var actionTypes: [ActionBar.Action.Types] = []
        
        let actions = content.actions
        let permissions = content.permissions
        
        if permissions.canLike {
            if actions.hasLiked {
                actionTypes.append(.Unlike)
            } else {
                actionTypes.append(.Like)
            }
        }
        
        if permissions.canComment {
            if let content = content as? Comment {
                if !content.isReply {
                    actionTypes.append(.Reply)
                }
            } else {
                actionTypes.append(.Comment)
            }
        }
        
        if content is Post {
            actionTypes.append(.Share)
        }
        
        if permissions.canLike {
            actionTypes.append(.Likers)
        }
        
        if permissions.canLike &&
            (actionTypes.contains(.Comment) || actionTypes.contains(.Reply)) {
            actionTypes.append(.Commenters)
        }
        
        return actionTypes
    }
    
    static func actions(forContent content: ContentInteractable) -> [ActionBar.Action] {
        
        var actions: [ActionBar.Action] = []
        
        let types = actionTypes(forContent: content)
        for type in types {
            
            var title: String?
            var isBold = false
            var tintColor: UIColor = Theme.Color.Content.ActionBar.primary
            var imageName: String?
            
            switch type {
            case .Like:
                title = NSLocalizedString("CONTENT_ACTION_BAR_ACTION_TITLE_LIKE", comment: "Title for action in content action bar which 'likes' a content item.")
                isBold = content.actions.hasLiked
                
            case .Unlike:
                title = NSLocalizedString("CONTENT_ACTION_BAR_ACTION_TITLE_UNLIKE", comment: "Title for action in content action bar which 'unlikes' a content item.")
                isBold = content.actions.hasLiked
                
            case .Comment:
                title = NSLocalizedString("CONTENT_ACTION_BAR_ACTION_TITLE_COMMENT", comment: "Title for action in content action bar which posts a comment targeted towards a content item.")
                isBold = content.actions.hasCommented
                
            case .Reply:
                title = NSLocalizedString("CONTENT_ACTION_BAR_ACTION_TITLE_REPLY", comment: "Title for action in content action bar which posts a reply targeted towards a content item.")
                isBold = content.actions.hasCommented
                
            case .Share:
                title = NSLocalizedString("CONTENT_ACTION_BAR_ACTION_TITLE_SHARE", comment: "Title for action in content action bar which shares a content item.")
                
            case .Likers:
                if content.actions.hasLiked {
                    var likeCount = content.likeCount
                    if content.actions.hasLiked {
                        likeCount -= 1
                    }
                    if likeCount > 0 {
                        let format = NSLocalizedString("CONTENT_ACTION_BAR_ACTION_TITLE_LIKERS_FORMAT", comment: "Format of title for action in content action bar which shows the users who have 'liked' a content item when current user and others have liked the content item.")
                        let count = Utility.abbreviatedNumber(likeCount)
                        title = String(format: format, arguments: [count.formattedString])
                    } else {
                        title = NSLocalizedString("CONTENT_ACTION_BAR_ACTION_TITLE_LIKERS", comment: "Title for action in content action bar which shows the users who have 'liked' a content item when only the current user has liked the content item.")
                    }
                } else if content.likeCount > 0 {
                    let count = Utility.abbreviatedNumber(content.likeCount)
                    title = count.formattedString
                }
                tintColor = Theme.Color.Content.ActionBar.secondary
                imageName = "action-bar-high-five-icon"
                
            case .Commenters:
                if content.commentCount > 0 {
                    let count = Utility.abbreviatedNumber(content.commentCount)
                    title = count.formattedString
                }
                tintColor = Theme.Color.Content.ActionBar.secondary
                imageName = "action-bar-chatter-icon"
            }
    
            let action = ActionBar.Action(type: type, title: title, isBold: isBold, tintColor: tintColor, imageName: imageName)
            actions.append(action)
        }
        
        return actions
    }
}

extension ActionBarUtility {
    
    /**
     Returns a new copy of the content with updated values for like count and actions.
     
     - parameter copy:  Content item to be copied.
     - parameter count: Value to increment the like count by. Set this value to `1` for a like, `-1` for an unlike.
     
     - returns: Modified copy of the content item.
     */
    static func copy<T: ContentInteractable>(content: T, incrementedLikeCount count: Int) -> T {
        let likeCount = content.likeCount + count
        let actions = Content.Actions(hasCommented: content.actions.hasCommented, hasLiked: (count > 0))
        
        if content is Comment {
            let content = content as! Comment
            return content.copy(likeCount: likeCount, actions: actions) as! T
        } else if content is Post {
            let content = content as! Post
            return content.copy(likeCount: likeCount, actions: actions) as! T
        } else {
            fatalError("Unsupported content type.")
        }
    }
}

// MARK: - Common handlers

extension ActionBarUtility {
    
    static func navigateToCommentViewController(userController: UserController, post: Post, targetPresentationViewController: UIViewController?) {
        
        let storyboard = UIStoryboard(name: "Comment", bundle: nil)
        guard let commentViewController = storyboard.instantiateInitialViewController() as? CommentTableViewController else { return }
        
        commentViewController.configure(userController, post: post)
        
        dispatch_async(dispatch_get_main_queue(), { [weak targetPresentationViewController] in
            targetPresentationViewController?.navigationController?.pushViewController(commentViewController, animated: true)
        })
    }
    
    /**
     Updates the action bar to reflect changes to the content item. This method is thread-safe.
     
     - parameter actionBar: Action bar to be updated.
     - parameter content:   Content item for the action bar.
     */
    static func update(actionBar: ActionBar, forContent content: ContentInteractable) {
        let updatedActions = actions(forContent: content)
        dispatch_async(dispatch_get_main_queue(), {
            actionBar.configure(updatedActions)
            actionBar.setNeedsDisplay()
        })
    }
}
