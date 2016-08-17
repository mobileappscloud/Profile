//
//  NotificationSettingsDeviceTableViewController.swift
//  higi
//
//  Created by Remy Panicker on 9/15/15.
//  Copyright (c) 2015 higi, LLC. All rights reserved.
//

import UIKit

private enum TableSection: Int {
    case GlobalSetting
    case UniqueSetting
    case _count
}

private enum SectionGlobalSettingRow: Int {
    case AllowNotifications
    case _count
}

private enum SectionUniqueSettingRow: Int {
    case StationNearby
    case _count
}

final class NotificationSettingsDeviceTableViewController: UITableViewController, SwitchTableViewCellDelegate {

    let switchCellReuseIdentifier = "SwitchCellReuseIdentifier";
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("NOTIFICATION_SETTINGS_DEVICE_VIEW_TITLE", comment: "Title for device-specific notification settings view.")
        
        configureTableView();
    }
    
    // MARK: Configuration
    
    private func configureTableView() {
        tableView.registerClass(SwitchTableViewCell.self, forCellReuseIdentifier: switchCellReuseIdentifier);
    }

    // MARK: - Settings
    
    private func shouldSendNotifications() -> Bool {
        return PersistentSettingsController.boolForKey(.EnableNotifications);
    }
    
    private func shouldSendStationNearbyNotifications() -> Bool {
        return PersistentSettingsController.boolForKey(.StationNearbyNotification);
    }
    
    private func switchValueForIndexPath(indexPath: NSIndexPath) -> Bool {
        var value = false;
        
        if let section = TableSection(rawValue: indexPath.section) {
            switch section {
            case .GlobalSetting:
                if let row = SectionGlobalSettingRow(rawValue: indexPath.row) {
                    switch row {
                    case .AllowNotifications:
                        value = shouldSendNotifications();
                    default:
                        break;
                    }
                }
                
            case .UniqueSetting:
                if let row = SectionUniqueSettingRow(rawValue: indexPath.row) {
                    switch row {
                    case .StationNearby:
                        value = shouldSendStationNearbyNotifications();
                    default:
                        break;
                    }
                }
                
            default:
                break;
            }
        }
        
        return value;
    }
    
    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return shouldSendNotifications() ? TableSection._count.rawValue : 1;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount: Int! = 0;
        if let tableSection = TableSection(rawValue: section) {
            switch tableSection {
            case .GlobalSetting:
                rowCount = SectionGlobalSettingRow._count.rawValue;
            case .UniqueSetting:
                rowCount = SectionUniqueSettingRow._count.rawValue;
            default:
                break;
            }
        }
        return rowCount;
    }
        
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell();

        if let tableSection = TableSection(rawValue: indexPath.section) {
            let switchCell = tableView.dequeueReusableCellWithIdentifier(switchCellReuseIdentifier, forIndexPath: indexPath) as! SwitchTableViewCell;
            
            switchCell.delegate = self;
            switchCell.switchControl.on = switchValueForIndexPath(indexPath);
            
            switch tableSection {
            case .GlobalSetting:
                if let row = SectionGlobalSettingRow(rawValue: indexPath.row) {
                    switch row {
                    case .AllowNotifications:
                        switchCell.textLabel!.text = NSLocalizedString("NOTIFICATION_SETTINGS_DEVICE_ALLOW_NOTIFICATIONS_CELL_TITLE", comment: "Title for cell to allow all notifications.")
                    default:
                        break;
                    }
                }
                
            case .UniqueSetting:
                if let row = SectionUniqueSettingRow(rawValue: indexPath.row) {
                    switch row {
                    case .StationNearby:
                        switchCell.textLabel!.text = NSLocalizedString("NOTIFICATION_SETTINGS_DEVICE_STATION_NEARBY_CELL_TITLE", comment: "Title for cell to allow nearby station notifications.")
                    default:
                        break;
                    }
                }
                
            default:
                break;
            }

            cell = switchCell;
        }
        
        return cell;
    }
    
    // MARK: - Switch Cell Delegate
    
    func valueDidChangeForSwitchCell(cell: SwitchTableViewCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            updateValueForNotificationSettingAtIndexPath(indexPath, value: cell.switchControl.on);
            
            if (indexPath.section == TableSection.GlobalSetting.rawValue && indexPath.row == SectionGlobalSettingRow.AllowNotifications.rawValue) {
                self.tableView.beginUpdates();
             
                let indexSet = NSIndexSet(index: TableSection.UniqueSetting.rawValue)
                
                if (cell.switchControl.on) {
                    self.tableView.insertSections(indexSet, withRowAnimation: .Bottom)
                } else {
                    self.tableView.deleteSections(indexSet, withRowAnimation: .Top)
                }

                self.tableView.endUpdates();
            }
        };
    }
    
    private func updateValueForNotificationSettingAtIndexPath(indexPath: NSIndexPath, value: Bool) {
        var key: PersistentSetting = .Unknown;
        
        if let tableSection = TableSection(rawValue: indexPath.section) {
            switch tableSection {
            case .GlobalSetting:
                if let row = SectionGlobalSettingRow(rawValue: indexPath.row) {
                    switch row {
                    case .AllowNotifications:
                        key = .EnableNotifications;
                    default:
                        break;
                    }
                }
            case .UniqueSetting:
                if let row = SectionUniqueSettingRow(rawValue: indexPath.row) {
                    switch row {
                    case .StationNearby:
                        key = .StationNearbyNotification;
                    default:
                        break;
                    }
                }
            default:
                break
            }
        }
        
        PersistentSettingsController.setBool(value, key: key);
    }
}
