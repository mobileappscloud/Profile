enum MetricsType {
    case DailySummary
    case BloodPressure
    case Pulse
    case Weight
    
    //@todo seems like it would take some work to be able to iterate
    //over enum, this will have to do for now
    static let allValues = [DailySummary, BloodPressure, Pulse, Weight]
    
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
            return "Blood Pressure";
        case Weight:
            return "Weight";
        case Pulse:
            return "Pulse";
        case DailySummary:
            return "Points";
        default:
            return "";
        }
    }
}