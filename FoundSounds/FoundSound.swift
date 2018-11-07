//
//  FoundSound.swift
//  Found Sounds
//
//  Created by David Jensenius on 2016-04-13.
//

import Foundation
import UIKit
#if os(watchOS)
    import WatchKit
#endif

protocol FoundSoundDelegate: class {
    /**
     Delegate called after sound has finished loading
     
     @returns FoundSound id
     */
    func finishedLoadingSound(_ foundSound: AnyObject)

    /**
     Delegate called after loading likes for a sound
     
     @returns String with formatting @a Liked @a by...
     */
    func finishedLoadingLikes(_ likedBy: String)

    /**
     Delegate called after removing a sound
     
     @returns BOOL indicating success
     */
    func finishedRemovingSound(_ success: Bool)

    /**
     Delegate called after making a sound private
     
     @returns BOOL indicating success
     */
    func finishedMakingSoundPrivate(_ success: Bool)

    /**
     Delegate called after making a sound public
     
     @return BOOL indicating success
     */
    func finishedMakingSoundPublic(_ success: Bool)
}

extension FoundSoundDelegate {
    // Make swift optional stuff
    func finishedLoadingSound(_ foundSound: AnyObject) { }
    func finishedLoadingLikes(_ likedBy: String) { }
    func finishedRemovingSound(_ success: Bool) { }
    func finishedMakingSoundPrivate(_ success: Bool) { }
    func finishedMakingSoundPublic(_ success: Bool) { }
}

class FoundSound: NSObject {
    weak var delegate: FoundSoundDelegate?
    var city = String()
    var country = String()
    var soundDescription = String()
    var fileName = String()
    var fullName = String()
    var liked = false
    var commons = false
    var longitude: Double = 0.0
    var latitude: Double = 0.0
    var likes = 0
    var name = String()
    var photoFileName: String?
    var photoID = 0
    var portrait = String()
    var publicSound = false
    var rawportrait = String()
    var soundID = 0
    var stateProvince = String()
    var timestamp = Date()
    var howLongAgo = String()
    var trackCover = String()
    var trackMP4 = URL(string: "")
    var trackOGG = URL(string: "")
    var userID = 0
    var username = String()
    var initials = String()
    var timeandplaceText = String()
    var shareURL = String()

    let SECOND: Double = 1
    let MINUTE: Double = 60
    let HOUR: Double = 3600
    let DAY: Double = 86400
    let MONTH: Double = 86400 * 30

    override init() {
        super.init()
    }

