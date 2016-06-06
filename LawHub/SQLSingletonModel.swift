//
//  SQLSingletonModel.swift
//  LawHub
//
//  Created by Dylan Aird on 13/05/2016.
//  Copyright © 2016 Dylan Aird. All rights reserved.
//

import Foundation
import SQLite
import Firebase


class SQLSingletonModel{
    
    static let sharedManager = SQLSingletonModel();
    var databasePath:String!
    
    let rootRef = Firebase(url: "https://lawhubaus.firebaseio.com/")
    var wikiRef:Firebase!
    var topicsRef:Firebase!
    var subTopicsRef:Firebase!
    var sectionsRef:Firebase!
    var subInfoRef:Firebase!
    
    //articles database
    let articles = Table("articles")
    //make this the primary key
    let articleId = Expression<String>("articleid")
    let articleTitle = Expression<String>("articletitle")
    let articleText = Expression<String>("articletext")
    let articleTimeStamp = Expression<Double>("articletimestamp")
    let articleShortText = Expression<String>("articleshorttext")
    
    let firms = Table("firms")
    let firmId = Expression<String>("firmId")
    let firmName = Expression<String>("firmname")
    let firmAddress = Expression<String>("firmaddress")
    let firmOpenHours = Expression<String>("firmopenhours")
    let firmPhoneNumber = Expression<String>("firmphonenumber")
    let firmSpecialities = Expression<String>("firmspecialities")
    let firmWebsite = Expression<String>("firmwebsite")
    
    
    
    //wikidatabase broken down into multiple tables
    let topics = Table("topics")
    let topicId = Expression<String>("topicId")
    let topicName = Expression<String>("topicName")
    
    
    //Subtopics
    let subTopics = Table("subtopics")
    
    let subTopicId = Expression<String>("subtopicid")
    let subTopicName = Expression<String>("subtopicname")
    let subTopicInfo = Expression<String>("subtopicinfo")
    let subTopicParentKey = Expression<String>("subtopicparentkey")
    
    //sections
    let sections = Table("sections")
    
    let sectionsId = Expression<String>("sectionid")
    let sectionInfo = Expression<String>("sectioninfo")
    let sectionName = Expression<String>("sectionname")
    let sectionParentKey = Expression<String>("sectionparentkey")
    
    //subinfo
    let subInfo = Table("subinfo")
    
    let subInfoId = Expression<String>("subinfoid")
    let subInfoName = Expression<String>("subinfoname")
    let subInfoInfo = Expression<String>("subinfoinfo")
    let subInfoParentKey = Expression<String>("subinfoparentkey")
    
    //wiki version, keep track with local version vs cloud
    let wikiVersion = Table("wikiversion")
    let currentVersion = Expression<String>("currentversion")
    
    private init(){
        
        //let filemgr = NSFileManager.defaultManager()
        let dirPaths =
            NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
                                                .UserDomainMask, true)
        
        let docsDir = dirPaths[0]
        
        databasePath = (docsDir as NSString).stringByAppendingPathComponent(
            "lawhub-1.2.db")
        
        let db = try! Connection(databasePath)
        
        //create the tables for the data storage
        try! db.run(articles.create(ifNotExists: true) { t in
            t.column(articleId, primaryKey: true)
            t.column(articleTitle)
            t.column(articleText)
            t.column(articleShortText)
            t.column(articleTimeStamp)
            })
        
        try! db.run(topics.create(ifNotExists: true){t in
            t.column(topicId, primaryKey :true)
            t.column(topicName)
            })
        try! db.run(subTopics.create(ifNotExists: true){t in
            t.column(subTopicId, primaryKey:true)
            t.column(subTopicName)
            t.column(subTopicInfo)
            t.column(subTopicParentKey)
            })
        try! db.run(sections.create(ifNotExists: true){t in
            t.column(sectionsId, primaryKey:true)
            t.column(sectionName)
            t.column(sectionInfo)
            t.column(sectionParentKey)
            })
        
        try! db.run(subInfo.create(ifNotExists: true){t in
            t.column(subInfoId, primaryKey:true)
            t.column(subInfoName)
            t.column(subInfoInfo)
            t.column(subInfoParentKey)
            })
        
