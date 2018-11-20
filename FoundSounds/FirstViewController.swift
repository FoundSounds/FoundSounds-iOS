//
//  FirstViewController.swift
//  FoundSounds
//
//  Created by David Jensenius on 2018-11-04.
//  Copyright © 2018 David Jensenius. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    var currentUser: CurrentUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        currentUser = CurrentUser.init(email: "david@example.com", password: "testing")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        currentUser?.logout()
    }

}
