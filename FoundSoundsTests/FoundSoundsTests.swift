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

class FoundSoundsArrayAPIConsumerMock: FoundSoundArrayDelegate {
    var didRetrieveFoundSoundArrayClosure: (([FoundSound]) -> Void)?
    func finishedLoadingSoundArray(_ sounds: [FoundSound]!) {
        didRetrieveFoundSoundArrayClosure!(sounds)
    }
}

class FoundSoundInitSoundIDAPIConsumerMock: FoundSoundDelegate {
    var didFoundSoundInitSoundIDClosure: ((FoundSound) -> Void)?
    func finishedLoadingSound(_ sound: FoundSound) {
        didFoundSoundInitSoundIDClosure!(sound)
    }

    func finishedLoadingLikes(_ likedBy: String) {
    }

    func finishedRemovingSound(_ success: Bool) {
    }

    func finishedMakingSoundPrivate(_ success: Bool) {
    }

    func finishedMakingSoundPublic(_ success: Bool) {
    }
}

class FoundSoundsTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
    }

    func matcher(request: NSURLRequest) -> Bool {
        return true  // Let's match this request
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoadingPublicRecentSounds() {
        let url = Bundle(for: type(of: self)).url(forResource: "recent", withExtension: "json")!
        var data = Data()
        do {
            data = try Data(contentsOf: url)
        } catch {
            print("Cannot find contents of \(url)")
        }
        stub(uri("/api/recent"), jsonData(data))
        let foundSoundArrayExpectation = expectation(description: "Get public sounds to load")
        let consumer = FoundSoundsArrayAPIConsumerMock()
        let currentSounds = FoundSoundArray(stream: "recentPublic")
        currentSounds.delegate = consumer
        consumer.didRetrieveFoundSoundArrayClosure = { sounds in
            XCTAssertEqual(sounds.count, 2)
            foundSoundArrayExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
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

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