        try! db.run(firms.create(ifNotExists: true){t in
            t.column(firmId, primaryKey: true)
            t.column(firmName)
            t.column(firmAddress)
            t.column(firmOpenHours)
            t.column(firmPhoneNumber)
            t.column(firmWebsite)
            t.column(firmSpecialities)
            
            })
        try! db.run(wikiVersion.create(ifNotExists:true){t in
            t.column(currentVersion)
            })
        //set firebase refs
        wikiRef = rootRef.childByAppendingPath("wiki");
        topicsRef = wikiRef.childByAppendingPath("handbook")
        subTopicsRef = wikiRef.childByAppendingPath("subtopics")
        sectionsRef = wikiRef.childByAppendingPath("sections")
        subInfoRef = wikiRef.childByAppendingPath("subinfo")
        
        let row = self.wikiVersion.filter(self.currentVersion == "0.0")
        
        if try! db.run(row.update(self.currentVersion <- "0.0")) > 0{
        }else{
            try! db.run(self.wikiVersion.insert(self.currentVersion <- "0.0"))
        }
        
    }
    
    
    func compareDatabaseVersions(CompletionHandler:(result:Bool)->Void){
        
        let db = try! Connection(self.databasePath)
        
        var firebaseVersionNumber:Double!
        var localVersionNumber:Double!
        
        wikiRef.observeSingleEventOfType(.Value, withBlock: {snapshot in
            
            firebaseVersionNumber = snapshot.value["wikiversion"] as! Double
            
            let user = try! db.pluck(self.wikiVersion)
            localVersionNumber = Double((user?.get(self.currentVersion))!)
            
            if(firebaseVersionNumber > localVersionNumber){
                CompletionHandler(result: true)
            }else{
                CompletionHandler(result: false)
            }
            
            }, withCancelBlock: { error in
                print(error.description)
        })
        
    }
    
    func updateLocalDatabaseVersion(CompletionHandler:(result:Bool)->Void){
        
        let db = try! Connection(self.databasePath)
        
        var firebaseVersionNumber:Double!
        var localVersionNumber:Double!
        
        wikiRef.observeSingleEventOfType(.Value, withBlock: {snapshot in
            
            firebaseVersionNumber = snapshot.value["wikiversion"] as! Double
            
            let user = try! db.pluck(self.wikiVersion)
            
            localVersionNumber = Double((user?.get(self.currentVersion))!)
            
            let row = self.wikiVersion.filter(self.currentVersion == String(localVersionNumber))
            
            if(firebaseVersionNumber > localVersionNumber){
                if try! db.run(row.update( self.currentVersion <- String(firebaseVersionNumber) )) > 0{
                    print("updated")
                    CompletionHandler(result: true)
                }
                
            }else{
                CompletionHandler(result: false)
            }
            
            }, withCancelBlock: { error in
                print(error.description)
        })
        
    }
    
    func syncTopics(CompletionHandler:(result:Bool)->Void){
        
        let db = try! Connection(self.databasePath)
        
        topicsRef.observeSingleEventOfType(.Value, withBlock: {snapshot in
            for child in snapshot.children{
                let childSnapshot = snapshot.childSnapshotForPath(child.key)
                
                let row = self.topics.filter(self.topicId == child.key)
                let name = childSnapshot.value["name"] as! String
                let key = child.key as String
                if try! db.run(row.update(self.topicName <- name )) > 0{
                    
                }else{
                    //insert if firebase model does not exist in SQL
                    try! db.run(self.topics.insert(self.topicId <- key, self.topicName <- name))
                }
            }
            
            CompletionHandler(result: true)
            
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    

    
    func syncSubTopics(CompletionHandler:(result:Bool)->Void){
        
        let db = try! Connection(self.databasePath)
        
        subTopicsRef.observeSingleEventOfType(.Value, withBlock: {snapshot in
            for child in snapshot.children{
                //get firebase key
                let childSnapshot = snapshot.childSnapshotForPath(child.key)
                //filter the existing row using above key
                let row = self.subTopics.filter(self.subTopicId == child.key)
                
                
                //convert firebase varibles into strings
                let name = childSnapshot.value["name"] as! String
                let key = child.key as String
                let info = childSnapshot.value["info"] as! String
                let parentKey = childSnapshot.value["parentkey"] as! String
                
                
                if try! db.run(row.update(self.subTopicName <- name, self.subTopicInfo <- info, self.subTopicParentKey <- parentKey )) > 0{
                    
                }else{
                    //insert if firebase model does not exist in SQL
                    try! db.run(self.subTopics.insert(self.subTopicId <- key, self.subTopicName <- name, self.subTopicInfo <- info, self.subTopicParentKey <- parentKey))
                }
            }
            
            CompletionHandler(result: true)
            
            }, withCancelBlock: { error in
                print(error.description)
        })
        
    }
    
    func syncSections(CompletionHandler:(result:Bool)->Void){
        
        let db = try! Connection(self.databasePath)
        
        sectionsRef.observeSingleEventOfType(.Value, withBlock: {snapshot in
            for child in snapshot.children{
                //get firebase key
                let childSnapshot = snapshot.childSnapshotForPath(child.key)
                //filter the existing row using above key
                let row = self.sections.filter(self.sectionsId == child.key)
                
                
                //convert firebase varibles into strings
                let name = childSnapshot.value["name"] as! String
                let key = child.key as String
                let info = childSnapshot.value["info"] as! String
                let parentKey = childSnapshot.value["parentkey"] as! String
                
                
                if try! db.run(row.update(self.sectionName <- name, self.sectionInfo <- info, self.sectionParentKey <- parentKey )) > 0{
                    
                }else{
                    //insert if firebase model does not exist in SQL
                    try! db.run(self.sections.insert(self.sectionsId <- key, self.sectionName <- name, self.sectionInfo <- info, self.sectionParentKey <- parentKey))
                }
            }
            
            CompletionHandler(result: true)
            
            }, withCancelBlock: { error in
                print(error.description)
        })
        
    }
    
    func syncSubinfo(CompletionHandler:(result:Bool)->Void){
        let db = try! Connection(self.databasePath)
        
        subInfoRef.observeSingleEventOfType(.Value, withBlock: {snapshot in
            for child in snapshot.children{
                //get firebase key
                let childSnapshot = snapshot.childSnapshotForPath(child.key)
                //filter the existing row using above key
                let row = self.subInfo.filter(self.subInfoId == child.key)
                
                
                //convert firebase varibles into strings
                let name = childSnapshot.value["name"] as! String
                let key = child.key as String
                let info = childSnapshot.value["info"] as! String
                let parentKey = childSnapshot.value["parentkey"] as! String
                
                
                if try! db.run(row.update(self.subInfoName <- name, self.subInfoInfo <- info, self.subInfoParentKey <- parentKey )) > 0{
                    
                }else{
                    //insert if firebase model does not exist in SQL
                    try! db.run(self.subInfo.insert(self.subInfoId <- key, self.subInfoName <- name, self.subInfoInfo <- info, self.subInfoParentKey <- parentKey))
                }
            }
            
            CompletionHandler(result: true)
            
            }, withCancelBlock: { error in
                print(error.description)
        })
        
    }
    
    func updateDbFromFirebase()->Void{
        let db = try! Connection(databasePath)
        for item in SingletonModel.sharedManager.getArticleMemoryModel(){
        
            //grab every article in the memory model and push it to the sql database
            //this memory model is updated from firbase
            let row = articles.filter(articleId == item.1.getArticleId())
            
            if try! db.run(row.update(articleTitle <- item.1.getArticleName(), articleText <- item.1.getArticleText(), articleTimeStamp <- item.1.getEpoc())) > 0{
            
            }else{
                //insert if firebase model does not exist in SQL
                try! db.run(articles.insert(articleId <- item.1.getArticleId(), articleTitle <- item.1.getArticleName(), articleText <- item.1.getArticleText(), articleTimeStamp <- item.1.getEpoc(), articleShortText <- item.1.getArticleShortText()))
            
            }
        }
    }
    
    func getAllTopics()->Array<SubtopicModel>{
        let db = try! Connection(self.databasePath)
        
        var topicsArray:Array<SubtopicModel> = []
        
        for item in try! db.prepare(topics) {
            
            let model:SubtopicModel = SubtopicModel(k: item[topicId], n: item[topicName])
            topicsArray.append(model)
        }
        return topicsArray
        
    }
    func getAllSubTopics(s:String)->Array<SubtopicModel>{
        let db = try! Connection(self.databasePath)
        
        var topicsArray:Array<SubtopicModel> = []
        let row = self.subTopics.filter(self.subTopicParentKey == s)
        
        
        for item in try! db.prepare(row) {
            let model:SubtopicModel = SubtopicModel(k: item[subTopicId], n: item[subTopicName], i: item[subTopicInfo])
            topicsArray.append(model)
        }
        return topicsArray
        
    }
    
    func getAllSections(s:String)->Array<SubtopicModel>{
        let db = try! Connection(self.databasePath)
        
        var topicsArray:Array<SubtopicModel> = []
        let row = self.sections.filter(self.sectionParentKey == s)
        

        for item in try! db.prepare(row) {
            print("here")
            let model:SubtopicModel = SubtopicModel(k: item[sectionsId], n: item[sectionName],i: item[sectionInfo])
            topicsArray.append(model)
        }
        return topicsArray
        
    }
    
    func searchFirmTable(searchTerm:String)->Array<FirmModel>{
    
    let db = try! Connection(self.databasePath)
        
        var firmArray:Array<FirmModel> = []
        let row = self.firms.filter(firmName.like(searchTerm + "%"))
        
        for item in try! db.prepare(row) {
            let specialitiesArray = item[firmSpecialities].componentsSeparatedByString("\n")
            let model:FirmModel = FirmModel(id: item[firmId], n: item[firmName], num: item[firmPhoneNumber], w: item[firmWebsite], o: item[firmOpenHours], a: item[firmAddress], s: specialitiesArray)
            firmArray.append(model)
        }
        return firmArray
    }
    
    func pushFirmToDb(model:FirmModel)->Void{
        
        let db = try! Connection(self.databasePath)
        
        let row = firms.filter(firmId == model.getId())
        
        if try! db.run(row.update(firmName <- model.getName(),  firmAddress <- model.getAddress(), firmOpenHours <- model.getOpenHours(), firmPhoneNumber <- model.getPhoneNum(), firmWebsite <- model.getWebsite(), firmSpecialities <- model.getSpecialties())) > 0{
            
        }else{
            //insert if firebase model does not exist in SQL
            try! db.run(firms.insert(firmId <- model.getId(), firmName <- model.getName(),  firmAddress <- model.getAddress(), firmOpenHours <- model.getOpenHours(), firmPhoneNumber <- model.getPhoneNum(), firmWebsite <- model.getWebsite(), firmSpecialities <- model.getSpecialties()))
            
        }
    }
    
    func pushArticleToDb(model:ArticleModel)->Void{
        let db = try! Connection(databasePath)
        
        
        //grab every article in the memory model and push it to the sql database
        //this memory model is updated from firbase
        let row = articles.filter(articleId == model.getArticleId())
        
        if try! db.run(row.update(articleTitle <- model.getArticleName(), articleText <- model.getArticleText(), articleTimeStamp <- model.getEpoc(), articleShortText <- model.getArticleShortText())) > 0{
            
        }else{
            //insert if firebase model does not exist in SQL
            try! db.run(articles.insert(articleId <- model.getArticleId(), articleTitle <- model.getArticleName(), articleText <- model.getArticleText(), articleTimeStamp <- model.getEpoc(), articleShortText <- model.getArticleShortText()))
            
        }
    }
    
    func getAllSubinfo(s:String)->Array<SubtopicModel>{
        let db = try! Connection(self.databasePath)
        
        var topicsArray:Array<SubtopicModel> = []
        let row = self.subInfo.filter(self.subInfoParentKey == s)
        
        
        for item in try! db.prepare(row) {
            let model:SubtopicModel = SubtopicModel(k: item[subInfoId], n: item[subInfoName],i: item[subInfoInfo])
            topicsArray.append(model)
        }
        return topicsArray
    }
    
    func getAllArticles()->Bool{
        let db = try! Connection(databasePath)
        
        for article in try! db.prepare(articles) {
            
            let model:ArticleModel = ArticleModel(id:article[articleId], n:article[articleTitle], t:article[articleText], epoc:article[articleTimeStamp],st: article[articleShortText])
            
            SingletonModel.sharedManager.addArticleToMemory(model)
        }
    
        return true
    }
}