//
//  FoundSoundsTests.swift
//  FoundSoundsTests
//
//  Created by David Jensenius on 2018-11-04.
//  Copyright © 2018 David Jensenius. All rights reserved.
//

import XCTest
import Mockingjay
@testable import FoundSounds

class FoundSoundInitSoundIDAPIConsumerMock: FoundSoundDelegate {
    var didFoundSoundInitSoundIDClosure: ((FoundSound) -> Void)?
    func finishedLoadingSound(_ sound: FoundSound) {
        didFoundSoundInitSoundIDClosure!(sound)
    }

    var didFoundSoundInitStringClosure: ((String) -> Void)?
    func finishedLoadingLikes(_ likedBy: String) {
        didFoundSoundInitStringClosure!(likedBy)
    }

    var didFoundSoundBoolClosure: ((Bool) -> Void)?
    func finishedRemovingSound(_ success: Bool) {
        didFoundSoundBoolClosure!(success)
    }

    func finishedMakingSoundPrivate(_ success: Bool) {
        didFoundSoundBoolClosure!(success)
    }

    func finishedMakingSoundPublic(_ success: Bool) {
        didFoundSoundBoolClosure!(success)
    }
}

class FoundSoundsTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFoundSoundInitSoundID() {
        let url = Bundle(for: type(of: self)).url(forResource: "sound", withExtension: "json")!
        var data = Data()
        do {
            data = try Data(contentsOf: url)
        } catch {
            print("Cannot find contents of \(url)")
        }
        stub(uri("/iosuser/getsound"), jsonData(data))
        let foundSoundExpectation = expectation(description: "Load sound for user")
        let consumer = FoundSoundInitSoundIDAPIConsumerMock()
        let sound = FoundSound(soundID: 1)
        sound.delegate = consumer
        consumer.didFoundSoundInitSoundIDClosure = { sound in
            XCTAssertEqual(sound.country, "Japan")
            foundSoundExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func testGetLikedByOne() {
        let url = Bundle(for: type(of: self)).url(forResource: "OneLike", withExtension: "json")!
        var data = Data()
        do {
            data = try Data(contentsOf: url)
        } catch {
            print("Cannot find contents of \(url)")
        }
        stub(uri("/iosuser/getlike"), jsonData(data))
        let foundSoundExpectation = expectation(description: "Get sound liked by")
        let consumer = FoundSoundInitSoundIDAPIConsumerMock()
        let sound = FoundSound.init()
        sound.getLikedBy(1)
        sound.delegate = consumer
        consumer.didFoundSoundInitStringClosure = { likedBy in
            XCTAssertEqual(likedBy, "Liked by Test User")
            foundSoundExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func testGetLikedByMany() {
        let url = Bundle(for: type(of: self)).url(forResource: "TwoLikes", withExtension: "json")!
        var data = Data()
        do {
            data = try Data(contentsOf: url)
        } catch {
            print("Cannot find contents of \(url)")
        }
        stub(uri("/iosuser/getlike"), jsonData(data))
        let foundSoundExpectation = expectation(description: "Get sound liked by")
        let consumer = FoundSoundInitSoundIDAPIConsumerMock()
        let sound = FoundSound.init()
        sound.getLikedBy(1)
        sound.delegate = consumer
        consumer.didFoundSoundInitStringClosure = { likedBy in
            XCTAssertEqual(likedBy, "Liked by Test User, Test User 2")
            foundSoundExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func testGetRandom() {
        let url = Bundle(for: type(of: self)).url(forResource: "sound", withExtension: "json")!
        var data = Data()
        do {
            data = try Data(contentsOf: url)
        } catch {
            print("Cannot find contents of \(url)")
        }
        stub(uri("/api/random"), jsonData(data))
        let foundSoundExpectation = expectation(description: "Load random sound")
        let consumer = FoundSoundInitSoundIDAPIConsumerMock()
        let sound = FoundSound()
        sound.getRandom()
        sound.delegate = consumer
        consumer.didFoundSoundInitSoundIDClosure = { sound in
            XCTAssertEqual(sound.country, "Japan")
            foundSoundExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func testDeleteSound() {
        let encoder = JSONEncoder()
        var data = Data()
        do {
            try data = encoder.encode(["deletesuccess": "success"])
        } catch { print("Could not encode") }
        stub(uri("/iosuser/remove"), jsonData(data))
        let foundSoundExpectation = expectation(description: "Delete sound succeeded")
        let consumer = FoundSoundInitSoundIDAPIConsumerMock()
        let sound = FoundSound()
        sound.deleteSound(1)
        sound.delegate = consumer
        consumer.didFoundSoundBoolClosure = { success in
            XCTAssertEqual(success, true)
            foundSoundExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func testDeleteSoundFailure() {
        let encoder = JSONEncoder()
        var data = Data()
        do {
            try data = encoder.encode(["deletesuccess": "failure"])
        } catch { print("Could not encode") }
        stub(uri("/iosuser/remove"), jsonData(data))
        let foundSoundExpectation = expectation(description: "Delete sound failed")
        let consumer = FoundSoundInitSoundIDAPIConsumerMock()
        let sound = FoundSound()
        sound.deleteSound(1)
        sound.delegate = consumer
        consumer.didFoundSoundBoolClosure = { success in
            XCTAssertEqual(success, false)
            foundSoundExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func testMarkSoundPrivate() {
        let encoder = JSONEncoder()
        var data = Data()
        do {
            try data = encoder.encode(["privatesuccess": "success"])
        } catch { print("Could not encode") }
        stub(uri("/iosuser/make_private"), jsonData(data))
        let foundSoundExpectation = expectation(description: "Make sound private succeeded")
        let consumer = FoundSoundInitSoundIDAPIConsumerMock()
        let sound = FoundSound()
        sound.markSoundPrivate(1)
        sound.delegate = consumer
        consumer.didFoundSoundBoolClosure = { success in
            XCTAssertEqual(success, true)
            foundSoundExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func testMarkSoundPrivateFailed() {
        let encoder = JSONEncoder()
        var data = Data()
        do {
            try data = encoder.encode(["privatesuccess": "failure"])
        } catch { print("Could not encode") }
        stub(uri("/iosuser/make_private"), jsonData(data))
        let foundSoundExpectation = expectation(description: "Make sound private failed")
        let consumer = FoundSoundInitSoundIDAPIConsumerMock()
        let sound = FoundSound()
        sound.markSoundPrivate(1)
        sound.delegate = consumer
        consumer.didFoundSoundBoolClosure = { success in
            XCTAssertEqual(success, false)
            foundSoundExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func testMarkSoundPublic() {
        let encoder = JSONEncoder()
        var data = Data()
        do {
            try data = encoder.encode(["publicsuccess": "success"])
        } catch { print("Could not encode") }
        stub(uri("/iosuser/make_public"), jsonData(data))
        let foundSoundExpectation = expectation(description: "Make sound private succeeded")
        let consumer = FoundSoundInitSoundIDAPIConsumerMock()
        let sound = FoundSound()
        sound.markSoundPublic(1)
        sound.delegate = consumer
        consumer.didFoundSoundBoolClosure = { success in
            XCTAssertEqual(success, true)
            foundSoundExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func testMarkSoundPublicFailed() {
        let encoder = JSONEncoder()
        var data = Data()
        do {
            try data = encoder.encode(["publicsuccess": "failure"])
        } catch { print("Could not encode") }
        stub(uri("/iosuser/make_public"), jsonData(data))
        let foundSoundExpectation = expectation(description: "Make sound private failed")
        let consumer = FoundSoundInitSoundIDAPIConsumerMock()
        let sound = FoundSound()
        sound.markSoundPublic(1)
        sound.delegate = consumer
        consumer.didFoundSoundBoolClosure = { success in
            XCTAssertEqual(success, false)
            foundSoundExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func testLogPlay() {
        let sound = FoundSound()
        XCTAssertNoThrow(sound.logPlay(1, withType: "test"))
    }
}
