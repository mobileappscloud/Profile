import Foundation

class WeightMetricDelegate: MetricDelegate {
    
    var selectedWeightCheckin, selectedFatCheckin: HigiCheckin!;

    var graph, secondaryGraph: MetricGraph!;
    
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
        let selectedDate = Utility.dateWithDateComponentOnly(date).timeIntervalSince1970;
        var minFatDifference = DBL_MAX, minWeightDifference = DBL_MAX;
        for checkin in SessionController.Instance.checkins.reverse() {
            let checkinDate = Utility.dateWithDateComponentOnly(checkin.dateTime).timeIntervalSince1970;
            let difference = abs(checkinDate - selectedDate);
            if difference < minWeightDifference {
                if checkin.weightLbs != nil && checkin.weightLbs > 0 {
                    minWeightDifference = difference;
                    selectedWeightCheckin = checkin;
                }
            }
            if difference < minFatDifference {
                if (checkin.fatRatio != nil && checkin.fatRatio > 0) {
                    minFatDifference = difference;
                    selectedFatCheckin = checkin;
                }
            }
            if (difference > minFatDifference && difference > minWeightDifference) {
                break;
            }
        }
        if weightMode {
            if secondaryGraph != nil {
                secondaryGraph.symbolFromXValue(Utility.dateWithDateComponentOnly(selectedFatCheckin.dateTime).timeIntervalSince1970);
            }
        } else {
            if graph != nil {
                graph.symbolFromXValue(Utility.dateWithDateComponentOnly(selectedWeightCheckin.dateTime).timeIntervalSince1970);
            }
        }
    }
    
    func getSelectedPoint() -> MetricCard.SelectedPoint? {
        if ((weightMode && selectedWeightCheckin == nil) || (!weightMode && selectedFatCheckin == nil)){
            return nil;
        } else {
            if weightMode {
                let weight = selectedWeightCheckin.weightLbs != nil ? "\(Int(selectedWeightCheckin.weightLbs!))" : "--";
                let date = Constants.displayDateFormatter.stringFromDate(selectedWeightCheckin.dateTime);
                return MetricCard.SelectedPoint(date: date, firstPanelValue: "", firstPanelLabel: "", firstPanelUnit: "", secondPanelValue: weight, secondPanelLabel: "Weight", secondPanelUnit: "lbs");
            } else {
                let date = Constants.displayDateFormatter.stringFromDate(selectedFatCheckin.dateTime);
                let weight = selectedFatCheckin.weightLbs != nil ? "\(Int(selectedFatCheckin.weightLbs!))" : "--";
                let bodyFat = selectedFatCheckin.fatRatio != nil ? String(format: "%.2f", selectedFatCheckin.fatRatio!) + "%" : "--";
                return MetricCard.SelectedPoint(date: date, firstPanelValue: weight, firstPanelLabel: "Weight", firstPanelUnit: "lbs", secondPanelValue: bodyFat, secondPanelLabel: "Body Fat", secondPanelUnit: "");
            }
        }
    }
    
    func getGraph(frame: CGRect) -> MetricGraph {
        graph = MetricGraphUtility.createWeightGraph(CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height));
        return graph;
    }
    
    func getSecondaryGraph(frame: CGRect) -> MetricGraph? {
        secondaryGraph = MetricGraphUtility.createBodyFatGraph(CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height));
        return secondaryGraph;
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
            } else if SessionData.Instance.user.gender == "f" {
                ranges.append(MetricGauge.Range(label: "Healthy", color: Utility.colorFromHexString("#88c681"), interval: (10, 25)));
                ranges.append(MetricGauge.Range(label: "Acceptable", color: Utility.colorFromHexString("#fdd835"), interval: (25, 32)));
                ranges.append(MetricGauge.Range(label: "At risk", color: Utility.colorFromHexString("#f79a4d"), interval: (32, 45)));
            }
        }
        return ranges;
    }
    
    func getSelectedValue(tab:Int) -> String {
        if tab == 1 && !weightMode {
            return selectedFatCheckin.fatRatio != nil ? String(format: "%.2f", selectedFatCheckin.fatRatio!) + "%" : "--";
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