//
//  SubtopicModel.swift
//  LawHub
//
//  Created by Dylan Aird on 15/05/2016.
//  Copyright © 2016 Dylan Aird. All rights reserved.
//

import Foundation

class SubtopicModel{
    private var key:String!
    private var name:String!
    private var info:String!
    private var parentKey:String!
    private var sections:Array<String>!

    init(k:String,  n:String){
        self.key = k
        self.name = n
    }
    
    convenience init(k:String, n:String, i:String, p:String, s:Array<String>){
        self.init(k: k, n: n)
        self.info = i
        self.parentKey = p
        self.sections = s
        
    }
    
    convenience init (k:String, n:String, i:String){
        self.init(k: k, n: n)
        self.info = i
    }
    
    func getKey()->String{
        return self.key!
    }
    func getInfo()->String{
        return self.info!
    }
    func getName()->String{
        return self.name!
    }
    func getSectionKeys()->Array<String>{
        return self.sections
    }
}