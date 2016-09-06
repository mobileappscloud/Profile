//
//  ChallengeTableViewCellModel.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 7/27/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class ChallengeTableViewCellModel {
    let titleText: String
    let dateText: String
    let participantCountText: String
    let mainImageAsset: MediaAsset
    let communityImageAsset: MediaAsset?
    let communityText: String?
    let challengeInformationUpperText: NSAttributedString?
    let challengeInformationLowerText: NSAttributedString?
    let challengeInformationImage: UIImage?
    let progressMilestones: [CGFloat]?
    let challenge: Challenge
    let hideCommunityInfo: Bool
    
    init(challenge: Challenge, hideCommunityInfo: Bool) {
        self.challenge = challenge
        titleText = challenge.name
        dateText = NewChallengeUtility.formattedDateRange(forStartDate: challenge.startDate, endDate: challenge.endDate)
        participantCountText = NewChallengeUtility.formattedParticipantCount(forParticipantCount: challenge.participantCount)
        mainImageAsset = challenge.image
        communityImageAsset = challenge.community?.logo
        communityText = challenge.community?.name
        challengeInformationUpperText = ChallengeTableViewCellModel.makeAttributedStringFor(goalDescription: challenge.goalDescription)
        challengeInformationLowerText = ChallengeTableViewCellModel.makeAttributedStringFor(
            prizesDescription: challenge.prizeDescription ?? NSLocalizedString("CHALLENGES_VIEW_CARD_INFORMATION_NO_PRIZE_TEXT", comment: "Text for No Prize for the prizes description on the challenge card information view.")
        )
        challengeInformationImage = nil //TODO: Fill in with an asset based on the state of the challenge
        progressMilestones = nil
        self.hideCommunityInfo = hideCommunityInfo
    }
}

// MARK: - Static Helpers and Properties
extension ChallengeTableViewCellModel {
    private static let challengeInfoFontSize: CGFloat = 15.0
    
    private class func makeAttributedStringFor(goalDescription goalDescriptionString: String) -> NSAttributedString {
        let goalFormat = NSLocalizedString("CHALLENGES_VIEW_CARD_INFORMATION_GOAL_FORMAT", comment: "Format for the goal description on the challenge card information view.")
        let goalString = NSLocalizedString("CHALLENGES_VIEW_CARD_INFORMATION_GOAL_TEXT", comment: "Text for Goal for the goal description on the challenge card information view.")
        return makeAttributedStringFor(format: goalFormat, title: goalString, description: goalDescriptionString)
    }
    
    private class func makeAttributedStringFor(prizesDescription prizesDescriptionString: String) -> NSAttributedString {
        let prizesFormat = NSLocalizedString("CHALLENGES_VIEW_CARD_INFORMATION_PRIZES_FORMAT", comment: "Format for the prize description on the challenge card information view.")
        let prizesString = NSLocalizedString("CHALLENGES_VIEW_CARD_INFORMATION_PRIZES_TEXT", comment: "Text for Prizes for the prize description on the challenge card information view.")
        return makeAttributedStringFor(format: prizesFormat, title: prizesString, description:  prizesDescriptionString)
    }
    
    private class func makeAttributedStringFor(format formatString: String, title titleString: String, description descriptionString: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: String(format: formatString, arguments: [titleString, descriptionString]))
        let rangeOfTitleText = (attributedString.string as NSString).rangeOfString(titleString)
        attributedString.setAttributes([
            NSFontAttributeName: UIFont.boldSystemFontOfSize(challengeInfoFontSize)
        ], range: rangeOfTitleText)
        let rangeOfDescriptionText = (attributedString.string as NSString).rangeOfString(descriptionString)
        attributedString.setAttributes([
            NSFontAttributeName: UIFont.systemFontOfSize(challengeInfoFontSize)
        ], range: rangeOfDescriptionText)
        return attributedString
    }
}

