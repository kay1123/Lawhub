//
//  FirmModel.swift
//  LawHub
//
//  Created by Dylan Aird on 3/04/2016.
//  Copyright © 2016 Dylan Aird. All rights reserved.
//

import Foundation

class FirmModel {
    private var firmName:String
    private var firmNumber:String
    private var firmWebsite:String
    private var firmOpenHours:String
    private var firmAddress:String
    private var firmSpecialties:Array<String>
    private var firmId:String
    private var firmDistanceFromUser:String = " "
    
    
    
    init(id:String, n:String, num:String, w:String, o:String, a:String, s:Array<String>){
        self.firmId = id
        self.firmNumber = num
        self.firmName = n
        self.firmWebsite = w
        self.firmOpenHours = o
        self.firmAddress = a
        self.firmSpecialties = s
    }
    
    func getDistanceFromUser() -> String {
        return self.firmDistanceFromUser
    }
    
    func setDistanceFromUser(s:String)->Void{
        self.firmDistanceFromUser = s
    }
    
    func getId() -> String {
        return self.firmId;
    }
    func getName() ->String{
        return self.firmName;
    }
    func getAddress() -> String {
        return self.firmAddress;
    }
    func setName(s:String)->Void{
        self.firmName = s
    }
    func getWebsite() ->String{
        return self.firmWebsite;
    }
    func getOpenHours() -> String {
        return self.firmOpenHours
    }
    func getPhoneNum() -> String {
        return self.firmNumber
    }
    func getSpecialties() -> String {
        var s:String = ""
        
        for item in self.firmSpecialties {
            s += item;
            s += "\n";
        }
        return s;
    }
}
