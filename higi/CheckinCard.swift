//
//  CheckinCard.swift
//  higi
//
//  Created by Dan Harms on 8/13/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class CheckinCard: UIView, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var mapContainer: UIView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var dateTime: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var address2: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var checkin: HigiCheckin!;
    
    var closeCallback: ((checkinCard: UIView) -> Void)!;
    
    var selectionCallback: ((checkin: HigiCheckin, measure: Int) -> Void)!;
    
    func createTable(checkin: HigiCheckin, onClose: ((checkinCard: UIView) -> Void)!, onSelection: ((checkin: HigiCheckin, measure: Int) -> Void)!) {
        self.checkin = checkin;
        var modifiedName = "";
        if (checkin.kioskInfo != nil) {
            var kioskInfo = checkin.kioskInfo!;
            address.text = kioskInfo.address1 as String;
            address2.text = kioskInfo.cityStateZip as String;
            modifiedName = kioskInfo.organizations[0] as String;
            
        } else {
            modifiedName = checkin.sourceVendorId! as String;
        }
        modifiedName = modifiedName.stringByReplacingOccurrencesOfString(" ", withString: "_").stringByReplacingOccurrencesOfString("'", withString: "").stringByReplacingOccurrencesOfString("&", withString: "");
        var url = "https://webqa.superbuddytime.com/images/retailer-icons/\(modifiedName)_100.png";
        var imageRequest = NSMutableURLRequest(URL: NSURL(string: url)!);
        imageRequest.addValue("image/*", forHTTPHeaderField: "Accept");
        logo.setImageWithURLRequest(imageRequest, placeholderImage: nil, success: nil, failure: {request, response, error in
            
            self.address.frame.origin.x = 10;
            self.address2.frame.origin.x = 10;
        });
        var formatter = NSDateFormatter();
        formatter.dateFormat = "MMMM d, yyyy @ h:mma"
        var formattedString = formatter.stringFromDate(checkin.dateTime);
        dateTime.text = formattedString.stringByReplacingOccurrencesOfString("AM", withString: "a", options: nil, range: nil).stringByReplacingOccurrencesOfString("PM", withString: "p", options: nil, range: nil);
        closeCallback = onClose;
        selectionCallback = onSelection;
        tableView.frame.size.height = self.frame.size.height - 36;
    }
    
    @IBAction func closeCard(sender: AnyObject) {
        closeCallback(checkinCard: self);
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        Flurry.logEvent("CheckinCell_Pressed");
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        closeCallback(checkinCard: self);
        var measure = indexPath.item;
        if (checkin.bpClass == nil) {
            measure += 3;
        }
        selectionCallback(checkin: checkin, measure: measure);
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0;
        
        if (checkin.systolic != nil) {
            rows += 3;
        }
        
        if (checkin.bmi != nil) {
            rows += 2;
        }
        
        return rows;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell;
        switch(indexPath.item) {
        case 0:
            if (checkin.systolic != nil) {
                cell = createBpCell();
            } else {
                cell = createWeightCell();
            }
        case 1:
            if (checkin.systolic != nil) {
                cell = createPulseCell();
            } else {
                cell = createBmiCell();
            }
        case 2:
            cell = createMapCell();
        case 3:
            cell = createWeightCell();
        case 4:
            cell = createBmiCell();
        default:
            cell = UITableViewCell();
        }
        return cell;
    }
    
    func createBpCell() -> UITableViewCell {
        var cell = UINib(nibName: "BpCheckinCellView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! BpCheckinCell;
        cell.systolic.text = "\(checkin.systolic!)";
        cell.diastolic.text = "\(checkin.diastolic!)";
        cell.bpClass.text = checkin.bpClass! as String;
        if (checkin.prevBpCheckin != nil) {
            if (checkin.systolic! > checkin.prevBpCheckin!.systolic!) {
                cell.systolicArrow.image = UIImage(named: "graph_sincelastarrow_up_invert.png");
                cell.systolicChange.text = "\(checkin.systolic! - checkin.prevBpCheckin!.systolic!) mm Hg systolic"
            } else if (checkin.systolic! < checkin.prevBpCheckin!.systolic!) {
                cell.systolicArrow.image = UIImage(named: "graph_sincelastarrow_down_invert.png");
                cell.systolicChange.text = "\(checkin.prevBpCheckin!.systolic! - checkin.systolic!) mm Hg systolic";
            } else {
                cell.systolicArrow.image = UIImage(named: "graph_sincelastarrow_nochange_invert.png");
                cell.systolicChange.text = "No change";
            }
            if (checkin.diastolic! > checkin.prevBpCheckin!.diastolic!) {
                cell.diastolicArrow.image = UIImage(named: "graph_sincelastarrow_up_invert.png");
                cell.diastolicChange.text = "\(checkin.diastolic! - checkin.prevBpCheckin!.diastolic!) mm Hg diastolic"
            } else if (checkin.diastolic! < checkin.prevBpCheckin!.diastolic!) {
                cell.diastolicArrow.image = UIImage(named: "graph_sincelastarrow_down_invert.png");
                cell.diastolicChange.text = "\(checkin.prevBpCheckin!.diastolic! - checkin.diastolic!) mm Hg diastolic";
            } else {
                cell.diastolicArrow.image = UIImage(named: "graph_sincelastarrow_nochange_invert.png");
                cell.diastolicChange.text = "No change";
            }
        } else {
            cell.systolicArrow.image = UIImage(named: "graph_sincelastarrow_nochange_invert.png");
            cell.systolicChange.text = "No change";
            cell.diastolicArrow.image = UIImage(named: "graph_sincelastarrow_nochange_invert.png");
            cell.diastolicChange.text = "No change";

        }
        if (checkin.bpClass! == "At Risk") {
            cell.gauge.image = UIImage(named: "gauge2_atrisk.png");
        } else if (checkin.bpClass! == "High") {
            cell.gauge.image = UIImage(named: "gauge2_high.png");
        } else {
            cell.gauge.image = UIImage(named: "gauge2_normal.png");
        }
        return cell;
    }
    
    func createPulseCell() -> UITableViewCell {
        var cell = UINib(nibName: "CheckinCellView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! CheckinCell;
        cell.title.text = "Pulse";
        cell.title.frame = CGRect(x: 10, y: 15, width: 142, height: 60);
        cell.measure.text = "\(checkin.pulseBpm!)";
        cell.measureClass.text = checkin.pulseClass! as String;
        cell.icon.image = UIImage(named: "vital_pulse_icon.png");
        if (checkin.prevBpCheckin != nil) {
            if (checkin.pulseBpm! > checkin.prevBpCheckin!.pulseBpm!) {
                cell.arrow.image = UIImage(named: "graph_sincelastarrow_up_invert.png");
                cell.change.text = "\(checkin.pulseBpm! - checkin.prevBpCheckin!.pulseBpm!) bpm";
            } else if (checkin.pulseBpm! < checkin.prevBpCheckin!.pulseBpm!) {
                cell.arrow.image = UIImage(named: "graph_sincelastarrow_down_invert.png");
                cell.change.text = "\(checkin.prevBpCheckin!.pulseBpm! - checkin.pulseBpm!) bpm";
            } else {
                cell.arrow.image = UIImage(named: "graph_sincelastarrow_nochange_invert.png");
                cell.change.text = "No change";
            }
        } else {
            cell.arrow.image = UIImage(named: "graph_sincelastarrow_nochange_invert.png");
            cell.change.text = "No change";
        }
        if (checkin.pulseClass! == "Low") {
            cell.gauge.image = UIImage(named: "gauge1_low.png");
        } else if (checkin.pulseClass! == "High") {
            cell.gauge.image = UIImage(named: "gauge1_high.png");
        } else {
            cell.gauge.image = UIImage(named: "gauge1_normal.png");
        }
        return cell;
    }
    
    func createMapCell() -> UITableViewCell {
        var cell = UINib(nibName: "TwoLineCheckinCellView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! CheckinCell;
        cell.title.text = "Mean Arterial Pressure";
        cell.title.sizeToFit();
        cell.measure.text = String(format: "%.1f", checkin.map!);
        cell.measureClass.text = checkin.bpClass! as String;
        cell.icon.image = UIImage(named: "vital_map_icon.png");
        if (checkin.prevBpCheckin != nil) {
            if (checkin.map! > checkin.prevBpCheckin!.map!) {
                cell.arrow.image = UIImage(named: "graph_sincelastarrow_up_invert.png");
                cell.change.text = String(format: "%01.1f mm Hg", checkin.map! - checkin.prevBpCheckin!.map!);
            } else if (checkin.map! < checkin.prevBpCheckin!.map!) {
                cell.arrow.image = UIImage(named: "graph_sincelastarrow_down_invert.png");
                cell.change.text = String(format: "%01.1f mm Hg", checkin.prevBpCheckin!.map! - checkin.map!);
            } else {
                cell.arrow.image = UIImage(named: "graph_sincelastarrow_nochange_invert.png");
                cell.change.text = "No change";
            }
        } else {
            cell.arrow.image = UIImage(named: "graph_sincelastarrow_nochange_invert.png");
            cell.change.text = "No change";
        }
        if (checkin.bpClass! == "At Risk") {
            cell.gauge.image = UIImage(named: "gauge2_atrisk.png");
        } else if (checkin.bpClass! == "High") {
            cell.gauge.image = UIImage(named: "gauge2_high.png");
        } else {
            cell.gauge.image = UIImage(named: "gauge2_normal.png");
        }
        return cell;
    }
    
    func createWeightCell() -> UITableViewCell {
        var cell = UINib(nibName: "CheckinCellView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! CheckinCell;
        cell.title.text = "Weight";
        cell.title.sizeToFit();
        cell.icon.image = UIImage(named: "vital_weight_icon.png");
        cell.measure.text = "\(Int(checkin.weightLbs!))";
        cell.measureClass.text = checkin.bmiClass! as String;
        if (checkin.prevBmiCheckin != nil) {
            if (checkin.weightLbs! > checkin.prevBmiCheckin!.weightLbs!) {
                cell.arrow.image = UIImage(named: "graph_sincelastarrow_up_invert.png");
                cell.change.text = "\(Int(checkin.weightLbs! - checkin.prevBmiCheckin!.weightLbs!)) lbs";
            } else if (checkin.weightLbs! < checkin.prevBmiCheckin!.weightLbs!) {
                cell.arrow.image = UIImage(named: "graph_sincelastarrow_down_invert.png");
                cell.change.text = "\(Int(checkin.prevBmiCheckin!.weightLbs! - checkin.weightLbs!)) lbs";
            } else {
                cell.arrow.image = UIImage(named: "graph_sincelastarrow_nochange_invert.png");
                cell.change.text = "No change";
            }
        } else {
            cell.arrow.image = UIImage(named: "graph_sincelastarrow_nochange_invert.png");
            cell.change.text = "No change";
        }
        if (checkin.bmiClass! == "Underweight") {
            cell.gauge.image = UIImage(named: "gauge3_underweight.png");
        } else if (checkin.bmiClass! == "Overweight") {
            cell.gauge.image = UIImage(named: "gauge3_overweight.png");
        } else if (checkin.bmiClass! == "Obese") {
            cell.gauge.image = UIImage(named: "gauge3_obese.png");
        } else {
            cell.gauge.image = UIImage(named: "gauge3_normal.png");
        }
        return cell;
    }
    
    func createBmiCell() -> UITableViewCell {
        var cell = UINib(nibName: "TwoLineCheckinCellView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! CheckinCell;
        cell.title.text = "Body Mass Index";
        cell.title.sizeToFit();
        cell.icon.image = UIImage(named: "vital_bmi_icon.png");
        cell.measure.text = String(format: "%.2f", checkin.bmi!);
        cell.measureClass.text = checkin.bmiClass! as String;
        if (checkin.prevBmiCheckin != nil) {
            if (checkin.bmi! > checkin.prevBmiCheckin!.bmi!) {
                cell.arrow.image = UIImage(named: "graph_sincelastarrow_up_invert.png");
                cell.change.text = String(format: "%01.2f", checkin.bmi! - checkin.prevBmiCheckin!.bmi!);
            } else if (checkin.bmi! < checkin.prevBmiCheckin!.bmi!) {
                cell.arrow.image = UIImage(named: "graph_sincelastarrow_down_invert.png");
                cell.change.text = String(format: "%01.2f", checkin.prevBmiCheckin!.bmi! - checkin.bmi!);
            } else {
                cell.arrow.image = UIImage(named: "graph_sincelastarrow_nochange_invert.png");
                cell.change.text = "No change";
            }
        } else {
            cell.arrow.image = UIImage(named: "graph_sincelastarrow_nochange_invert.png");
            cell.change.text = "No change";
        }
        if (checkin.bmiClass! == "Overweight") {
            cell.gauge.image = UIImage(named: "gauge3_underweight.png");
        } else if (checkin.bmiClass! == "Overweight") {
            cell.gauge.image = UIImage(named: "gauge3_overweight.png");
        } else if (checkin.bmiClass! == "Obese") {
            cell.gauge.image = UIImage(named: "gauge3_obese.png");
        } else {
            cell.gauge.image = UIImage(named: "gauge3_normal.png");
        }
        return cell;
    }
    
    func setupMap() {
        if (checkin.kioskInfo != nil) {
            var kioskInfo = checkin.kioskInfo!;
            var camera = GMSCameraPosition.cameraWithLatitude(kioskInfo.latitude!, longitude: kioskInfo.longitude!, zoom: 14);
            var mapView = GMSMapView.mapWithFrame(mapContainer.frame, camera: camera);
            mapView.userInteractionEnabled = false;
            var icon = Utility.scaleImage(UIImage(named: "mapicon_higicard")!, newSize: CGSize(width: 45, height: 45));
            var marker = GMSMarker(position: kioskInfo.position!);
            marker.icon = icon;
            marker.map = mapView;
            mapContainer.addSubview(mapView);
        }
    }
}