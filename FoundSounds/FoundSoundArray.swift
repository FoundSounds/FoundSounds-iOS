//
//  FoundSoundArray.swift
//  Found Sounds
//
//  Created by David Jensenius on 2016-04-12.
//

import Foundation
#if TARGET_OS_TV
    import CoreLocation
#else
    import MapKit
#endif

protocol FoundSoundArrayDelegate: class {
    func finishedLoadingSoundArray(_ foundSounds: [AnyObject]!)
}

class FoundSoundArray: NSObject {
    weak var delegate: FoundSoundArrayDelegate?

    var FSArray = NSMutableArray()

    var streamArray = NSMutableDictionary()
    var streamType = ""
    var userID = 0
    var sound = FoundSound()

    override init() {
        super.init()
    }
    /**
    Update an array of found sounds.
        
    @params Stream: favorites, mysounds, soundStream
    @note Use with finishedLoadingSoundArray delegate
    */
    func updateStream(_ content: NSString) {
        print("Going to update stream")
        var requestURL = "https://foundsounds.me/stream/api"
        streamType = content as String
        if content == "favorites" {
            requestURL = "https://foundsounds.me/stream/favorites"
        } else if content == "mysounds" {
            requestURL = "https://foundsounds.me/stream/mysounds"
        } else if content == "soundsByUser" {
            requestURL = "https://foundsounds.me/stream/usersounds/\(userID)"
        } else if content == "favoritesByUser" {
            requestURL = "https://foundsounds.me/stream/userfavorited/\(userID)"
        } else if content == "favoritedByUser" {
            requestURL = "https://foundsounds.me/stream/userfavorites/\(userID)"
        } else if content == "recentPublic" {
            requestURL = "https://foundsounds.me/api/recent"
        }

        fetchFSArray(URL(string: requestURL)!, post: nil, cacheBackup: true, streamType: self.streamType)
    }

    /**
     Initialize an array of found sounds with a given stream type.
     
     @params Stream favorites, mysounds, soundStream
     @note Use with finishedLoadingSoundArray delegate
     */
    init(stream: NSString) {
        super.init()
        self.updateStream(stream)
    }

    /**
     Initialize an array of found sounds with a given stream type specific to user.
     
     @params soundsByUser, favoritesByUser, favoritedByUser
     @note Use with finishedLoadingSoundArray delegate
     */
    init(stream: NSString, user: NSInteger) {
        super.init()
        userID = user
        self.updateStream(stream)
    }

    /**
     Initialize an array of found sounds within a given map box
     
     @params neCoord, nwCoord, seCoord, SwCoord
     @note Use with finishedLoadingSoundArray delegate
     */
    init(mapNECoord: CLLocationCoordinate2D,
         NWCoord: CLLocationCoordinate2D,
         SECoord: CLLocationCoordinate2D,
         SWCoord: CLLocationCoordinate2D) {
        super.init()
        let requestURL = "https://foundsounds.me/iosuser/mapmakers"
        let post = """
            neLat=\(mapNECoord.latitude)\
            &neLon=\(mapNECoord.longitude)\
            &nwLat=\(NWCoord.latitude)\
            &nwLon=\(NWCoord.longitude)\
            &seLat=\(SECoord.latitude)\
            &seLon=\(SECoord.longitude)\
            &swLat=\(SWCoord.latitude)\
            &swLon=\(SWCoord.longitude)
            """
        fetchFSArray(URL(string: requestURL)!, post: post, cacheBackup: false, streamType: nil)
    }

    /**
     Initialize an array of found sounds within a given map box (public version, no login required)
     
     @params neCoord, nwCoord, seCoord, SwCoord
     @note Use with finishedLoadingSoundArray delegate
     */
    init(publicMapNECoord: CLLocationCoordinate2D,
         NWCoord: CLLocationCoordinate2D,
         SECoord: CLLocationCoordinate2D,
         SWCoord: CLLocationCoordinate2D) {
        super.init()
        let requestURL = "https://foundsounds.me/api/mapmarkers"
        let post = """
            neLat=\(publicMapNECoord.latitude)\
            &neLon=\(publicMapNECoord.longitude)\
            &nwLat=\(NWCoord.latitude)\
            &nwLon=\(NWCoord.longitude)\
            &seLat=\(SECoord.latitude)\
            &seLon=\(SECoord.longitude)\
            &swLat=\(SWCoord.latitude)\
            &swLon=\(SWCoord.longitude)
            """
        fetchFSArray(URL(string: requestURL)!, post: post, cacheBackup: false, streamType: nil)
    }

    /**
     Initialize an array of sounds for a sound walk
     
     @params currentLocation
     @note Use with finishedLoadingSoundArray delegate
     */
    init(walkCoord: CLLocation) {
        super.init()
        let requestURL = "https://foundsounds.me/iosuser/walk"
        let post = "lat=\(walkCoord.coordinate.latitude)&lon=\(walkCoord.coordinate.longitude)"
        fetchFSArray(URL(string: requestURL)!, post: post, cacheBackup: false, streamType: nil)
    }

