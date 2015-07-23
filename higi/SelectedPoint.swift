class SelectedPoint {
    
    var date:String!
    
    var firstPanel, secondPanel: Panel!;
    
    var kioskInfo: KioskInfo?;
    
    struct Panel {
        var value, label, unit: String!;
        
        init(value: String, label: String, unit:String) {
            self.value = value;
            self.label = label;
            self.unit = unit;
        }
    }
    
    init(date: String, panelValue: String, panelLabel: String, panelUnit: String, kioskInfo: KioskInfo?) {
        self.date = date;
        self.firstPanel = Panel(value: "", label: "", unit: "");
        self.secondPanel = Panel(value: panelValue, label: panelLabel, unit: panelUnit);
        self.kioskInfo = kioskInfo;
    }
    
    init(date: String, firstPanelValue: String, firstPanelLabel: String, firstPanelUnit: String, secondPanelValue: String, secondPanelLabel: String, secondPanelUnit: String, kioskInfo: KioskInfo?) {
        self.date = date;
        self.firstPanel = Panel(value: firstPanelValue, label: firstPanelLabel, unit: firstPanelUnit);
        self.secondPanel = Panel(value: secondPanelValue, label: secondPanelLabel, unit: secondPanelUnit);
        self.kioskInfo = kioskInfo;
    }
}