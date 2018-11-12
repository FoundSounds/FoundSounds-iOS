//
//  GraphQLExampleTest.swift
//  FoundSoundsTests
//
//  Created by David Jensenius on 2018-11-12.
//  Copyright © 2018 David Jensenius. All rights reserved.
//

import XCTest
@testable import FoundSounds
import Apollo

class GraphQLExampleTest: XCTestCase {
    func testGraphQL() {
        let example = GraphQLExample()
        let networkTransport = MockNetworkTransport(body:
            [
                "data": [
                    "sound": [
                        "__typename": "SoundType",
                        "id": "6",
                        "latitude": 72.1060423834631,
                        "user": [
                            "__typename": "UserType",
                            "id": "2",
                            "email": "test@tes.com"
                        ],
                        "longitude": -37.2403820346771
                    ]
                ]
            ]
        )
        let foundSoundExpectation = expectation(description: "Load sound from GraphQL")
        let closure: (ExampleQuery.Data) -> Void = { (sound) in
            dump(sound)
            foundSoundExpectation.fulfill()
        }
        example.getExampleQuery(networkTransport: networkTransport, closure: closure)
        waitForExpectations(timeout: 5.0)
    }
}
