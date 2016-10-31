//
//  ios_ci_sampleUITests.swift
//  ios-ci-sampleUITests
//
//  Created by Miklos Fazekas on 2016. 10. 19..
//  Copyright © 2016. Miklos Fazekas. All rights reserved.
//

import XCTest

class ios_ci_sampleUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    override func recordFailure(withDescription description: String, inFile filePath: String, atLine lineNumber: UInt, expected: Bool)
    {
        super.recordFailure(withDescription: description, inFile: filePath, atLine: lineNumber, expected: expected)
    }
    
    
    func testExample() {
        let app = XCUIApplication()
        percySnapshot(path:"before_tap")
        app.buttons["Say hello"].tap()
        percySnapshot(path:"after_tap")
        XCTAssertEqual("true", "true")
    }
    
}
