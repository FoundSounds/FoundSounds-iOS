//
//  UserTest.swift
//  FoundSoundsTests
//
//  Created by David Jensenius on 2018-11-19.
//  Copyright © 2018 David Jensenius. All rights reserved.
//

import XCTest
import Mockingjay
@testable import FoundSounds

class CurrentUserAPIConsumerMock: CurrentUserDelegate {
    var didFinishCurrentUserClosure: ((Bool) -> Void)?
    func finishedLoggingIn(_ success: Bool) {
        didFinishCurrentUserClosure!(success)
    }

    func finishedLoggingOut(_ success: Bool) {
        didFinishCurrentUserClosure!(success)
    }
}

class CurrentUserTest: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoginSuccessExample() {
        let data = [ "username": "david" ]
        stub(uri("/users/sign_in.json"), json(data))
        let userExpectation = expectation(description: "Log in success")
        let consumer = CurrentUserAPIConsumerMock()
        let currentUser = CurrentUser.init(email: "david@test.com", password: "testing")
        currentUser.delegate = consumer
        consumer.didFinishCurrentUserClosure = { result in
            XCTAssertEqual(result, true)
            userExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func testLoginFailureExample() {
        let data = [ "error": "Cannot sign in" ]
        stub(uri("/users/sign_in.json"), json(data))
        let userExpectation = expectation(description: "Log in failure")
        let consumer = CurrentUserAPIConsumerMock()
        let currentUser = CurrentUser.init(email: "david@test.com", password: "testing")
        currentUser.delegate = consumer
        consumer.didFinishCurrentUserClosure = { result in
            XCTAssertEqual(result, false)
            userExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func testLogoutSuccessExample() {
        stub(uri("/users/sign_out.json"), json([]))
        let userExpectation = expectation(description: "Log out success")
        let consumer = CurrentUserAPIConsumerMock()
        let currentUser = CurrentUser()
        currentUser.logout()
        currentUser.delegate = consumer
        consumer.didFinishCurrentUserClosure = { result in
            XCTAssertEqual(result, true)
            userExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }
}
