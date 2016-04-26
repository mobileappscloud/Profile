//
//  CommunitiesExpandedListSegue.swift
//  higi
//
//  Created by Remy Panicker on 4/22/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class CommunitiesExpandedListSegue: UIStoryboardSegue {

    override func perform() {
        guard let source = self.sourceViewController as? CommunitiesViewController,
            let destination = self.destinationViewController as? CommunitiesExpandedViewController else { return }
        
        let indexPath = source.communityListMaxIndexPath()
        source.navigationController?.pushViewController(destination, animated: true, completion: {
            destination.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        })
    }
}
