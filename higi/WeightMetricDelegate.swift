import Foundation

final class WeightMetricDelegate: MetricDelegate {
    
    var selectedWeightCheckin, selectedFatCheckin: HigiCheckin!;

    var graph, secondaryGraph: MetricGraph!;
    
    var weightMode = true;
    
    func getTitle() -> String {
        return getType().getTitle();
    }
    
    func getColor() -> UIColor {
        return getType().getColor();
    }
    
    func getSecondaryColor() -> UIColor? {
        return Utility.colorFromHexString("#f7ada4");
    }

    func getType() -> MetricsType {
        return MetricsType.Weight;
    }

    func getBlankStateText() -> String {
        return NSLocalizedString("WEIGHT_METRICS_VIEW_BLANK_STATE_TEXT", comment: "Text to display on the weight metrics view if there are no weight readings to display.");
    }
    
    func setSelected(date: NSDate) {
        let selectedDate = date.timeIntervalSince1970;
        var minFatDifference = DBL_MAX, minWeightDifference = DBL_MAX;
        for checkin in Array(SessionController.Instance.checkins.reverse()) {
            let checkinTime = checkin.dateTime.timeIntervalSince1970;
            let difference = abs(checkinTime - selectedDate);
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
                secondaryGraph.symbolFromXValue(selectedFatCheckin.dateTime.timeIntervalSince1970);
            }
        } else {
            if graph != nil {
                graph.symbolFromXValue(selectedWeightCheckin.dateTime.timeIntervalSince1970);
            }
        }
    }

    func getSecondaryGraph(frame: CGRect, points: [GraphPoint], altPoints:[GraphPoint]) -> MetricGraph? {
        return MetricGraphUtility.graphWithPoints(CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), points: points, altPoints: altPoints, color:  getColor(), secondaryColor: getSecondaryColor());
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
                ranges.append(MetricGauge.Range(label: NSLocalizedString("WEIGHT_METRICS_WEIGHT_RANGE_UNDERWEIGHT_LABEL", comment: "Label for a weight which falls within an underweight range."), color: Utility.colorFromHexString("#fdd835"), interval: (factor * 10, factor * 18.5)));
                ranges.append(MetricGauge.Range(label: NSLocalizedString("WEIGHT_METRICS_WEIGHT_RANGE_NORMAL_LABEL", comment: "Label for a weight which falls within a normal range."), color: Utility.colorFromHexString("#88c681"), interval: (factor * 18.5, factor * 25)));
                ranges.append(MetricGauge.Range(label: NSLocalizedString("WEIGHT_METRICS_WEIGHT_RANGE_OVERWEIGHT_LABEL", comment: "Label for a weight which falls within an overweight range."), color: Utility.colorFromHexString("#f79a4d"), interval: (factor * 25, factor * 30)));
                ranges.append(MetricGauge.Range(label: NSLocalizedString("WEIGHT_METRICS_WEIGHT_RANGE_OBESE_LABEL", comment: "Label for a weight which falls within an obese range."), color: Utility.colorFromHexString("#ef535a"), interval: (factor * 30, factor * 50)));
            }
        } else {
            let healthyLabel = NSLocalizedString("WEIGHT_METRICS_WEIGHT_RANGE_HEALTHY_LABEL", comment: "Label for a weight which falls within a healthy range.")
            let acceptableLabel = NSLocalizedString("WEIGHT_METRICS_WEIGHT_RANGE_ACCEPTABLE_LABEL", comment: "Label for a weight which falls within an acceptable range.")
            let atRiskLabel = NSLocalizedString("WEIGHT_METRICS_WEIGHT_RANGE_AT_RISK_LABEL", comment: "Label for a weight which falls within an at-risk range.")
            if SessionData.Instance.user.biologicalSex == .Male {
                ranges.append(MetricGauge.Range(label: healthyLabel, color: Utility.colorFromHexString("#88c681"), interval: (5, 18)));
                ranges.append(MetricGauge.Range(label: acceptableLabel, color: Utility.colorFromHexString("#fdd835"), interval: (18, 25)));
                ranges.append(MetricGauge.Range(label: atRiskLabel, color: Utility.colorFromHexString("#f79a4d"), interval: (25, 40)));
            } else if SessionData.Instance.user.biologicalSex == .Female {
                ranges.append(MetricGauge.Range(label: healthyLabel, color: Utility.colorFromHexString("#88c681"), interval: (10, 25)));
                ranges.append(MetricGauge.Range(label: acceptableLabel, color: Utility.colorFromHexString("#fdd835"), interval: (25, 32)));
                ranges.append(MetricGauge.Range(label: atRiskLabel, color: Utility.colorFromHexString("#f79a4d"), interval: (32, 45)));
            }
        }
        return ranges;
    }
    
    func getSelectedValue(tab:Int) -> String {
        if tab == 1 && !weightMode {
            if selectedFatCheckin == nil {
                return "--";
            }
            return selectedFatCheckin.fatRatio != nil ? String(format: "%.2f", selectedFatCheckin.fatRatio!) + "%" : "--";
        } else {
            if selectedWeightCheckin == nil {
                return "--";
            }
            return selectedWeightCheckin.weightLbs != nil ? "\(Int(selectedWeightCheckin.weightLbs!))" : "--";
        }
    }
    
    func getSelectedUnit(tab: Int) -> String {
        if tab == 1 && !weightMode {
            return "";
        } else {
            return NSLocalizedString("GENERAL_PURPOSE_UNIT_LABEL_ABBR_WEIGHT_POUNDS", comment: "General purpose abbreviated label for the english units of weight measurement, pounds.");
        }
    }
    
    func getSelectedClass(tab: Int) -> String {
        if tab == 1 && !weightMode {
            if selectedFatCheckin != nil && selectedFatCheckin.fatClass != nil {
                return selectedFatCheckin.fatClass as! String;
            }
        } else {
            if selectedWeightCheckin != nil && selectedWeightCheckin.bmiClass != nil {
                return selectedWeightCheckin.bmiClass as! String;
            }
        }
        return "";
    }
    
    // TODO: l10n ....
    func colorFromClass(className: String, tab: Int) -> UIColor {
        var color: UIColor;
        switch (className) {
        case "Healthy":
            color = Utility.colorFromHexString("#88c681");
        case "Acceptable":
            color = Utility.colorFromHexString("#fdd835");
        case "At risk":
            color = Utility.colorFromHexString("#f79a4d");
        case "Underweight":
            color = Utility.colorFromHexString("#fdd835");
        case "Normal":
            color = Utility.colorFromHexString("#88c681");
        case "Overweight":
            color = Utility.colorFromHexString("#f79a4d");
        case "Obese":
            color = Utility.colorFromHexString("#ef535a");
        default:
            color = UIColor.whiteColor();
        }
        return color;
    }
    
    func shouldShowRegions() -> Bool {
        return true;
    }
    
    func togglePanel(weight: Bool) {
        weightMode = !weightMode;
    }
}