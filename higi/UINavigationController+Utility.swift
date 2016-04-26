//
//  UINavigationController+Utility.swift
//  higi
//
//  Created by Remy Panicker on 4/22/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

extension UINavigationController {
    
    public func pushViewController(viewController: UIViewController, animated: Bool, completion: Void -> Void) {
        pushViewController(viewController, animated: animated)
        
        guard animated, let coordinator = transitionCoordinator() else {
            completion()
            return
        }
        
        coordinator.animateAlongsideTransition(
            // pass nil here or do something animated if you'd like
            { context in
                
            },
            completion: { context in
                completion()
            }
        )
    }
}
