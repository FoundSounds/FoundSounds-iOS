//
//  FirstViewController.swift
//  FoundSounds
//
//  Created by David Jensenius on 2018-11-04.
//  Copyright © 2018 David Jensenius. All rights reserved.
//

import UIKit
import Reachability

class SetupViewController: UIViewController {

    var currentUser: CurrentUser?
    let reachability = Reachability()!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to create Reachability")
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SetupViewController.handleNetworkChange(note:)),
            name: Notification.Name.reachabilityChanged,
            object: reachability
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Timer.scheduledTimer(
            timeInterval: 2.0,
            target: self,
            selector: #selector(SetupViewController.logAccess),
            userInfo: nil,
            repeats: false
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        currentUser = CurrentUser.init(email: "david@example.com", password: "testing")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        currentUser?.logout()
    }

    @objc func handleNetworkChange(note: Notification) {
        if currentUser?.currentlyLoggedIn == false {
            let reach = note.object as? Reachability
            if reach?.connection != .none {
                currentUser = CurrentUser(email: "test@test.com", password: "testing")
            }
        }
    }

    @objc func logAccess() {

    }
}
