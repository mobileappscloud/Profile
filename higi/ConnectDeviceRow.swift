import Foundation

class ConnectDeviceRow: UITableViewCell {

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var connectedToggle: UISwitch!
    @IBAction func deviceSwitchTouch(sender: UISwitch) {
        let connected = sender.on;
        if (connected) {
            connectDevice();
        } else {
            disconnectDevice();
        }
    }
    
    class func instanceFromNib(device: ActivityDevice) -> ConnectDeviceRow {
        let row = UINib(nibName: "ConnectDeviceRow", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ConnectDeviceRow;
        row.logo.setImageWithURL(Utility.loadImageFromUrl(device.iconUrl));
        row.name.text = device.name;
        row.connectedToggle.on = device.connected;
        
        return row;
    }
    
    func connectDevice() {
        let i = 0;
    }
    
    func disconnectDevice() {
        let i = 1;
    }
}