    /**
    Init a FoundSound with the Sound ID
         
    @returns self id
    @note Should be used with finishedLoadingSound delegate
    */
    init(soundID: NSInteger) {
        super.init()

        let requestSoundURL = "https://foundsounds.me/iosuser/getsound"

        let request = NSMutableURLRequest()
        let post = "sound_id=\(soundID)"
        let postData = post.data(using: String.Encoding.ascii, allowLossyConversion: true)
        let postLength = String(describing: postData?.count)

        request.url = URL(string: requestSoundURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(postLength, forHTTPHeaderField: "Content-Length")
        request.httpBody = postData

        _ = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, _, _) in
            var json: Any!
            do {
                json = try JSONSerialization.jsonObject(with: data!, options: [])
            } catch {
                print("Well, shit (delegate) again, another error 1")
            }

            for like in (json as? [NSDictionary])! {
                self.setAllValues(like)
            }

            self.delegate?.finishedLoadingSound(self)
        }).resume()
    }

    /**
     Create a found sound with a dictionary of FoundSound components
     
     @params soundDictionary: All values associated with a FoundSound
     @returns FoundSound object
     */
    init(soundDictionary: NSDictionary) {
        super.init()
        self.setAllValues(soundDictionary)
    }

    /**
     Get who likes a sound id
     
     @note Should be used with finishedLoadingLikes delegate
     */
    func getLikedBy(_ soundID: NSInteger) {
        let requestLikeURL = "https://foundsounds.me/iosuser/getlike"

        let request = NSMutableURLRequest()
        let post = "sound_id=\(soundID)"
        let postData = post.data(using: String.Encoding.ascii, allowLossyConversion: true)
        let postLength = String(describing: postData?.count)

        request.url = URL(string: requestLikeURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(postLength, forHTTPHeaderField: "Content-Length")
        request.httpBody = postData

        _ = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, _, _) in
            var json: Any!
            do {
                json = try JSONSerialization.jsonObject(with: data!, options: [])
            } catch {
                print("Well, shit (delegate) again, another error 2")
            }

            var likeText = ""
            for like in (json as? [NSDictionary])! {
                if likeText == "" {
                    likeText = "Liked by \(like.object(forKey: "fullname")!)"
                } else {
                    likeText += ", \(like.object(forKey: "fullname")!)"
                }
            }

            if likeText == "" {
                likeText = "No one has favorited this yet. Why not be the first?"
            }
            self.delegate?.finishedLoadingLikes(likeText)
        }).resume()
    }

    /**
     Get a random public sound with a location
     
     @returns self id
     @note Should be used with finishedLoadingSound delegate
     */
    func getRandom() {
        let requestSoundURL = "https://foundsounds.me/api/random"

        let request = NSMutableURLRequest()
        request.url = URL(string: requestSoundURL)

        _ = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, _, _) in
            var json: Any!
            do {
                json = try JSONSerialization.jsonObject(with: data!, options: [])
            } catch {
                print("Well, shit (delegate) again, another error 1")
            }

            for like in (json as? [NSDictionary])! {
                self.setAllValues(like)
            }

            self.delegate?.finishedLoadingSound(self)
        }).resume()
    }

    /**
     Delete a found sound from server. Will only return success if the logged in user is the sounds owner
     
     @note Should be used with finishedRemovingSound delegate
     */
    func deleteSound(_ soundID: NSInteger) {
        let requestLikeURL = "https://foundsounds.me/iosuser/remove"

        let request = NSMutableURLRequest()
        let post = "sound_id=\(soundID)"
        let postData = post.data(using: String.Encoding.ascii, allowLossyConversion: true)
        let postLength = String(postData!.count)

        request.url = URL(string: requestLikeURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(postLength, forHTTPHeaderField: "Content-Length")
        request.httpBody = postData!

        _ = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, _, _) in
            var json: Any!
            do {
                json = try JSONSerialization.jsonObject(with: data!, options: [])
            } catch {
                print("Well, shit (delegate) again, another error 3")
            }

            if ((json as AnyObject).object(forKey: "deletesuccess") as? String)! == "success" {
                self.delegate?.finishedRemovingSound(true)
            } else {
                self.delegate?.finishedRemovingSound(false)
            }
        }).resume()
    }

    /**
     Mark a found sound private. Will only return success if the logged in user is the sounds owner
     
     @note Should be used with finishedRemovingSound delegate
     */
    func markSoundPrivate(_ soundID: NSInteger) {
        let requestLikeURL = "https://foundsounds.me/iosuser/make_private"

        let request = NSMutableURLRequest()
        let post = "sound_id=\(soundID)"
        let postData = post.data(using: String.Encoding.ascii, allowLossyConversion: true)
        let postLength = String(describing: postData?.count)

        request.url = URL(string: requestLikeURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(postLength, forHTTPHeaderField: "Content-Length")
        request.httpBody = postData

        let privateConnection = URLSession.shared

        privateConnection.dataTask(with: request as URLRequest, completionHandler: { (data, _, _) in
            var json: Any!
            do {
                json = try JSONSerialization.jsonObject(with: data!, options: [])
            } catch {
                print("Well, shit (delegate) again, another error")
            }

            if ((json as AnyObject).object(forKey: "privatesuccess") as? String)! == "success" {
                self.delegate?.finishedMakingSoundPrivate(true)
            } else {
                self.delegate?.finishedMakingSoundPrivate(false)
            }
        }).resume()
    }

    /**
     Mark a found sound public. Will only return success if the logged in user is the sounds owner
     
     @note Should be used with finishedRemovingSound delegate
     */
    func markSoundPublic(_ soundID: NSInteger) {
        let requestLikeURL = "https://foundsounds.me/iosuser/make_public"

        let request = NSMutableURLRequest()
        let post = "sound_id=\(soundID)"
        let postData = post.data(using: String.Encoding.ascii, allowLossyConversion: true)
        let postLength = String(describing: postData?.count)

        request.url = URL(string: requestLikeURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(postLength, forHTTPHeaderField: "Content-Length")
        request.httpBody = postData

        let publicConnection = URLSession.shared

        publicConnection.dataTask(with: request as URLRequest, completionHandler: { (data, _, _) in
            var json: Any!
            do {
                json = try JSONSerialization.jsonObject(with: data!, options: [])
            } catch {
                print("Well, shit (delegate) again, another error 4")
            }

            if ((json as AnyObject).object(forKey: "publicsuccess") as? String)! == "success" {
                self.delegate?.finishedMakingSoundPublic(true)
            } else {
                self.delegate?.finishedMakingSoundPublic(false)
            }
        }).resume()
    }

    /**
     Mark the sound played
     */
    func logPlay(_ soundID: NSInteger, withType: NSString) {
        let requestLikeURL = "https://foundsounds.me/api/play"

        //let device = UIDevice.currentDevice()
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        let build = Bundle.main.object(forInfoDictionaryKey: String(kCFBundleVersionKey))

        #if os(watchOS)
            let currentDevice = WKInterfaceDevice.current()
            let iOSV = WKInterfaceDevice.current().systemVersion
            let name = WKInterfaceDevice.current().name
        #else
            let iOSV = UIDevice.current.systemVersion
            let name = UIDevice.current.name
            let currentDevice = UIDevice.current
        #endif

        let request = NSMutableURLRequest()
        let post = """
            sound_id=\(soundID)\
            &type=\(withType)\
            &os=\(iOSV)\
            &version=\(String(describing: version))\
            &build=\(String(describing: build))\
            &name=\(name)\
            &device_systemname=\(currentDevice.systemName)\
            &device_version=\(currentDevice.systemVersion)\
            &device_model=\(currentDevice.model)\
            &e=\(currentDevice.localizedModel)
            """
        let postData = post.data(using: String.Encoding.ascii, allowLossyConversion: true)
        let postLength = String(describing: postData?.count)

        request.url = URL(string: requestLikeURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(postLength, forHTTPHeaderField: "Content-Length")
        request.httpBody = postData

        let logConnection = URLSession.shared

        logConnection.dataTask(with: request as URLRequest, completionHandler: { (_, _, _) in
            print("Logged play...")
        }).resume()
    }

    /**
     Calculate the interval between two dates
     
     @params Start Date, End Date
     @returns Text representation of time, including text "ago". For example, "2 months ago".
     */
    func timeIntervalWithStartDate(_ firstDate: Date, secondDate: Date) -> String {
        let delta = secondDate.timeIntervalSince(firstDate)

        if delta < 1 * MINUTE {
            return delta == 1 ? "seconds ago" : "seconds ago"
        }

        if delta < 2 * MINUTE {
            return "1 minute ago"
        }

        if delta < 45 * MINUTE {
            let minutes = Int(floor(delta/MINUTE))
            return "\(minutes) minutes ago"
        }

        if delta < 90 * MINUTE {
            return "1 hour ago"
        }

        if delta < 24 * HOUR {
            let hours = Int(floor(delta/HOUR))
            return "\(hours) hours ago"
        }

        if delta < 48 * HOUR {
            return "1 day ago"
        }

        if delta < 30 * DAY {
            let days = Int(floor(delta/DAY))
            return "\(days) days ago"
        }

        if delta < 12 * MONTH {
            let months = Int(floor(delta/MONTH))
            return months <= 1 ? "1 month ago" : "\(months) months ago"
        } else {
            let years = Int(floor(delta/MONTH/12.0))
            return years <= 1 ? "1 year ago" : "\(years) years ago"
        }
    }

    /**
     Calculate the interval between two dates
     
     @params Start Date, End Date
     @returns Text representation of time, excluding text "ago". For example, "2 months".
     */
    func timeDescriptionIntervalWithStartDate(_ firstDate: Date, secondDate: Date) -> String {
        //Calculate the delta in seconds between the two dates
        let delta = secondDate.timeIntervalSince(firstDate)

        if delta < 1 * MINUTE {
            return delta == 1 ? "seconds ago" : "seconds ago"
        }

        if delta < 2 * MINUTE {
            return "1 minute"
        }

        if delta < 45 * MINUTE {
            let minutes = Int(floor(delta/MINUTE))
            return "\(minutes) minutes"
        }

        if delta < 90 * MINUTE {
            return "1 hour"
        }

        if delta < 24 * HOUR {
            let hours = Int(floor(delta/HOUR))
            return "\(hours) hours"
        }

        if delta < 48 * HOUR {
            return "1 day"
        }

        if delta < 30 * DAY {
            let days = Int(floor(delta/DAY))
            return "\(days) days"
        }

        if delta < 12 * MONTH {
            let months = Int(floor(delta/MONTH))
            return months <= 1 ? "1 month" : "\(months) months"
        } else {
            let years = Int(floor(delta/MONTH/12.0))
            return years <= 1 ? "1 year" : "\(years) years"
        }
    }

    fileprivate func setAllValues(_ like: NSDictionary) {
        /* Load the rest of the view */
        //NSLog(@"Like is %@", like);
        self.fullName = (like.object(forKey: "full_name") as? String)!
        self.city = (like.object(forKey: "city") as? String)!
        self.stateProvince = (like.object(forKey: "state") as? String)!
        country = (like.object(forKey: "country") as? String)!

        self.fileName = (like.object(forKey: "file_name") as? String)!
        self.name = (like.object(forKey: "name") as? String)!

        self.soundID = (like.object(forKey: "soundID")! as AnyObject).intValue
        self.userID = (like.object(forKey: "userID")! as AnyObject).intValue
        self.likes = (like.object(forKey: "likes")! as AnyObject).intValue

        self.latitude = (like.object(forKey: "latitude")! as AnyObject).doubleValue
        self.longitude = (like.object(forKey: "longitude")! as AnyObject).doubleValue

        let requestDomain = "https://foundsounds.me"
        self.trackMP4 = URL(string: "\(requestDomain)\(like.object(forKey: "trackMP4")!)")!

        self.soundDescription = ""
        self.soundDescription = (like.object(forKey: "description") as? String)!
        self.trackCover = (like.object(forKey: "trackCover") as? String)!
        self.rawportrait = (like.object(forKey: "rawportrait") as? String)!
        self.portrait = (like.object(forKey: "portrait") as? String)!
        self.photoFileName = like.object(forKey: "photo_file_name") as? String
        self.photoID = (like.object(forKey: "photo_id")! as AnyObject).intValue

        if (like.object(forKey: "public")! as AnyObject).intValue == 1 {
            self.publicSound = true
        } else {
            self.publicSound = false
        }

        if (like.object(forKey: "commons")! as AnyObject).intValue == 1 {
            self.commons = true
        } else {
            self.commons = false
        }

        self.username = (like.object(forKey: "username") as? String)!

        var likedInt = 0
        likedInt = (like.object(forKey: "liked")! as AnyObject).intValue
        if likedInt == 1 {
            self.liked = true
        } else {
            self.liked = false
        }

        self.shareURL = """
            https://foundsounds.me/listen/\(like.object(forKey: "username")!)/\(like.object(forKey: "soundID")!)
            """

        setTimeAndLocation(like: like)
        setInitials()
    }

    func setTimeAndLocation(like: NSDictionary) {
        var locationString = ""
        if self.stateProvince == "" && self.city == "" {
            locationString = country
        } else if self.stateProvince == "" {
            locationString = "\(self.city), \(self.country)"
        } else if self.city == "" {
            locationString = "\(self.stateProvince), \(self.country)"
        } else {
            locationString = "\(self.city), \(self.stateProvince)"
        }
        if self.soundDescription == "" {
            self.soundDescription = locationString
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timeZone = TimeZone(identifier: "UTC")
        formatter.timeZone = timeZone
        timestamp = formatter.date(from: (like.object(forKey: "timestamp") as? String)!)!
        let d2 = Date()
        self.howLongAgo = self.timeIntervalWithStartDate(self.timestamp, secondDate: d2) as String
        if locationString != "" {
            self.timeandplaceText = """
            \(self.timeDescriptionIntervalWithStartDate(self.timestamp, secondDate: d2)) ago in \(locationString)
            """
        } else {
            self.timeandplaceText = "\(self.timeDescriptionIntervalWithStartDate(self.timestamp, secondDate: d2)) ago"
        }
    }

    func setInitials() {
        let names = self.name.components(separatedBy: CharacterSet.whitespaces)
        var firstLetter = ""
        var secondLetter = ""

        for name in names {
            if firstLetter != "" {
                if name.characters.count > 0 {
                    secondLetter = String(name[name.startIndex])
                }
            } else {
                firstLetter = String(name[name.startIndex])
            }
        }

        if secondLetter != "" {
            self.initials = firstLetter + secondLetter
        } else {
            self.initials = firstLetter
        }
    }
}
