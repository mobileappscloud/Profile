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
    
    class var displayDateFormatter: NSDateFormatter {
        let formatter = NSDateFormatter();
        formatter.dateFormat = DISPLAY_DATE_FORMAT;
        return formatter;
    }
    
    class var higiGreen : String {
        return HIGI_GREEN;
    }
}

let KEY_DATE_FORMAT = "yyyyMMdd";

let DISPLAY_DATE_FORMAT = "MM/dd/yyyy";

let HIGI_GREEN = "#76C043";