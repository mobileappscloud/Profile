import Foundation

class WeightMetricDelegate: MetricDelegate {
    
    var selectedWeightCheckin, selectedFatCheckin: HigiCheckin!;

    var weightMode = true;
    
    func getTitle() -> String {
        return getType().getTitle();
    }
    
    func getColor() -> UIColor {
        return getType().getColor();
    }
    
    func getIcon() -> UIImage {
        return Utility.imageWithColor(UIImage(named: "weighticon")!, color: UIColor.whiteColor());
    }
    
    func getType() -> MetricsType {
        return MetricsType.Weight;
    }
    
    func getCopyImage(tab: Int) -> UIImage? {
        if weightMode {
            return UIImage(named: "weight_overlay")!;
        } else {
            return UIImage(named: "bmi_overlay")!;
        }
    }
    
    func getBlankStateImage() -> UIImage {
        return UIImage(named: "weight_overlay")!;
    }
    
    func setSelected(date: NSDate) {
        let selectedDate = Double(Constants.dateFormatter.dateFromString(Constants.dateFormatter.stringFromDate(date))!.timeIntervalSince1970);
        var minDifference = DBL_MAX;
        for i in 0...SessionController.Instance.checkins.count - 1 {
            let checkin = SessionController.Instance.checkins[SessionController.Instance.checkins.count - i - 1];
            let checkinDate = Double(checkin.dateTime.timeIntervalSince1970);
            let difference = abs(checkinDate - selectedDate);
            if weightMode {
                if (difference < minDifference && (checkin.weightLbs != nil)) {
                    minDifference = difference;
                    selectedWeightCheckin = checkin;
                    if (selectedFatCheckin == nil && checkin.fatRatio != nil) {
                        selectedFatCheckin = checkin;
                    }
                }
            } else {
                if (difference < minDifference && (checkin.fatRatio != nil)) {
                    minDifference = difference;
                    selectedFatCheckin = checkin;
                }
            }
        }
    }
    
    func getSelectedPoint() -> MetricCard.SelectedPoint? {
        if ((weightMode && selectedWeightCheckin == nil) || (!weightMode && selectedFatCheckin == nil)){
            return nil;
        } else {
            let date = Constants.displayDateFormatter.stringFromDate(selectedWeightCheckin.dateTime);
            let weight = selectedWeightCheckin.weightLbs != nil ? "\(Int(selectedWeightCheckin.weightLbs!))" : "--";
            if weightMode {
                return MetricCard.SelectedPoint(date: date, firstPanelValue: "", firstPanelLabel: "", firstPanelUnit: "", secondPanelValue: weight, secondPanelLabel: "Weight", secondPanelUnit: "lbs");
            } else {
                let bodyFat = selectedFatCheckin.fatRatio != nil ? "\(selectedFatCheckin.fatRatio!)%" : "--";
                return MetricCard.SelectedPoint(date: date, firstPanelValue: weight, firstPanelLabel: "Weight", firstPanelUnit: "lbs", secondPanelValue: bodyFat, secondPanelLabel: "Body Fat", secondPanelUnit: "");
            }
        }
    }
    
    func getGraph(frame: CGRect) -> MetricGraph {
        return MetricGraphUtility.createWeightGraph(CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height));
    }
    
    func getSecondaryGraph(frame: CGRect) -> MetricGraph? {
        let graph = MetricGraphUtility.createBodyFatGraph(CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height));
        return graph;
    }
    
    func getRanges(tab:Int) -> [MetricGauge.Range] {
        var ranges:[MetricGauge.Range] = [];
        if (tab == 0 && !weightMode || weightMode) {
            if selectedWeightCheckin == nil {
                setSelected(NSDate());
                if selectedWeightCheckin == nil {
                    return [];
                }
            }
            if let height = selectedWeightCheckin.heightInches {
                let factor:Double = (height * height) / 703.0;
                ranges.append(MetricGauge.Range(label: "Underweight", color: Utility.colorFromHexString("#fdd835"), interval: (Int(factor * 10), Int(factor * 18.5))));
                ranges.append(MetricGauge.Range(label: "Normal", color: Utility.colorFromHexString("#88c681"), interval: (Int(factor * 18.5), Int(factor * 25))));
                ranges.append(MetricGauge.Range(label: "Overweight", color: Utility.colorFromHexString("#f79a4d"), interval: (Int(factor * 25), Int(factor * 30))));
                ranges.append(MetricGauge.Range(label: "Obese", color: Utility.colorFromHexString("#ef535a"), interval: (Int(factor * 30), Int(factor * 50))));
            }
        } else {
            if SessionData.Instance.user.gender == "m" {
                ranges.append(MetricGauge.Range(label: "Healthy", color: Utility.colorFromHexString("#88c681"), interval: (5, 18)));
                ranges.append(MetricGauge.Range(label: "Acceptable", color: Utility.colorFromHexString("#fdd835"), interval: (18, 25)));
                ranges.append(MetricGauge.Range(label: "At risk", color: Utility.colorFromHexString("#f79a4d"), interval: (25, 40)));
            } else {
                ranges.append(MetricGauge.Range(label: "Healthy", color: Utility.colorFromHexString("#88c681"), interval: (10, 25)));
                ranges.append(MetricGauge.Range(label: "Acceptable", color: Utility.colorFromHexString("#fdd835"), interval: (25, 32)));
                ranges.append(MetricGauge.Range(label: "At risk", color: Utility.colorFromHexString("#f79a4d"), interval: (32, 45)));
            }
        }
        return ranges;
    }
    
    func getSelectedValue(tab:Int) -> String {
        if tab == 1 && !weightMode {
            return selectedFatCheckin.fatRatio != nil ? "\(selectedFatCheckin.fatRatio!)%" : "--";
        } else {
            return selectedWeightCheckin.weightLbs != nil ? "\(Int(selectedWeightCheckin.weightLbs!))" : "--";
        }
    }
    
    func getSelectedUnit(tab: Int) -> String {
        if tab == 1 && !weightMode {
            return "";
        } else {
            return "lbs";
        }
    }
    
    func shouldShowRegions() -> Bool {
        return true;
    }
    
    func togglePanel(weight: Bool) {
        weightMode = !weightMode;
    }
}