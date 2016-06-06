//
//  SingletonModel.swift
//  LawHub
//
//  Created by Dylan Aird on 11/05/2016.
//  Copyright © 2016 Dylan Aird. All rights reserved.
//

import Foundation

class SingletonModel {
    
    //declare the three dictionaries containing my memory objects
    var firmMemoryModel:Dictionary = Dictionary<String, FirmModel>();
    var lawyerMemoryModel:Dictionary = Dictionary<String, LawyerModel>();
    var articleMemoryModel:Dictionary = Dictionary<String, ArticleModel>();
    
    
    static let sharedManager = SingletonModel();
    
    //private init constructor so it can only be created once
    private init(){}
    
    func addtoFirmMemory(firm:FirmModel) -> Bool{
        if((self.firmMemoryModel.updateValue(firm, forKey: firm.getId())) != nil){
            return true;
        }
        return false;
    }
    
    func removeFromFirmMemory(firmId:String) -> Bool{
        if (self.firmMemoryModel.removeValueForKey(firmId) != nil) {
            return true;
        }
        return false;
    
    }
    
    func getFirmWithId(id:String)->FirmModel{
        return self.firmMemoryModel[id]!;
    
    }
    
    func getLawyerWithId(id:String)->LawyerModel{
        return self.lawyerMemoryModel[id]!;
    }
    
    func addtoLawyerMemory(lawyer:LawyerModel) -> Bool{
        if((self.lawyerMemoryModel.updateValue(lawyer, forKey: lawyer.getId())) != nil){
            return true;
        }
        return false;
    }
    func getArticleMemoryModel()->Dictionary<String, ArticleModel>{
        return self.articleMemoryModel
    }
    func addArticleToMemory(m:ArticleModel)->Bool{
        if((self.articleMemoryModel.updateValue(m, forKey: m.getArticleId())) != nil){
            return true;
        }
        return false;
    
    }
    
}
