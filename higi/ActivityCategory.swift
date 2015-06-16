enum ActivityCategory {
    case Fitness
    case Health
    case Lifestyle
    
    //@todo seems like it would take some work to be able to iterate
    //over enum, this will have to do for now
    static let allValues = [Fitness, Health, Lifestyle]
    
    func getColor() -> UIColor {
        switch(self) {
        case Fitness:
            return Utility.colorFromHexString("#3acec7")
        case Health:
            return Utility.colorFromHexString("#ba77ff");
        case Lifestyle:
            return Utility.colorFromHexString("#fc3767");
        default:
            return Utility.colorFromHexString("#FFFFFF");
        }
    }
    
    static func categoryFromString(category: String) -> ActivityCategory {
        switch(category) {
        case "checkin":
            return Health;
        case "steps":
            return Fitness;
        case "lifestyle":
            return Lifestyle;
        default:
            return Fitness;
        }
    }
}