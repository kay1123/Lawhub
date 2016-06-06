//
//  LawHubTests.swift
//  LawHubTests
//
//  Created by Dylan Aird on 1/04/2016.
//  Copyright © 2016 Dylan Aird. All rights reserved.
//

import XCTest
@testable import LawHub

class LawHubTests: XCTestCase {
    
    var articleModel:ArticleModel!
    var firmModel:FirmModel!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func createModels() {
       
        articleModel = ArticleModel(id: "thisisanid", n: "Test", t: "More text", epoc: 123.312, st: "More Stuff")
        XCTAssertEqual(articleModel.getArticleId(), "thisisanid")
        firmModel = FirmModel(id: "anotherid", n: "firm name", num: "1800555777", w: "www.example.com", o: "9-5", a: "an address", s: ["hello", "world"])
        XCTAssertEqual(firmModel.getWebsite(), "www.example.com")
    
        
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func ModelsToMemoryAndMore(){
        SingletonModel.sharedManager.addtoFirmMemory(firmModel)
        SingletonModel.sharedManager.addArticleToMemory(articleModel)
        
        //pull model back and check it against a new model
        let firm2 = SingletonModel.sharedManager.getFirmWithId(firmModel.getId())
        XCTAssertEqual(firm2.getName(), firmModel.getName())
        
        //change name of model object
        firm2.setName("new Name")
        SingletonModel.sharedManager.addtoFirmMemory(firm2)
        XCTAssertNotEqual(SingletonModel.sharedManager.getFirmWithId(firm2.getId()).getName(), firmModel.getName())
        
    }
    
    func initDataBase(){
        //init singleton
        SQLSingletonModel.sharedManager
        //push some test data
        SQLSingletonModel.sharedManager.pushFirmToDb(self.firmModel)
        SQLSingletonModel.sharedManager.pushArticleToDb(self.articleModel)
        
        //will return true because one article exists
        XCTAssertTrue(SQLSingletonModel.sharedManager.getAllArticles())
    }
    
    
    func getDataBaseModel(){
        let launch:LaunchScreen = LaunchScreen()
        
       launch.syncDatabases(){(result)-> Void in
            if(result){
                let topicArray = SQLSingletonModel.sharedManager.getAllTopics()
                XCTAssertNotNil(topicArray)
                print(topicArray.count)
            }else{
                
            }
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
}