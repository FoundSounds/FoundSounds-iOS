//
//  User.swift
//  FoundSounds
//
//  Created by David Jensenius on 2018-11-19.
//  Copyright © 2018 David Jensenius. All rights reserved.
//

import Foundation

protocol CurrentUserDelegate: class {
    /**
     Delegate called after logging in
     
     @returns Bool indicating success.
     */
    func finishedLoggingIn(_ success: Bool)
    func finishedLoggingOut(_ success: Bool)
}

extension CurrentUserDelegate {
    func finishedLoggingIn(_ success: Bool) { }
    func finishedLoggingOut(_ success: Bool) { }
}

class CurrentUser: NSObject {
    weak var delegate: CurrentUserDelegate?
    var name: String?
    var username: String?
    var userID: Int?
    var email: String?
    var portrait: String?
    var currentlyLoggedIn: Bool?

    override init() {
        super.init()
    }

    convenience init(email: String, password: String) {
        self.init()

        guard let domain = ProcessInfo.processInfo.environment["FS_DOMAIN"] else { return }
        guard let token = ProcessInfo.processInfo.environment["AUTH_TOKEN"] else { return }
        let requestURL = "\(domain)/users/sign_in.json"

        let request = NSMutableURLRequest()
        let post =
            "user[email]=\(email)&user[password]=\(password)&user[remember_me]=1&commit=Log%20in&auth_token=\(token)"
        let postData = post.data(using: String.Encoding.ascii, allowLossyConversion: true)
        let postLength = String(describing: postData?.count)

        request.url = URL(string: requestURL as String)
        request.httpMethod = "POST"
        request.setValue(postLength, forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = postData

        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, _, error) in
            if error != nil {
                print("Shit, an error! \(String(describing: error))")
                return
            } else {
                var json: Any!
                do {
                    json = try JSONSerialization.jsonObject(with: data!, options: [])
                } catch {
                    print("Error logging in!")
                    return
                }
                if let loginError = (json as AnyObject).object(forKey: "error") as? String {
                    print("Error \(loginError)")
                    self.currentlyLoggedIn = false
                    self.delegate?.finishedLoggingIn(false)
                    return
                }
                self.currentlyLoggedIn = true
                self.delegate?.finishedLoggingIn(true)
            }
        }).resume()
    }

    func logout() {
        guard let domain = ProcessInfo.processInfo.environment["FS_DOMAIN"] else { return }
        let requestURL = "\(domain)/users/sign_out.json"

        let request = NSMutableURLRequest()
        request.url = URL(string: requestURL as String)
        request.httpMethod = "DELETE"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(_, _, error) in
            if error != nil {
                print("Error logging out! \(String(describing: error))")
                self.delegate?.finishedLoggingOut(false)
                return
            } else {
                self.currentlyLoggedIn = false
                self.delegate?.finishedLoggingOut(true)
            }
        }).resume()
    }
}
