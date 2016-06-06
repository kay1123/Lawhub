//
//  ArticleModel.swift
//  LawHub
//
//  Created by Dylan Aird on 19/05/2016.
//  Copyright © 2016 Dylan Aird. All rights reserved.
//

import Foundation

class ArticleModel{
    private var articleId: String
    private var articleName:String
    private var articleText:String
    private var articleEpoc:Double
    private var articleShortText:String = ""
    
    
    init(id:String, n:String, t:String, epoc:Double, st:String){
        self.articleName = n
        self.articleText = t
        self.articleEpoc = epoc
        self.articleId = id
        self.articleShortText = st
    }
    
    func setShortText(text:String){
        self.articleShortText = text
        
    }
    func getArticleName() -> String{
        return self.articleName
    }
    
    func getArticleShortText() ->String{
        return self.articleShortText
    }
    
    func getArticleText() -> String{
        return self.articleText
    }
    
    func getEpoc() -> Double{
        return self.articleEpoc
    }
    func getArticleId()->String{
        return self.articleId
    }
    func setArticleName(s:String)->Void{
        self.articleName = s
    }
    func setArticleText(s:String)->Void{
        self.articleText = s
    }
    func setArticleId(s:String)->Void{
        self.articleId = s
    }
    func setArticleShortText(s:String)->Void{
        self.articleShortText = s
}

}