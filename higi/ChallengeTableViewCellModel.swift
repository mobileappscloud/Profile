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

    var isChallengeJoinable: Bool {
        return challengeStatusState.isJoinable
    }
    
    init(challenge: Challenge) {
        titleText = challenge.name
        challengeStatusState = State(withChallenge: challenge)
        dateText = ChallengeTableViewCellModel.getFormattedDateRangeFor(startDate: challenge.startDate, endDate: challenge.endDate)
        participantCountText = "\(challenge.participantCount) \(NSLocalizedString("CHALLENGES_VIEW_CARD_PARTICIPATING_TEXT", comment: "Text for the number of people participating in a challenge."))"
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
        
        return "\(startDateFormatter.stringFromDate(startDate)) - \(endDateFormatter.stringFromDate(endDate))"
    }
    
    private class func makeAttributedStringFor(goalDescription goalDescriptionString: String) -> NSAttributedString {
        let goalString = "\(NSLocalizedString("CHALLENGES_VIEW_CARD_INFORMATION_GOAL_TEXT", comment: "Text for Goal on the challenge card information view.")): "
        return makeAttributedStringFor(title: goalString, description:  goalDescriptionString)
    }
    
    private class func makeAttributedStringFor(prizesDescription prizesDescriptionString: String) -> NSAttributedString {
        let prizesString = "\(NSLocalizedString("CHALLENGES_VIEW_CARD_INFORMATION_PRIZES_TEXT", comment: "Text for Prizes on the challenge card information view.")): "
        return makeAttributedStringFor(title: prizesString, description:  prizesDescriptionString)
    }
    
    private class func makeAttributedStringFor(title titleString: String, description descriptionString: String) -> NSAttributedString {
        let entireAttributedString = NSMutableAttributedString(string: titleString, attributes: [
            NSFontAttributeName: UIFont.boldSystemFontOfSize(challengeInfoFontSize)
        ])
        
        entireAttributedString.appendAttributedString(NSMutableAttributedString(string: descriptionString, attributes: [
            NSFontAttributeName: UIFont.systemFontOfSize(challengeInfoFontSize)
        ]))
        
        return entireAttributedString
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
        
        var isJoinable: Bool {
            switch self {
                case .unjoinedAndUnderway, .unjoinedAndNotUnderway: return true
                default: return false
            }
        }
    }
}