//
//  GraphDelegate.swift
//  higi
//
//  Created by Dan Harms on 7/24/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

protocol GraphDelegate {
    
    func getBackgroundColor() -> UIColor;
    
    func createGraph(checkins: [HigiCheckin], isPortrait: Bool, frame: CGRect) -> BaseCustomGraphHostingView?;
    
    func getHighlightString(checkin: HigiCheckin) -> String;
    
    func getTitle() -> String;
    
    func getUnit() -> String;
    
    func getMeasureValue(checkin: HigiCheckin) -> String;
    
    func getMeasureClass(checkin: HigiCheckin) -> String;
    
    func cellForCheckin(checkin: HigiCheckin, cell: BodyStatCheckinCell);
    
    func getInfoImage() -> UIImage;
    
    func getScreenPoint(graph: CPTGraphHostingView, checkin: HigiCheckin, isPortrait: Bool) -> CGPoint;
    
    func getScreenPoint2(graph: CPTGraphHostingView, checkin: HigiCheckin, isPortrait: Bool) -> CGPoint?;
}