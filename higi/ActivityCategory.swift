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
    
    func getString() -> String {
        switch(self) {
        case Fitness:
            return "Fitness";
        case Health:
            return "Health";
        case Lifestyle:
            return "Lifestyle";
        default:
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
    
    static func categoryFromActivity(activity: HigiActivity) -> ActivityCategory {
        if (activity.category == "checkin") {
            if (activity.checkinCategory == "health") {
                return Health;
            } else if (activity.checkinCategory == "lifestyle") {
                return Lifestyle;
            }
        } else {
            return Fitness;
        }
        return Lifestyle;
    }
}