    /**
     Initialize an array of nearby sounds
     
     @params currentLocation
     @note Use with finishedLoadingSoundArray delegate
     */
    init(listOfNearbySounds: CLLocation) {
        super.init()
        let requestURL = "https://foundsounds.me/api/nearby"
        let post = "lat=\(listOfNearbySounds.coordinate.latitude)&lon=\(listOfNearbySounds.coordinate.longitude)"
        fetchFSArray(URL(string: requestURL)!, post: post, cacheBackup: false, streamType: nil)
    }

    /**
     Pull an array of sounds from local cache
     @params Stream: favorites, mysounds, soundStream
     */
    init(cache: NSString) {
        super.init()
        let type = cache

        let cacheFile: String

        if type == "default" {
            cacheFile = "stream-data"
        } else {
            cacheFile = "stream-\(type)"
        }

        let filePath = self.cacheStreamDirectoryName() + cacheFile
        if FileManager.default.fileExists(atPath: filePath) {
            let returnData = NSMutableData(contentsOfFile: filePath)
            if returnData?.length ?? 0 > 0 {
                var json: Any!
                do {
                    json = try JSONSerialization.jsonObject(with: returnData! as Data, options: [])
                    self.streamArray.removeAllObjects()

                    self.FSArray = NSMutableArray()
                    for sound in (json as? NSArray)! {
                        let foundSound: FoundSound = FoundSound(
                            soundDictionary: (sound as? [NSObject: AnyObject])! as NSDictionary
                        )
                        self.FSArray.add(foundSound)
                    }
                    self.delegate?.finishedLoadingSoundArray(self.FSArray as [AnyObject])

                } catch {
                    print("Well, shit (initFoundSoundCache) again, another error 5")
                }
            }
        } else {
            print("Cache not found...")
        }
    }

    fileprivate func fetchFSArray(_ url: URL, post: String?, cacheBackup: Bool, streamType: String?) {

        let request = NSMutableURLRequest()

        request.url = url
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        if post != nil {
            let postData = post!.data(using: String.Encoding.utf8, allowLossyConversion: false)
            let postLength = String(describing: postData?.count)
            request.setValue(postLength, forHTTPHeaderField: "Content-Length")
            request.httpBody = postData
        }

        _ = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, _, error) in
            let returnData = data

            if error != nil && cacheBackup == true {
                self.getCacheStream()
                self.delegate?.finishedLoadingSoundArray(self.FSArray as [AnyObject])
            } else if error != nil {
                print("Error loading array")
            } else {
                if cacheBackup == true {
                    self.writeCacheData(returnData)
                }
                var json: Any!
                do {
                    json = try JSONSerialization.jsonObject(with: returnData!, options: [])
                } catch { print("Well, shit (delegate) again, another error 6") }

                self.streamArray.removeAllObjects()

                self.FSArray = NSMutableArray()
                let jsonArray = json as? NSArray

                if jsonArray?.count ?? 0 > 0 {
                    for sound in jsonArray! {
                        let foundSound = FoundSound(soundDictionary: (sound as? [NSObject: AnyObject])! as NSDictionary)
                        self.FSArray.add(foundSound)
                    }
                    self.delegate?.finishedLoadingSoundArray(self.FSArray as [AnyObject])
                }
            }
        }).resume()
    }

    fileprivate func getCacheStream() {
        var returnData: Data?
        if self.streamType == "default" {
            returnData = try? Data(contentsOf: URL(
                fileURLWithPath: self.cacheStreamDirectoryName() + "stream-data")
            )
        } else {
            returnData = try? Data(contentsOf: URL(fileURLWithPath:
                self.cacheStreamDirectoryName() + "stream-\(self.streamType)")
            )
        }

        var json: Any!
        do {
            json = try JSONSerialization.jsonObject(with: returnData!, options: [])
        } catch { print("Well, shit (delegate) again, another error 6") }

        self.streamArray.removeAllObjects()
        self.FSArray = NSMutableArray()
        for sound in (json as? NSArray)! {
            let foundSound = FoundSound(soundDictionary: (sound as? [NSObject: AnyObject])! as NSDictionary)
            self.FSArray.add(foundSound)
        }
    }

    fileprivate func writeCacheData(_ returnData: Data?) {
        if self.streamType == "default" {
            let writeDir = URL(fileURLWithPath: "\(self.cacheStreamDirectoryName())stream-data")
            do {
                try returnData?.write(to: writeDir, options: [.atomicWrite])
            } catch { print("Bummer 1") }
        } else {
            let writeDir =
                URL(fileURLWithPath: "\(self.cacheStreamDirectoryName())stream-\(self.streamType)")
            do {
                try returnData?.write(to: writeDir, options: [.atomicWrite])
            } catch { print("Bummer 2") }
        }
    }

    fileprivate func cacheStreamDirectoryName() -> String {
        let directory = "Stream"
        let cacheDirectoryName =
            NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] as NSString
        let finalDirectoryName = cacheDirectoryName.appendingPathComponent(directory)

        do {
            try FileManager.default.createDirectory(
                atPath: finalDirectoryName,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            print(error)
        }
        return finalDirectoryName
    }
}
