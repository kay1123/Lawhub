//
//  LawyerTest.swift
//  LawHub
//
//  Created by Dylan Aird on 8/04/2016.
//  Copyright © 2016 Dylan Aird. All rights reserved.
//

import XCTest

class LawyerTest: XCTestCase {
        
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
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCUIDevice.sharedDevice().orientation = .Portrait
        
        let app = XCUIApplication()
        app.tabBars.buttons["Lawyers"].tap()
        
        let cell = app.tables.childrenMatchingType(.Cell).elementBoundByIndex(0)
        cell.staticTexts["Craigs Firm"].tap()
        
        let craigsFirmStaticText = cell.childrenMatchingType(.StaticText).matchingIdentifier("Craigs Firm").elementBoundByIndex(0)
        craigsFirmStaticText.tap()
        craigsFirmStaticText.tap()
        cell.buttons["Lawyers"].tap()
        let cellsQuery = app.collectionViews.cells
        let firstLawyerElement = cellsQuery.elementBoundByIndex(0)
        
        firstLawyerElement.tap()
        XCUIApplication().scrollViews.otherElements.buttons["close"].tap()
        
        let secondLawyerElement = cellsQuery.elementBoundByIndex(1)
        
        secondLawyerElement.tap()
        
        XCUIApplication().scrollViews.otherElements.buttons["close"].tap()
        
        
        
        XCUIDevice.sharedDevice().orientation = .LandscapeRight
        
        let thirdLawyerElement = cellsQuery.elementBoundByIndex(2)
        
        thirdLawyerElement.tap()
        XCUIApplication().scrollViews.otherElements.buttons["close"].tap()
        
        app.tabBars.buttons["Lawyers"].tap()
        
        XCUIDevice.sharedDevice().orientation = .Portrait
     
        
    }
    
}
