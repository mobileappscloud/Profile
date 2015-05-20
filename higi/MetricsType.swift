enum MetricsType {
    case DailySummary
    case BloodPressure
    case Pulse
    case Weight
    
    //@todo seems like it would take some work to be able to iterate
    //over enum, this will have to do for now
    static let allValues = [DailySummary, BloodPressure, Pulse, Weight]
}