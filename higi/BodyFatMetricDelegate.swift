import Foundation

class BodyFatMetricDelegate : WeightMetricCard {
    
    override func getSelectedPoint() -> MetricCard.SelectedPoint {
        let date = Constants.displayDateFormatter.stringFromDate(selectedCheckin.dateTime);
        let weight = selectedCheckin.weightLbs != nil ? "\(Int(selectedCheckin.weightLbs!))" : "";
        let bodyFat = selectedCheckin.fatRatio != nil ? "\(Int(selectedCheckin.fatRatio!))" : "--";
        return MetricCard.SelectedPoint(date: date, firstPanelValue: weight, firstPanelLabel: "Weight", firstPanelUnit: "lbs", secondPanelValue: bodyFat, secondPanelLabel: "Body Fat", secondPanelUnit: "%")
    }
    
    override func getGraph(frame: CGRect) -> MetricGraph {
        return MetricGraphUtility.createWeightGraph(CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height));
    }
    
    override func getRanges() -> [MetricGauge.Range] {
        var ranges:[MetricGauge.Range] = [];
        if (selectedCheckin.bmi != nil) {
            let bmi = selectedCheckin.bmi!;
        }
        ranges.append(MetricGauge.Range(label: "Underweight", color: Utility.colorFromHexString("#fdd835"), interval: (0, 10)));
        ranges.append(MetricGauge.Range(label: "Normal", color: Utility.colorFromHexString("#88c681"), interval: (10, 20)));
        ranges.append(MetricGauge.Range(label: "Overweight", color: Utility.colorFromHexString("#f79a4d"), interval: (20, 30)));
        ranges.append(MetricGauge.Range(label: "Obese", color: Utility.colorFromHexString("#ef535a"), interval: (30, 40)));
        return ranges;
    }
}