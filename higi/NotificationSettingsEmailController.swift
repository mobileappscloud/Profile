
//
//  NotificationSettingsEmailController.swift
//  higi
//
//  Created by Remy Panicker on 9/23/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import UIKit

public enum EmailNotification: String {
    case CheckInResult = "EmailCheckins"
    case HigiNews = "EmailHigiNews"
    
    func isEnabled() -> Bool {
        let user = SessionData.Instance.user;

        var enabled = true;
        switch self {
        case .CheckInResult:
            enabled = user.emailCheckins;
        case .HigiNews:
            enabled = user.emailHigiNews;
        }
        return enabled;
    }
}

class NotificationSettingsEmailController: NSObject {

    let user = SessionData.Instance.user;
    
    func updateNotification(notification: EmailNotification, value: Bool, completion: (Bool -> Void)?) {
        let contents = NSMutableDictionary();
        let notifications = NSMutableDictionary();
        notifications.setObject(value ? "True" : "False", forKey: notification.rawValue);
        contents.setObject(notifications, forKey: "Notifications");
        
        updateUserNotification(notification, value: value);
        
        let URL = "\(HigiApi.higiApiUrl)/data/user/\(user.userId)";
        HigiApi().sendPost(URL, parameters: contents, success: { (operation, response) in
            if let _ = completion {
                completion!(true);
            }
        }, failure: { [weak self] (operation, error) in
            self?.updateUserNotification(notification, value: !value)
            if let _ = completion {
                completion!(false);
            }
        });
    }
    
    private func updateUserNotification(notification: EmailNotification, value: Bool) {
        switch notification {
        case .CheckInResult:
            user.emailCheckins = value;
        case .HigiNews:
            user.emailHigiNews = value;
        }
    }
}
