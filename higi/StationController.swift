//
//  StationController.swift
//  higi
//
//  Created by Remy Panicker on 6/2/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class StationController: NSObject {
    
    private(set) var stations: [KioskInfo] = []
    
    lazy private var session: NSURLSession = {
       return APIClient.session()
    }()
    
    private let fileManager: NSFileManager = {
        return NSFileManager.defaultManager()
    }()

    private let saveFileURL: NSURL = {
        let tempPath = (NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0])
        let tempURL = NSURL(fileURLWithPath: tempPath)
        let writePath = tempURL.URLByAppendingPathComponent("higi-stations.json")
        return writePath
    }()
    
    private func saveFilePath() -> String {
       return saveFileURL.relativePath!
    }
}

extension StationController {
    
    func fetch(success: () -> Void, failure: () -> Void) {
        if (stations.count != 0) {
            success()
            return
        }
        
        if (fileManager.fileExistsAtPath(saveFileURL.relativePath!)) {
            deserializeSavedStationList(success, failure: failure)
        } else {
            performDownloadTask(success, failure: failure)
        }
    }
    
    private func performDownloadTask(success: () -> Void, failure: () -> Void) {
        
        let request = StationCollectionRequest.request()
        
        let task = session.downloadTaskWithRequest(request, completionHandler: { [weak self] (responseURL, response, error) in
            
            guard let strongSelf = self else { return }
            
            guard let response = response as? NSHTTPURLResponse where response.statusCodeEnum.isSuccess,
                let responseURL = responseURL else {
                failure()
                return
            }
            
            strongSelf.process(fileAtURL: responseURL, success: success, failure: failure)
        })
        task.resume()
    }
}

extension StationController {
    
    private func process(fileAtURL URL: NSURL, success: () -> Void, failure: () -> Void) {
        do {
            try fileManager.copyItemAtURL(URL, toURL: saveFileURL)
            deserializeSavedStationList(success, failure: failure)
        } catch {
            do {
                try fileManager.removeItemAtURL(saveFileURL)
                failure()
            } catch {
                failure()
            }
        }
    }
}

extension StationController: JSONDeserializable {
    
    private func deserializeSavedStationList(success: () -> Void, failure: () ->  Void) {
        
        guard let data = NSData(contentsOfURL: saveFileURL) else {
            failure()
            return
        }
        
        self.dynamicType.deserialize(data, success: { [weak self] (JSON) in
            guard let strongSelf = self else { return }
            
            guard let responseArray = JSON as? NSArray else {
                failure()
                return
            }
            
            var stations: [KioskInfo] = []
            for stationDictionary in responseArray {
                guard let stationDictionary = stationDictionary as? NSDictionary else { continue }
                
                let station = KioskInfo(dictionary: stationDictionary)
                if station.position == nil { continue }
                
                if (station.isMapVisible) {
                    stations.append(station)
                } else {
                    guard let checkins = SessionController.Instance.checkins else { continue }
                    
                    for checkin in checkins {
                        if let kioskInfo = checkin.kioskInfo where station.kioskId == kioskInfo.kioskId {
                            stations.append(station)
                            break
                        }
                    }
                }
            }
            strongSelf.stations = stations
            success()
            
        }, failure: { _ in
            failure()
        })
    }
}
