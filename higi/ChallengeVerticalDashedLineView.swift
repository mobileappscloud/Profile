//
//  ChallengeVerticalDashedLineView.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 9/23/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class ChallengeVerticalDashedLineView: ReusableXibView {
    private var dashedLineLayer: CAShapeLayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawDashedLineFor(view: self)
    }
    
    /// Draws a dashed line from the top left of the view to the bottom left of the view, and adds it to the view.
    func drawDashedLineFor(view view: UIView) {
        let dashedLinePath = UIBezierPath()
        dashedLinePath.moveToPoint(view.bounds.origin)
        dashedLinePath.addLineToPoint(CGPoint(x: view.bounds.origin.x, y: view.bounds.origin.y + view.bounds.height))
        let dashedLineLayer = CAShapeLayer()
        dashedLineLayer.path = dashedLinePath.CGPath
        dashedLineLayer.strokeColor = Theme.Color.Challenge.UserProgress.dashedLineColor.CGColor
        dashedLineLayer.lineWidth = 1.0
        dashedLineLayer.lineDashPattern = [5, 5]
        dashedLineLayer.contentsScale = view.contentScaleFactor
        self.dashedLineLayer?.removeFromSuperlayer()
        self.dashedLineLayer = dashedLineLayer
        view.layer.addSublayer(dashedLineLayer)
    }
}
