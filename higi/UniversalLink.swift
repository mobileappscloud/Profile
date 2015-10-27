//
//  UniversalLink.swift
//  higi
//
//  Created by Remy Panicker on 10/16/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import Foundation

/**
URL paths which support universal linking.
*/
public enum PathType: String {
    case ActivityList = "/activity/list"
    case ChallengeDashboard = "/challenge/dashboard"
    case ChallengeDetail = "/challenge/view/id/%@"
    case DailySummary = "/profile/checkin/%@"
    case PulseArticle = "/pulse/%@"
    case PulseHome = "/pulse"
    case Metrics = "/stats"
    case MetricsBloodPressure = "/stats/blood_pressure"
    case MetricsPulse = "/stats/pulse"
    case MetricsWeight = "/stats/weight"
    case StationLocator = "/locator"
    
    private static let parameterToken = "%@"
    
    private static let tokenizedPaths: [PathType] = [.ChallengeDetail, .PulseArticle, .DailySummary]
    
    private static func handler(forPathType pathType: PathType) -> UniversalLinkHandler? {
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
            
        case .MetricsBloodPressure:
            fallthrough;
        case .MetricsPulse:
            fallthrough;
        case .MetricsWeight:
            fallthrough;
        case .Metrics:
            handler = MetricsViewController()
            
        case .ActivityList:
            fallthrough
        case .DailySummary:
            handler = DailySummaryViewController()
        }
        
        return handler;
    }
}

public class UniversalLink {
    
    /**
    Determines if a URL can be handled by the app.
    
    - parameter URL: Universal link to be handled.
    
    - returns: `true` if the app can handle the URL, otherwise `false`.
    */
    public class func canHandleURL(URL: NSURL) -> Bool {
        var canHandleURL = false;
        
        let (pathType, _) = self.parsePath(forURL: URL);
        canHandleURL = pathType != nil;
        
        return canHandleURL;
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
            if sourcePathComponenets.first == "pulse" {
                return (true, nil);
            } else {
                return (false, nil);
            }
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
        handler?.handleUniversalLink(URL, pathType: pathType!, parameters: parameters)
    }
}

/**
Protocol definition for app universal link handlers.
*/
public protocol UniversalLinkHandler {
    
    /**
    Protocol method for handling a universal link.
    
    - parameter URL:        URL of a compatible universal link.
    - parameter parameters: URL parameters such as resource GUIDs if applicable, otherwise nil.
    */
    func handleUniversalLink(URL: NSURL, pathType: PathType, parameters: [String]?);
}
