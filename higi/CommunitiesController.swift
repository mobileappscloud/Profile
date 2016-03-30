//
//  CommunitiesController.swift
//  higi
//
//  Created by Remy Panicker on 3/25/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class CommunitiesController: NSObject {
    
    private(set) var communitiesJoinedSet: Set<Community> = []
    private(set) var communitiesJoined: [Community] = []
    
    private(set) var communitiesUnjoinedSet: Set<Community> = []
    private(set) var communitiesUnjoined: [Community] = []
    
    private(set) var paging: Paging? = nil
}

