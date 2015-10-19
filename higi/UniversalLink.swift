//
//  UniversalLink.swift
//  higi
//
//  Created by Remy Panicker on 10/16/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import Foundation
import UIKit

/**
Associated domains the app can handle URLs from.

- `Higi`:             The main higi domain.
- `HigiWebSubdomain`: The main higi domain with the World Wide Web subdomain.
*/
private enum AssociatedDomain: String {
    case Higi = "higi.com"
    case HigiWebSubdomain = "www.higi.com"
}

/**
URL paths which support universal linking.

- `ChallengeDetail`: Details for a specific challenge.
- `ChallengeDashboard`: Dashboard with overview of challenges.
- `StationLocator`: Map view with search function to find a station.
- `PulseHome`: List of higi Pulse articles.
- `PulseArticle`: View a specific higi Pulse article.
- `DailySummary`: Summary of a user's daily activity.
- `Metrics`: Overview of a user's health data.
- `MetricsBloodPressure`: Visualization of blood pressure data.
- `MetricsPulse`: Visualization of heart rate data.
- `MetricsWeight`: Visualization of body weight data.
- `ActivityList`: List of activities.
*/
private enum PathType: String {
    case ChallengeDetail = "/challenge/view/id/%@"
    case ChallengeDashboard = "/challenge/dashboard"
    case StationLocator = "/locator"
    case PulseHome = "/pulse"
    case PulseArticle = "/pulse/%@"
    case DailySummary = "/profile/checkin/%@"
    case Metrics = "/stats"
    case MetricsBloodPressure = "/stats/blood_pressure"
    case MetricsPulse = "/stats/pulse"
    case MetricsWeight = "/stats/weight"
    case ActivityList = "/activity/list"
}

public class UniversalLink {
    
    /**
    Determines if a URL can be handled by the app.
    
    - parameter URL: Universal link to be handled.
    
    - returns: `true` if the app can handle the URL, otherwise `false`.
    */
    public class func canHandleURL(URL: NSURL) -> Bool {
        var canHandleURL = false;
        
        if let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: true), let host = components.host {
            if self.canHandleHost(host) {
                let (pathType, _) = self.pathType(forURL: URL);
                canHandleURL = pathType != nil;
            }
        }
        
        return canHandleURL;
    }
    
    /**
    Determines if the `host` from a URL can be handled by the app.
    
    - parameter host: Host component for a URL.
    
    - returns: `true` if the host can be handled, otherwise `false`.
    */
    private class func canHandleHost(host: String) -> Bool {
        var canHandleHost = false;
        
        switch host {
        case AssociatedDomain.Higi.rawValue:
            fallthrough;
        case AssociatedDomain.HigiWebSubdomain.rawValue:
            canHandleHost = true;
        default:
            break;
        }
        
        return canHandleHost;
    }
    
    /**
    Determines the `PathType` for a given URL path and returns a `GUID` if applicable.
    
    - parameter URL: URL to evaluate.
    
    - returns: A tuple consisting of a `PathType` and `GUID`.
    */
    private class func pathType(forURL URL: NSURL) -> (pathType: PathType?, GUID: String?) {
        var pathType: PathType? = nil
        var guid: String? = nil
        
        if let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: true), let path = components.path {
            if let fullPathType = PathType(rawValue: path) {
                pathType = fullPathType;
            } else {
                if let pathComponents = URL.pathComponents {
                    switch pathComponents.count {
                    case 3:
                        switch (pathComponents[0], pathComponents[1], pathComponents[2]) {
                        case ("/", "pulse", let articleGUID):
                            pathType = .PulseArticle;
                            guid = articleGUID;
                        default:
                            break;
                        }
                    case 4:
                        switch (pathComponents[0], pathComponents[1], pathComponents[2], pathComponents[3]) {
                        case ("/", "profile", "checkin", let summaryGUID):
                            pathType = .DailySummary;
                            guid = summaryGUID;
                        default:
                            break;
                        }
                    case 5:
                        switch (pathComponents[0], pathComponents[1], pathComponents[2], pathComponents[3], pathComponents[4]) {
                        case ("/", "challenge", "view", "id", let challengeGUID):
                            pathType = .ChallengeDetail;
                            guid = challengeGUID;
                        default:
                            break;
                        }
                    default:
                        break;
                    }
                }
            }
        }
        
        return (pathType, guid);
    }
    
    /**
    Handles a compatible universal link. This method should only be called after calling
    `canHandleURL:` to ensure that the app is capable of continuing the user activity.
    
    - parameter URL: Universal link to be handled.
    */
    public class func handleURL(URL: NSURL) {
        let (pathType, guid) = self.pathType(forURL: URL);
        if pathType == nil {
            return;
        }
        
        switch pathType! {
        case .ChallengeDetail:
            print("wait")
            break;
        case .ChallengeDashboard:
            break;
        case .StationLocator:
            break;
        case .PulseHome:
            break;
        case .PulseArticle:
            print("wait")
            break;
        case .DailySummary:
            print("wait")
            break;
        case .Metrics:
            break;
        case .MetricsBloodPressure:
            break;
        case .MetricsPulse:
            break;
        case .MetricsWeight:
            break;
        case .ActivityList:
            break;
        }
        

        if let keyWindow = UIApplication.sharedApplication().keyWindow {
            if let rootViewController = keyWindow.rootViewController {
                switch rootViewController {
                case is DashboardViewController:
                    break;
                default:
                    break;
                }
            }
        }
    }
}
