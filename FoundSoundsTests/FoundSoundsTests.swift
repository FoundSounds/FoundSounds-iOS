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

class FoundSoundsTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        let url = Bundle(for: type(of: self)).url(forResource: "recent", withExtension: "json")!
        var data = Data()
        do {
            data = try Data(contentsOf: url)
        } catch {
            print("Cannot find contents of \(url)")
        }
        stub(uri("/api/recent"), jsonData(data))
    }

    func matcher(request: NSURLRequest) -> Bool {
        return true  // Let's match this request
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoadingPublicRecentSounds() {
        let foundSoundArrayExpectation = expectation(description: "beep boop")
        let consumer = FoundSoundsArrayAPIConsumerMock()
        let currentSounds = FoundSoundArray(stream: "recentPublic")
        currentSounds.delegate = consumer
        consumer.didRetrieveFoundSoundArrayClosure = { sounds in
            XCTAssertEqual(sounds.count, 2)
            foundSoundArrayExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
