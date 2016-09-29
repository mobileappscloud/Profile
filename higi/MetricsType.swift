enum MetricsType {
    case watts
    case bloodPressure
    case pulse
    case weight
    case bodyMassIndex
    case bodyFat
    
    //@todo seems like it would take some work to be able to iterate
    //over enum, this will have to do for now
    static let allValues = [watts, bloodPressure, pulse, weight, bodyMassIndex, bodyFat]
    
    static let allOldValues = [watts, bloodPressure, pulse, weight]
    
    func getColor() -> UIColor {
        switch self {
        case bloodPressure:
            return Utility.colorFromHexString("#8379B5");
        case weight:
            return Utility.colorFromHexString("#EE6C55");
        case pulse:
            return Utility.colorFromHexString("#5FAFDF");
        case watts:
            return Theme.Color.primary;
        default:
            return Utility.colorFromHexString("#FFFFFF");
        }
    }
    
    func getTitle() -> String {
        switch self {
        case bloodPressure:
            return NSLocalizedString("METRIC_TYPE_BLOOD_PRESSURE_TITLE", comment: "Title for blood pressure metrics");
        case weight:
            return NSLocalizedString("METRIC_TYPE_WEIGHT_TITLE", comment: "Title for weight metrics");
        case pulse:
            return NSLocalizedString("METRIC_TYPE_PULSE_TITLE", comment: "Title for pulse metrics");
        case watts:
            return NSLocalizedString("METRIC_TYPE_DAILY_SUMMARY_TITLE", comment: "Title for daily summary metrics");
        default:
            return "";
        }
    }
}