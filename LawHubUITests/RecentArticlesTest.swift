//
//  RecentArticlesTest.swift
//  LawHub
//
//  Created by Dylan Aird on 7/04/2016.
//  Copyright © 2016 Dylan Aird. All rights reserved.
//

import XCTest

class RecentArticlesTest: XCTestCase {
        
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
        
        
        
        let app = XCUIApplication()
        let cellsQuery = app.collectionViews.cells
        let didYouKnowElement = cellsQuery.otherElements.containingType(.StaticText, identifier:"Did You Know?").element
        didYouKnowElement.tap()
        didYouKnowElement.tap()
        didYouKnowElement.tap()
        cellsQuery.otherElements.containingType(.StaticText, identifier:"Downloading Music Or Films").element.tap()
        app.navigationBars["Downloading Music Or Films"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
        
        let websiteDesignElement = cellsQuery.otherElements.containingType(.StaticText, identifier:"Website Design").element
        websiteDesignElement.tap()
        app.navigationBars["Website Design"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
        app.navigationBars["Recent Articles"].childrenMatchingType(.Button).elementBoundByIndex(1).tap()
        app.navigationBars["Settings"].buttons["Cancel"].tap()
        XCUIDevice.sharedDevice().orientation = .Portrait
        XCUIDevice.sharedDevice().orientation = .LandscapeRight
        
        let lightbulbElement = cellsQuery.otherElements.containingType(.Button, identifier:"lightbulb").element
        lightbulbElement.tap()
        lightbulbElement.tap()
        
        let downloadingMusicOrFilmsElement = cellsQuery.otherElements.containingType(.StaticText, identifier:"Downloading Music Or Films").element
        downloadingMusicOrFilmsElement.tap()
                app.navigationBars["Downloading Music Or Films"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
        cellsQuery.otherElements.containingType(.StaticText, identifier:"Website Design").element.tap()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.TextView).element.tap()
        app.navigationBars["Website Design"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
        downloadingMusicOrFilmsElement.tap()
        app.navigationBars["Downloading Music Or Films"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
        XCUIDevice.sharedDevice().orientation = .Portrait
        
        
        
        
    }
    
}
