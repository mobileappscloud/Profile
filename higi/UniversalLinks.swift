//
//  UniversalLinks.swift
//  higi
//
//  Created by Remy Panicker on 10/16/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import Foundation

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
    
    /// Collection of `PathType` objects where the relative path contains a resource `GUID`.
    private static let GUIDPaths: [PathType] = [.ChallengeDetail, .PulseArticle, .DailySummary];
}

public class UniversalLinks {
    
    /**
    Determines if a URL can be handled by the app.
    
    - parameter URL: Universal link to be handled.
    
    - returns: `true` if the app can handle the URL, otherwise `false`.
    */
    public class func canHandleURL(URL: NSURL) -> Bool {
        var canHandleURL = false;
        
        if let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: true), let host = components.host, let path = components.path {
            
            if self.canHandleHost(host) {
                let (pathType, _) = self.pathType(forPath: path);
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
    
    - parameter path: Relative path to evaluate.
    
    - returns: A tuple consisting of a `PathType` and `GUID`.
    */
    private class func pathType(forPath path: String) -> (pathType: PathType?, GUID: String?) {
        var pathType: PathType? = nil
        var guid: String? = nil
        
        if let fullPathType = PathType(rawValue: path) {
            pathType = fullPathType;
        } else {
            for currentPathType in PathType.GUIDPaths {
                var pathFormat = currentPathType.rawValue;
                pathFormat = pathFormat.stringByReplacingOccurrencesOfString("%@", withString: "");
                
                if let range = path.rangeOfString(pathFormat, options: .RegularExpressionSearch, range: nil, locale: nil) {
                    guid = path.substringFromIndex(range.endIndex);
                    pathType = currentPathType;
                    break;
                }
            }
        }
        
        return (pathType, guid);
    }
}
