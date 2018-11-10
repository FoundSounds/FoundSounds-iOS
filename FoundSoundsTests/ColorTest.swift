//
//  ColorTest.swift
//  FoundSoundsTests
//
//  Created by David Jensenius on 2018-11-10.
//  Copyright © 2018 David Jensenius. All rights reserved.
//

import XCTest

class ColorTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPrimaryColor() {
        XCTAssertEqual(
            UIColor.primaryColor(),
            UIColor(red: 235.0/255.0, green: 96.0/255.0, blue: 67.0/255.0, alpha: 1.0)
        )
    }

    func testContrastingComplementColor() {
        XCTAssertEqual(
            UIColor.contrastingComplementColor(),
            UIColor(red: 170.0/255.0, green: 69.0/255.0, blue: 49.0/255.0, alpha: 1.0)
        )
    }

    func testBackgroundColor() {
        XCTAssertEqual(
            UIColor.backgroundColor(),
            UIColor(red: 229.0/255.0, green: 224.0/255.0, blue: 220.0/255.0, alpha: 1.0)
        )
    }

    func testprimaryText() {
        XCTAssertEqual(
            UIColor.primaryText(),
            UIColor(red: 87.0/255.0, green: 87.0/255.0, blue: 87.0/255.0, alpha: 1.0)
        )
    }

    func testSecondaryText() {
        XCTAssertEqual(
            UIColor.secondaryText(),
            UIColor(red: 162.0/255.0, green: 163.0/255.0, blue: 163.0/255.0, alpha: 1.0)
        )
    }
}
