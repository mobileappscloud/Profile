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
    
    static let parameterToken = "%@"
    
    static let tokenizedPaths: [PathType] = [.ChallengeDetail, .PulseArticle, .DailySummary]
    
    static func handler(forPathType pathType: PathType) -> UniversalLinkHandler? {
        var handler: UniversalLinkHandler? = nil
        
        switch pathType {
        case .ChallengeDetail:
            handler = ChallengeDetailsViewController()
            
        case .ChallengeDashboard:
            handler = ChallengesViewController()
            
        case .StationLocator:
            handler = FindStationViewController()
            
        case .PulseHome:
            fallthrough;
        case .PulseArticle:
            handler = PulseHomeViewController()
            
        case .DailySummary:
            handler = DailySummaryViewController()
            
        case .MetricsBloodPressure:
            fallthrough;
        case .MetricsPulse:
            fallthrough;
        case .MetricsWeight:
            fallthrough;
        case .Metrics:
            handler = MetricsViewController()
            
        case .ActivityList:
            handler = DailySummaryViewController()
        }
        
        return handler;
    }
}

public class UniversalLink {
    
    // MARK: URL Parsing
    
    /**
    Determines if a URL can be handled by the app.
    
    - parameter URL: Universal link to be handled.
    
    - returns: `true` if the app can handle the URL, otherwise `false`.
    */
    public class func canHandleURL(URL: NSURL) -> Bool {
        var canHandleURL = false;
        
        if let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: true), let host = components.host {
            if self.canHandleHost(host) {
                let (pathType, _) = self.parsePath(forURL: URL);
                canHandleURL = pathType != nil;
            }
        }
        
        return canHandleURL;
    }
    
    private class func canHandleHost(host: String) -> Bool {
        var canHandleHost = false;
        
        if let _ = AssociatedDomain(rawValue: host) {
            canHandleHost = true;
        }
        
        return canHandleHost;
    }
    
    private class func parsePath(forURL URL: NSURL) -> (pathType: PathType?, parameters: [String]?) {
        var pathType: PathType? = nil
        var parameters: [String]? = nil
        
        if let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: true), let path = components.path {
            if let fullPathType = PathType(rawValue: path) {
                pathType = fullPathType;
            } else {
                if var pathComponents = URL.pathComponents {
                    var canHandlePath: Bool = false;
                    // The first path component can be ignored because it is just a forward slash ('/')
                    pathComponents.removeFirst()
                    
                    for tokenizedPathType in PathType.tokenizedPaths {
                        var targetPathComponents = tokenizedPathType.rawValue.componentsSeparatedByString("/")
                        // Remove the first component in the target because similar to the source, the first component can be ignored
                        targetPathComponents.removeFirst()
                        
                        (canHandlePath, parameters) = matchPathComponents(targetPathComponents, sourcePathComponenets: pathComponents)
                        if canHandlePath {
                            pathType = tokenizedPathType;
                            break;
                        }
                    }

                }
            }
        }
        
        return (pathType, parameters);
    }
    
    private class func matchPathComponents(targetPathComponents: [String], sourcePathComponenets: [String]) -> (didMatchComponents: Bool, parameters: [String]?) {
        if targetPathComponents.count != sourcePathComponenets.count {
            return (false, nil);
        }
        
        var componentsMatch: Bool? = nil;
        var parameters: [String]? = [];
        
        for index in 0...targetPathComponents.count-1 {
            if targetPathComponents[index] == PathType.parameterToken {
                parameters?.append(sourcePathComponenets[index])
            } else if targetPathComponents[index] != sourcePathComponenets[index] {
                parameters = nil;
                componentsMatch = false;
                break;
            }
        }
        
        componentsMatch = componentsMatch ?? true;
        
        return (componentsMatch!, parameters);
    }
}

public extension UniversalLink {
    /**
    Handles a compatible universal link. This method should only be called after calling
    `canHandleURL:` to ensure that the app is capable of continuing the user activity.
    
    - parameter URL: Universal link to be handled.
    */
    public class func handleURL(URL: NSURL) {
        let (pathType, parameters) = self.parsePath(forURL: URL);
        if pathType == nil {
            return;
        }
        
        
        let handler: UniversalLinkHandler? = PathType.handler(forPathType: pathType!)
        handler?.handleUniversalLink(URL, parameters: parameters)
    }
}

public extension UniversalLink {
    /**
    Convenience method which traverses the view hierarchy to find the main navigation controller.
    
    - returns: A reference to the `MainNavigationController`.
    */
    internal class func mainNavigationController() -> MainNavigationController? {
        var navigationController: MainNavigationController? = nil
        
        if let keyWindow = UIApplication.sharedApplication().keyWindow {
            if let rootViewController = keyWindow.rootViewController as? RevealViewController {

                for child in rootViewController.childViewControllers {
                    if child is MainNavigationController {
                        navigationController = child as? MainNavigationController
                        break;
                    }
                }
            }
        }
        
        return navigationController;
    }
}

/**
Protocol definition for higi universal link handlers.
*/
public protocol UniversalLinkHandler {
    /**
    Protocol method for handling a universal link.
    
    - parameter URL:        URL of a compatible universal link.
    - parameter parameters: URL parameters such as resource GUIDs if applicable, otherwise nil.
    */
   func handleUniversalLink(URL: NSURL, parameters: [String]?);
}
