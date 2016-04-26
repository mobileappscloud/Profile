//
//  CommunityDetailJoinSegue.swift
//  higi
//
//  Created by Remy Panicker on 4/21/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class CommunityDetailJoinSegue: UIStoryboardSegue {

    override func perform() {
        guard let destination = self.destinationViewController as? CommunityDetailViewController else { return }
        
        let source = self.sourceViewController        
        source.navigationController?.pushViewController(destination, animated: true, completion: {
            destination.joinCommunity()
        })
    }
}
