import Foundation

class NavigationObject {
    var title, icon:String, activeIcon:String
    
    var callback:(NSIndexPath) -> Void;
    
    
    init(title:String, icon:String, activeIcon:String, callback:(NSIndexPath) -> Void) {
        self.title = title;
        self.icon = icon;
        self.activeIcon = activeIcon;
        self.callback = callback;
    }

}