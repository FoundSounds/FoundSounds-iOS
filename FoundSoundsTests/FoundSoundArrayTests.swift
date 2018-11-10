//
//  FoundSoundArrayTests.swift
//  FoundSoundsTests
//
//  Created by David Jensenius on 2018-11-09.
//

import XCTest
import Mockingjay
import MapKit
@testable import FoundSounds

class FoundSoundsArrayAPIConsumerMock: FoundSoundArrayDelegate {
    var didRetrieveFoundSoundArrayClosure: (([FoundSound]) -> Void)?
    func finishedLoadingSoundArray(_ sounds: [FoundSound]!) {
        didRetrieveFoundSoundArrayClosure!(sounds)
    }
}

class FoundSoundArrayTests: XCTestCase {

    var data: Data!
    var fsc = FoundSoundArray()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let url = Bundle(for: type(of: self)).url(forResource: "recent", withExtension: "json")!
        data = Data()
        do {
            data = try Data(contentsOf: url)
        } catch {
            print("Cannot find contents of \(url)")
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoadingSoundArray() {
       for (stream, url) in soundTypes() {
            stub(uri(url), jsonData(data))
            let foundSoundArrayExpectation = expectation(description: "Get \(stream) sounds to load")
            let consumer = FoundSoundsArrayAPIConsumerMock()
            let currentSounds = FoundSoundArray(stream: stream)
            currentSounds.delegate = consumer
            consumer.didRetrieveFoundSoundArrayClosure = { sounds in
                XCTAssertEqual(sounds.count, 2)
                foundSoundArrayExpectation.fulfill()
            }
            waitForExpectations(timeout: 1.0)
        }
    }

    func testLoadingUserSoundArray() {
        for (stream, url) in soundUserTypes() {
            stub(uri(url), jsonData(data))
            let foundSoundArrayExpectation = expectation(description: "Get \(stream) sounds to load")
            let consumer = FoundSoundsArrayAPIConsumerMock()
            let currentSounds = FoundSoundArray(stream: stream, user: 1)
            currentSounds.delegate = consumer
            consumer.didRetrieveFoundSoundArrayClosure = { sounds in
                XCTAssertNoThrow(currentSounds.writeCacheData(self.data))
                XCTAssertEqual(sounds.count, 2)
                foundSoundArrayExpectation.fulfill()
            }
            waitForExpectations(timeout: 1.0)
        }
    }

    func testPublicMaps() {
        stub(uri("/api/mapmarkers"), jsonData(data))
        let foundSoundArrayExpectation = expectation(description: "Get public map sounds to load")
        let consumer = FoundSoundsArrayAPIConsumerMock()
        let currentSounds = FoundSoundArray(
            publicMapNECoord: CLLocationCoordinate2DMake(0, 0),
            NWCoord: CLLocationCoordinate2DMake(0, 0),
            SECoord: CLLocationCoordinate2DMake(0, 0),
            SWCoord: CLLocationCoordinate2DMake(0, 0)
        )
        currentSounds.delegate = consumer
        consumer.didRetrieveFoundSoundArrayClosure = { sounds in
            XCTAssertEqual(sounds.count, 2)
            foundSoundArrayExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func testPrivateMaps() {
        stub(uri("/iosuser/mapmakers"), jsonData(data))
        let foundSoundArrayExpectation = expectation(description: "Get private map sounds to load")
        let consumer = FoundSoundsArrayAPIConsumerMock()
        let currentSounds = FoundSoundArray(
            mapNECoord: CLLocationCoordinate2DMake(0, 0),
            NWCoord: CLLocationCoordinate2DMake(0, 0),
            SECoord: CLLocationCoordinate2DMake(0, 0),
            SWCoord: CLLocationCoordinate2DMake(0, 0)
        )
        currentSounds.delegate = consumer
        consumer.didRetrieveFoundSoundArrayClosure = { sounds in
            XCTAssertEqual(sounds.count, 2)
            foundSoundArrayExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func testWalkCoords() {
        stub(uri("/iosuser/walk"), jsonData(data))
        let foundSoundArrayExpectation = expectation(description: "Get walk sounds to load")
        let consumer = FoundSoundsArrayAPIConsumerMock()
        let currentSounds = FoundSoundArray(walkCoord: CLLocation(latitude: 0, longitude: 0))
        currentSounds.delegate = consumer
        consumer.didRetrieveFoundSoundArrayClosure = { sounds in
            XCTAssertEqual(sounds.count, 2)
            foundSoundArrayExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func testListOfNearbySounds() {
        stub(uri("/api/nearby"), jsonData(data))
        let foundSoundArrayExpectation = expectation(description: "Get nearby sounds to load")
        let consumer = FoundSoundsArrayAPIConsumerMock()
        let currentSounds = FoundSoundArray(listOfNearbySounds: CLLocation(latitude: 0, longitude: 0))
        currentSounds.delegate = consumer
        consumer.didRetrieveFoundSoundArrayClosure = { sounds in
            XCTAssertEqual(sounds.count, 2)
            foundSoundArrayExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func testCache() {
        stub(uri("/stream/mysounds"), jsonData(data))
        let foundSoundArrayExpectation = expectation(description: "Get mysounds sounds to load")

        let cacheConsumer = FoundSoundsArrayAPIConsumerMock()
        cacheConsumer.didRetrieveFoundSoundArrayClosure = { sounds in
            XCTAssertEqual(sounds.count, 2)
            foundSoundArrayExpectation.fulfill()
        }

        let consumer = FoundSoundsArrayAPIConsumerMock()
        let currentSounds = FoundSoundArray(stream: "mysounds", user: 1)
        currentSounds.delegate = consumer
        consumer.didRetrieveFoundSoundArrayClosure = { sounds in
            XCTAssertNoThrow(currentSounds.writeCacheData(self.data))
            let cacheSounds = FoundSoundArray.init(cache: "mysounds", cacheDelegate: cacheConsumer)
            cacheSounds.delegate = cacheConsumer
        }
        waitForExpectations(timeout: 5.0)
    }

    func testGetCacheStream() {
        stub(uri("/stream/mysounds"), jsonData(data))
        let foundSoundArrayExpectation = expectation(description: "Get cached sound stream to load")
        let consumer = FoundSoundsArrayAPIConsumerMock()
        let currentSounds = FoundSoundArray(stream: "mysounds", user: 1)
        currentSounds.delegate = consumer
        consumer.didRetrieveFoundSoundArrayClosure = { sounds in
            XCTAssertNoThrow(currentSounds.writeCacheData(self.data))
            let cachedSounds = FoundSoundArray()
            cachedSounds.streamType = "mysounds"
            cachedSounds.getCacheStream()
            XCTAssertEqual(cachedSounds.FSArray.count, 2)
            foundSoundArrayExpectation.fulfill()
        }
        waitForExpectations(timeout: 5.0)
    }

    func soundTypes() -> [String: String] {
        return [
            "favorites": "/stream/favorites",
            "mysounds": "/stream/mysounds",
            "soundStream": "/stream/api",
            "recentPublic": "/api/recent"
        ]
    }

    func soundUserTypes() -> [String: String] {
        return [
            "soundsByUser": "/stream/usersounds/1",
            "favoritesByUser": "/stream/userfavorited/1",
            "favoritedByUser": "/stream/userfavorites/1"
        ]
    }
}
