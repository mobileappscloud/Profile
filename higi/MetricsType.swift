enum MetricsType {
    case DailySummary
    case BloodPressure
    case Pulse
    case Weight
    case BodyMassIndex
    case BodyFat
    
    //@todo seems like it would take some work to be able to iterate
    //over enum, this will have to do for now
    static let allValues = [DailySummary, BloodPressure, Pulse, Weight, BodyMassIndex, BodyFat]
    
    static let allOldValues = [DailySummary, BloodPressure, Pulse, Weight]
    
    func getColor() -> UIColor {
        switch self {
        case BloodPressure:
            return Utility.colorFromHexString("#8379B5");
        case Weight:
            return Utility.colorFromHexString("#EE6C55");
        case Pulse:
            return Utility.colorFromHexString("#5FAFDF");
        case DailySummary:
            return Utility.colorFromHexString(Constants.higiGreen);
        default:
            return Utility.colorFromHexString("#FFFFFF");
        }
    }
    
    func getTitle() -> String {
        switch self {
        case BloodPressure:
            return NSLocalizedString("METRIC_TYPE_BLOOD_PRESSURE_TITLE", comment: "Title for blood pressure metrics");
        case Weight:
            return NSLocalizedString("METRIC_TYPE_WEIGHT_TITLE", comment: "Title for weight metrics");
        case Pulse:
            return NSLocalizedString("METRIC_TYPE_PULSE_TITLE", comment: "Title for pulse metrics");
        case DailySummary:
            return NSLocalizedString("METRIC_TYPE_DAILY_SUMMARY_TITLE", comment: "Title for daily summary metrics");
        default:
            return "";
        }
    }
}