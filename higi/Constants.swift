import Foundation

class Constants {
    class var dateFormat: String {
        return KEY_DATE_FORMAT;
    }
    
    class var dateFormatter: NSDateFormatter {
        let formatter = NSDateFormatter();
        formatter.dateFormat = KEY_DATE_FORMAT;
        return formatter;
    }
}

let KEY_DATE_FORMAT = "yyyyMMdd";