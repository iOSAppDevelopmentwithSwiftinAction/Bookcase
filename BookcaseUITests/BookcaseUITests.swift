//
//  BookcaseUITests.swift
//  BookcaseUITests
//
//  Created by Craig Grummitt on 10/05/2016.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import XCTest

class BookcaseUITests: XCTestCase {
        
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

    func testToggleISBN() {
        
        let app = XCUIApplication()
        app.navigationBars["Books"].buttons["Add"].tap()
        
        let elementsQuery = app.scrollViews.otherElements
        let isbnExists = elementsQuery.staticTexts["ISBN:"].exists
        elementsQuery.buttons["More Info"].tap()
        XCTAssertNotEqual(elementsQuery.staticTexts["ISBN:"].exists, isbnExists)
        
    }
    
}
