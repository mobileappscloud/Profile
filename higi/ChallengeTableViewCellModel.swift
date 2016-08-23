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
    let challengeStatusState: State
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

    var isChallengeJoinable: Bool {
        return challenge.canBeJoined && challenge.userRelation.joinURL != nil
    }
    
    init(challenge: Challenge) {
        self.challenge = challenge
        titleText = challenge.name
        challengeStatusState = State(withChallenge: challenge)
        dateText = ChallengeTableViewCellModel.getFormattedDateRangeFor(startDate: challenge.startDate, endDate: challenge.endDate)
        let participantCountFormat = NSLocalizedString("CHALLENGES_VIEW_CARD_PARTICIPANT_COUNT_FORMAT", comment: "Format for the number of people participating in a challenge. For example, 12k participating")
        let participantCount = Utility.abbreviatedNumber(challenge.participantCount).formattedString
        let participatingText = NSLocalizedString("CHALLENGES_VIEW_CARD_PARTICIPATING_TEXT", comment: "Text for the number of people participating in a challenge.")
        participantCountText = String(format: participantCountFormat, arguments: [participantCount, participatingText])
        mainImageAsset = challenge.image
        communityImageAsset = challenge.community?.logo
        communityText = challenge.community?.name
        challengeInformationUpperText = ChallengeTableViewCellModel.makeAttributedStringFor(goalDescription: challenge.goalDescription)
        challengeInformationLowerText = ChallengeTableViewCellModel.makeAttributedStringFor(prizesDescription: challenge.prizeDescription ?? "") //FIXME: Peter Ryszkiewicz: Is this supposed to be optional?
        challengeInformationImage = nil //TODO: Fill in with an asset based on the state of the challenge
        progressMilestones = nil
    }
}

//MARK: - Static Helpers and Properties
extension ChallengeTableViewCellModel {
    private static let challengeInfoFontSize: CGFloat = 15.0

    private class func areDatesInSameYearAndMonth(startDate startDate: NSDate, endDate: NSDate?) -> Bool {
        guard let endDate = endDate else {
            return false
        }
        let calendar = NSCalendar.currentCalendar()
        let startDateComponents = calendar.components([.Year, .Month, .Day], fromDate: startDate)
        let endDateComponents = calendar.components([.Year, .Month, .Day], fromDate: endDate)
        return startDateComponents.year == endDateComponents.year && startDateComponents.month == endDateComponents.month
    }
    
    private class func getFormattedDateRangeFor(startDate startDate: NSDate, endDate: NSDate?) -> String {
        guard let endDate = endDate else {
            return NSLocalizedString("CHALLENGE_INVITATION_VIEW_DATE_RANGE_NO_END_DATE", comment: "Text to display on a challenge invitation if there is no end date.")
        }
        
        let startDateFormatter = NSDateFormatter.challengeCardStartDateFormatter
        
        let endDateFormatter: NSDateFormatter
        if areDatesInSameYearAndMonth(startDate: startDate, endDate: endDate) {
            endDateFormatter = NSDateFormatter.challengeCardEndDateNoMonthFormatter
        } else {
            endDateFormatter = NSDateFormatter.challengeCardEndDateFormatter
        }
        
        return String(
            format: NSLocalizedString("CHALLENGES_VIEW_CARD_INFORMATION_DATE_RANGE_FORMAT", comment: "Format for displaying a range of dates in the Challenge card, like startDate - endDate."),
            arguments: [startDateFormatter.stringFromDate(startDate), endDateFormatter.stringFromDate(endDate)]
        )
    }
    
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

//MARK: - Enums
extension ChallengeTableViewCellModel {
    enum State {
        case unjoinedAndUnderway
        case unjoinedAndNotUnderway
        case joinedAndUnderway
        case joinedAndNotUnderway
        case tabulatingResults
        case challengeComplete
        case cancelled
        
        init(withChallenge challenge: Challenge) {
            if challenge.status == .canceled {
                self = .cancelled
                return
            }
            if challenge.status == .finished {
                self = .challengeComplete
                return
            }
            if challenge.status == .calculating {
                self = .tabulatingResults
                return
            }
            if challenge.status == .running {
                if challenge.userRelation.status.isJoined {
                    self = .joinedAndUnderway
                    return
                }
                self = .unjoinedAndUnderway
                return
            }
            if challenge.userRelation.status.isJoined {
                self = .joinedAndNotUnderway
                return
            }
            self = .unjoinedAndNotUnderway
        }
    }
}