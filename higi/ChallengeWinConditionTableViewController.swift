//
//  ChallengeWinConditionTableViewController.swift
//  higi
//
//  Created by Remy Panicker on 8/31/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class ChallengeWinConditionTableViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.estimatedRowHeight = 200.0
            tableView.rowHeight = UITableViewAutomaticDimension
            
            tableView.tableFooterView = UIView()
            
            tableView.register(nibWithCellClass: ChallengeWinConditionTableViewCell.self)
            tableView.separatorStyle = .None
            tableView.allowsSelection = false
        }
    }
    
    private var challengeWinConditionController: ChallengeWinConditionController!
}

// MARK: - Dependency Injection

extension ChallengeWinConditionTableViewController {
    
    func configure(withChallenge challenge: Challenge) {
        challengeWinConditionController = ChallengeWinConditionController(challenge: challenge)
    }
}

// MARK: - Table Data Source

extension ChallengeWinConditionTableViewController: UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return challengeWinConditionController.challenge.winConditions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return winConditionCell(forTableView: tableView, atIndexPath: indexPath)
    }
}

// MARK: - Custom Cell

private extension ChallengeWinConditionTableViewController {
 
    func winConditionCell(forTableView tableView: UITableView, atIndexPath indexPath: NSIndexPath) -> ChallengeWinConditionTableViewCell {
        let winConditionCell = tableView.dequeueReusableCell(withClass: ChallengeWinConditionTableViewCell.self, forIndexPath: indexPath)
        
        winConditionCell.winConditionLabel.text = nil
        winConditionCell.prizeLabel.text = nil
        winConditionCell.prizeImageView.image = nil
        winConditionCell.prizeIconImageView.hidden = true
        winConditionCell.prizeImageView.hidden = true
        
        let challenge = challengeWinConditionController.challenge
        let winCondition = challenge.winConditions[indexPath.row]
        
        winConditionCell.placeLabel.attributedText = attributedWinConditionName(withName: winCondition.name, drawingQuantity: winCondition.drawingQuantity)
        
        if let prize = winCondition.prize {
            winConditionCell.prizeIconImageView.hidden = false
            winConditionCell.prizeLabel.text = prize.name
            winConditionCell.prizeImageView.setImage(withMediaAsset: prize.image)
            winConditionCell.prizeImageView.hidden = false
        }
        
        winConditionCell.winConditionLabel.text = winCondition.description
        
        return winConditionCell
    }
    
    func attributedWinConditionName(withName name: String, drawingQuantity: Int?) -> NSAttributedString {
        guard let drawingQuantity = drawingQuantity where drawingQuantity > 0 else {
            return NSAttributedString(string: name)
        }
        
        let formattedDrawingQuantity =  NSString.localizedStringWithFormat(NSLocalizedString("CHALLENGE_WIN_CONDITION_WINNER_SINGLE_PLURAL", comment: "Format for pluralization of winners."), drawingQuantity)
        
        let format = NSLocalizedString("CHALLENGE_DETAIL_WIN_CONDITION_NAME_FORMAT", comment: "Format of win condition name displayed within challenge detail prizes segment.")
        let formattedString = String(format: format, arguments: [name, formattedDrawingQuantity])
        
        let attrString = NSMutableAttributedString(string: formattedString)
        
        let nameFont = UIFont.systemFontOfSize(20.0, weight: UIFontWeightSemibold)
        let nameRange = (attrString.string as NSString).rangeOfString(name)
        attrString.addAttributes([NSFontAttributeName : nameFont], range: nameRange)
        
        let quantityFont = UIFont.systemFontOfSize(20.0)
        let quantityRange = (attrString.string as NSString).rangeOfString(formattedDrawingQuantity as String)
        attrString.addAttributes([NSFontAttributeName : quantityFont], range: quantityRange)
        
        return attrString.copy() as! NSAttributedString
    }
}
