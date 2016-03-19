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
            return Utility.colorFromHexString("#ba77ff");
        case Health:
            return Utility.colorFromHexString("#3acec7");
        case Lifestyle:
            return Utility.colorFromHexString("#fc3767");
        }
    }
    
    // TODO: l10n, refactor enum
    func getString() -> String {
        switch(self) {
        case Fitness:
            return "Fitness";
        case Health:
            return "Health";
        case Lifestyle:
            return "Lifestyle";
        }
    }
    
    static func categoryFromString(category: String) -> ActivityCategory {
        switch(category) {
        case "Health":
            return Health;
        case "Fitness":
            return Fitness;
        case "Lifestyle":
            return Lifestyle;
        default:
            return Lifestyle;
        }
    }
}