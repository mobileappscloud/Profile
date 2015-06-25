import Foundation

class SummaryViewUtility {
    
    class func sortByPoints(this: HigiActivity, that: HigiActivity) -> Bool {
        return this.points >= that.points;
    }
    
    class func initBreakdownRow(originX: CGFloat, originY: CGFloat, text: String, duplicate: Bool) -> DailySummaryBreakdown {
        let breakdownRow = UINib(nibName: "DailySummaryBreakdownView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! DailySummaryBreakdown;
        breakdownRow.frame.origin.y = originY;
        breakdownRow.frame.origin.x = originX;
        breakdownRow.desc.text = text;
        if (duplicate) {
            breakdownRow.desc.textColor = UIColor.lightGrayColor();
        }
        return breakdownRow;
    }
    
    class func initTitleRow(originX: CGFloat, originY: CGFloat, width: CGFloat, points: Int, device: String, color: UIColor) -> BreakdownTitleRow {
        let titleRow = UINib(nibName: "BreakdownTitleRowView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! BreakdownTitleRow;
        titleRow.frame.origin.x = originX;
        titleRow.frame.origin.y = originY;
        titleRow.frame.size.width = width;
        titleRow.points.text = "\(points)";
        titleRow.device.text = device;
        titleRow.points.textColor = color;
        return titleRow;
    }
    
    class func initDuplicateLabel(originX: CGFloat, originY: CGFloat, width: CGFloat, text: String) -> UILabel {
        let labelHeight:CGFloat = 20;
        let label = UILabel(frame: CGRect(x: originX, y: originY, width: width, height: labelHeight));
        label.text = text;
        label.textColor = UIColor.lightGrayColor();
        label.font = UIFont.italicSystemFontOfSize(15);
        return label;
    }
}