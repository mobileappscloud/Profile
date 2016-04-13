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
enum PathType: String {
    case ActivityList = "/activity/list"
    case ChallengeDashboard = "/challenge/dashboard"
    case ChallengeDetail = "/challenge/view/id/%@"
    case ChallengeDetailSubPath = "/challenge/view/id/%@/*]"
    case ConnectDevice = "/settings/apps"
    case DailySummary = "/profile/checkin/%@"
    case Metrics = "/stats"
    case MetricsBloodPressure = "/stats/blood_pressure"
    case MetricsPulse = "/stats/pulse"
    case MetricsWeight = "/stats/weight"
    case StationLocator = "/locator"
    
    // Token specifying a word which should be extracted for use as an input parameter
    private static let parameterToken = "%@"
    
    // Token specifying that all trailing characters can be ignored
    private static let trailingToken = "*]"
    
    private static let tokenizedPaths: [PathType] = [.ChallengeDetail, .ChallengeDetailSubPath, .DailySummary]
    
    private static func handler(forPathType pathType: PathType) -> UniversalLinkHandler? {
        var handler: UniversalLinkHandler? = nil
        
        switch pathType {
        case .ChallengeDetail:
            fallthrough
        case .ChallengeDetailSubPath:
            fallthrough
        case .ChallengeDashboard:
            handler = ChallengesViewController()
            
        case .StationLocator:
            handler = FindStationViewController()
            
        case .MetricsBloodPressure:
            fallthrough
        case .MetricsPulse:
            fallthrough
        case .MetricsWeight:
            fallthrough
        case .Metrics:
            handler = NewMetricsViewController()
            
        case .ActivityList:
            fallthrough
        case .DailySummary:
            handler = DailySummaryViewController()
            
        case .ConnectDevice:
            handler = ConnectDeviceViewController()
        }
        
        return handler
    }
}

class UniversalLink {
    
    /**
    Determines if a URL can be handled by the app.
    
    - parameter URL: Universal link to be handled.
    
    - returns: `true` if the app can handle the URL, otherwise `false`.
    */
    class func canHandleURL(URL: NSURL) -> Bool {
        var canHandleURL = false
        
        let (pathType, _) = self.parsePath(forURL: URL)
        if pathType != nil {
            canHandleURL = true
        }
        
        return canHandleURL
    }
    
    class func parsePath(forURL URL: NSURL) -> (pathType: PathType?, parameters: [String]?) {
        var pathType: PathType? = nil
        var parameters: [String]? = nil
        
        if let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: true), let path = components.path {
            if let fullPathType = PathType(rawValue: path) {
                pathType = fullPathType
            } else {
                if var pathComponents = URL.pathComponents {
                    var canHandlePath: Bool = false
                    // The first path component can be ignored because it is just a forward slash ('/')
                    pathComponents.removeFirst()
                    
                    for tokenizedPathType in PathType.tokenizedPaths {
                        var targetPathComponents = tokenizedPathType.rawValue.componentsSeparatedByString("/")
                        // Remove the first component in the target because similar to the source, the first component can be ignored
                        targetPathComponents.removeFirst()
                        
                        (canHandlePath, parameters) = matchPathComponents(targetPathComponents, sourcePathComponenets: pathComponents)
                        if canHandlePath {
                            pathType = tokenizedPathType
                            break
                        }
                    }

                }
            }
        }
        
        return (pathType, parameters)
    }
    
    private class func matchPathComponents(targetPathComponents: [String], sourcePathComponenets: [String]) -> (didMatchComponents: Bool, parameters: [String]?) {

        if targetPathComponents.count > sourcePathComponenets.count {
            return (false, nil)
        } else if targetPathComponents.count < sourcePathComponenets.count {
            if !targetPathComponents.contains(PathType.trailingToken) {
                return (false, nil)
            }
        }

        var componentsMatch: Bool? = nil
        var parameters: [String]? = []
        
        for index in 0...targetPathComponents.count-1 {
            if targetPathComponents[index] == PathType.trailingToken {
                break
            } else if targetPathComponents[index] == PathType.parameterToken {
                parameters?.append(sourcePathComponenets[index])
            } else if targetPathComponents[index] != sourcePathComponenets[index] {
                parameters = nil
                componentsMatch = false
                break
            }
        }
        
        componentsMatch = componentsMatch ?? true
        
        return (componentsMatch!, parameters)
    }
}

extension UniversalLink {
    
    /**
    Handles a compatible universal link. This method should only be called after calling
    `canHandleURL:` to ensure that the app is capable of continuing the user activity.
    
    - parameter URL: Universal link to be handled.
    */
    class func handleURL(URL: NSURL) {
        let (pathType, parameters) = self.parsePath(forURL: URL)
        if pathType == nil {
            return
        }
          
        let handler: UniversalLinkHandler? = PathType.handler(forPathType: pathType!)
        handler?.handleUniversalLink(URL, pathType: pathType!, parameters: parameters)
    }
}

/**
Protocol definition for app universal link handlers.
*/
protocol UniversalLinkHandler {
    
    /**
    Protocol method for handling a universal link.
    
    - parameter URL:        URL of a compatible universal link.
    - parameter parameters: URL parameters such as resource GUIDs if applicable, otherwise nil.
    */
    func handleUniversalLink(URL: NSURL, pathType: PathType, parameters: [String]?)
}

extension UniversalLinkHandler {
    
    /** 
    Presents a loading view controller from the main navigation controller.
     
    - returns: The loading view controller which has been presented.
    */
    func presentLoadingViewController() -> UIViewController {
        let tabBarController = Utility.mainTabBarController()!
        let loadingViewController = UIStoryboard(name: "Loading", bundle: nil).instantiateInitialViewController()!
        dispatch_async(dispatch_get_main_queue(), {
            tabBarController.navigationController?.popToRootViewControllerAnimated(false)
            tabBarController.presentViewController(loadingViewController, animated: true, completion: nil)
        })
        return loadingViewController
    }
}
