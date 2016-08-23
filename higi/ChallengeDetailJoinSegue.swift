//
//  ChallengeDetailJoinSegue.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 8/22/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class ChallengeDetailJoinSegue: UIStoryboardSegue {
    override func perform() {
        guard let destination = self.destinationViewController as? ChallengeDetailViewController else { return }
        
        self.sourceViewController.navigationController?.pushViewController(destination, animated: true, completion: {
            destination.joinChallenge()
        })
    }
}
