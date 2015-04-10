//
//  BodyStatCheckinCell.swift
//  higi
//
//  Created by Dan Harms on 7/28/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class BodyStatCheckinCell: UITableViewCell {
    
    @IBOutlet weak var selectionIndicator: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var gauge: UIImageView!
    @IBOutlet weak var measureValue: UILabel!
    @IBOutlet weak var bpMeasures: UIView!
    @IBOutlet weak var systolic: UILabel!
    @IBOutlet weak var diastolic: UILabel!
    @IBOutlet weak var cardButton: UIButton!
    
    var checkin: HigiCheckin!;
    var checkinCardContainer: UIView!;
    var checkinContainer: UIView!;
    var checkinBlur: UIView!;
    var parentViewController: BodyStatsViewController!;
    
    @IBAction func bringUpCard(sender: AnyObject) {
        if (parentViewController == nil) {
            parentViewController = Utility.getViewController(self) as! BodyStatsViewController!;
        }
        parentViewController.revealController.shouldRotate = false;
        parentViewController.revealController.supportedOrientations = UIInterfaceOrientationMask.Portrait.rawValue;
        parentViewController.portView.scrollView.scrollEnabled = false;
        parentViewController!.navigationController!.navigationBarHidden = true;
        parentViewController!.navigationController!.navigationBar.userInteractionEnabled = false;
        parentViewController.fakeNavBar.hidden = true;
        self.parentViewController.portView.orientationIndicator.hidden = true;
        self.parentViewController.portView.pager.hidden = true;
        checkinContainer.hidden = false;
        var checkinCard = UINib(nibName: "CheckinCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! CheckinCard;
        checkinCard.frame.size = checkinCardContainer.frame.size;
        checkinCard.createTable(checkin, onClose: self.closeCheckinCard, onSelection: self.checkinMeasureSelected);
        checkinCardContainer.addSubview(checkinCard);
        checkinCard.frame.origin.y = checkinCard.frame.size.height;
        
        UIView.animateWithDuration(0.15, delay: 0.0, options: .CurveEaseInOut, animations: {
            
            self.checkinContainer.alpha = 1.0;
            
            }, completion: {finished in
                UIView.animateWithDuration(0.35, delay: 0.0, options: .CurveEaseInOut, animations: {
                    
                    checkinCard.frame.origin.y = 0;
                    
                    }, completion: nil);
        });
        checkinCard.setupMap();
    }
    
    func closeCheckinCard(checkinCard: UIView) {
        
        UIView.animateWithDuration(0.35, delay: 0.0, options: .CurveEaseInOut, animations: {
            
            checkinCard.frame.origin.y = checkinCard.frame.size.height;
            
            }, completion: {finished in
                self.parentViewController.navigationController!.navigationBarHidden = false;
                self.parentViewController.fakeNavBar.hidden = false;
                self.parentViewController.navigationController!.navigationBar.userInteractionEnabled = true;
                self.parentViewController.portView.orientationIndicator.hidden = false;
                self.parentViewController.portView.pager.hidden = false;
                UIView.animateWithDuration(0.15, delay: 0.0, options: .CurveEaseInOut, animations: {
                    self.checkinContainer.alpha = 0.0;
                    }, completion: {finished in
                        self.checkinContainer.hidden = true;
                });
                checkinCard.removeFromSuperview();
                self.parentViewController.portView.scrollView.scrollEnabled = true;
                self.parentViewController.revealController.supportedOrientations = UIInterfaceOrientationMask.Portrait.rawValue | UIInterfaceOrientationMask.LandscapeLeft.rawValue | UIInterfaceOrientationMask.LandscapeRight.rawValue;
                self.parentViewController.revealController.shouldRotate = true;
        });
    }
    
    func checkinMeasureSelected(checkin: HigiCheckin, selected: Int) {
        var offsetSelected = selected;
        if (checkin.bpClass == nil) {
            offsetSelected += 3;
        }
        var pager = parentViewController.portView.pager;
        pager.currentPage = offsetSelected;
        parentViewController.changePage(pager);
        parentViewController.setSelected(checkin);
    }
}