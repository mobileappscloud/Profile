//
//  NewChallengeUtility.swift
//  higi
//
//  Created by Remy Panicker on 8/22/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

// TODO: Rename to `ChallengeUtility` after removing legacy file.
/// Utility functions for challenges.
final class NewChallengeUtility {}

// MARK: - Challenge Date

extension NewChallengeUtility {
    
    private class func areDatesInSameYearAndMonth(startDate startDate: NSDate, endDate: NSDate?) -> Bool {
        guard let endDate = endDate else {
            return false
        }
        let calendar = NSCalendar.currentCalendar()
        let startDateComponents = calendar.components([.Year, .Month, .Day], fromDate: startDate)
        let endDateComponents = calendar.components([.Year, .Month, .Day], fromDate: endDate)
        return startDateComponents.year == endDateComponents.year && startDateComponents.month == endDateComponents.month
    }
    
    class func formattedDateRange(forStartDate startDate: NSDate, endDate: NSDate?) -> String {
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
        
        let format = NSLocalizedString("CHALLENGES_VIEW_CARD_INFORMATION_DATE_RANGE_FORMAT", comment: "Format for displaying a range of dates in the Challenge card, like startDate - endDate.")
        let formattedStartDate = startDateFormatter.stringFromDate(startDate)
        let formattedEndDate = endDateFormatter.stringFromDate(endDate)
        
        return String(format: format, arguments: [formattedStartDate, formattedEndDate])
    }
}

// MARK: - Participant Count

extension NewChallengeUtility {
    
    static func formattedParticipantCount(forParticipantCount participantCount: Int) -> String {
        let format = NSLocalizedString("CHALLENGES_VIEW_CARD_PARTICIPANT_COUNT_FORMAT", comment: "Format for the number of people participating in a challenge. For example, 12k participating")
        let formattedCount = Utility.abbreviatedNumber(participantCount).formattedString
        let units = NSLocalizedString("CHALLENGES_VIEW_CARD_PARTICIPATING_TEXT", comment: "Text for the number of people participating in a challenge.")
        return String(format: format, arguments: [formattedCount, units])
    }
}
