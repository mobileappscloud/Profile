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
    let challengeStatusState: ChallengeStatusIndicatorView.State
    let dateText: String
    let participantCountText: String
    let mainImageView: UIImage
    let communityImage: UIImage
    let communityText: String
    let challengeInformationUpperText: NSAttributedString?
    let challengeInformationLowerText: NSAttributedString?
    let challengeInformationImage: UIImage?
    let showChallengeInformationStatus: Bool
    
    init(
        titleText: String,
        challengeStatusState: ChallengeStatusIndicatorView.State,
        dateText: String,
        participantCountText: String,
        mainImageView: UIImage,
        communityImage: UIImage,
        communityText: String,
        challengeInformationUpperText: NSAttributedString?,
        challengeInformationLowerText: NSAttributedString?,
        challengeInformationImage: UIImage?,
        showChallengeInformationStatus: Bool
    ) {
        self.titleText = titleText
        self.challengeStatusState = challengeStatusState
        self.dateText = dateText
        self.participantCountText = participantCountText
        self.mainImageView = mainImageView
        self.communityImage = communityImage
        self.communityText = communityText
        self.challengeInformationUpperText = challengeInformationUpperText
        self.challengeInformationLowerText = challengeInformationLowerText
        self.challengeInformationImage = challengeInformationImage
        self.showChallengeInformationStatus = showChallengeInformationStatus
    }
}