//
//  LawyerModel.swift
//  LawHub
//
//  Created by Dylan Aird on 29/04/2016.
//  Copyright © 2016 Dylan Aird. All rights reserved.
//

import Foundation
import UIKit

class LawyerModel{
    
    private var lawyerName: String
    private var lawyerId:String
    private var lawyerBio:String
    private var awards: String
    private var firmId:String
    private var imageurl :String
    private var image: UIImage!
    private var languages : Array<String>;
    private var specialisesIn: Array<String>
    
    
    init(id:String, name:String, bio:String,  a:String, url:String, lang:Array<String>, spec:Array<String>, fId:String){
        
        self.lawyerId = id
        self.firmId = fId
        self.lawyerName = name
        self.lawyerBio = bio
        self.awards = a
        self.imageurl = url
        self.languages = lang
        self.specialisesIn = spec
    }
    
    func getUrlString()->String{
        return self.imageurl
    }
    
    func getId()-> String{
        return self.lawyerId;
    }
    
    func getName()->String{
        return self.lawyerName;
    }
    func setImage(img: UIImage){
        self.image = img
    }
    
    func getImage()-> UIImage{
        return self.image
    }
    func getLanguages()->String{
        var lang:String = ""
        for item in self.languages{
            lang += item + " "
        }
        return lang
    }
    
    func getSpecialties()->String{
        var spec:String = ""
        for item in self.specialisesIn{
            spec += item + "\n"
        }
        return spec
    }
    
    func getAwards()->String{
        return self.awards
    }
    func getBio()->String{
        return self.lawyerBio
    }
    
    
    


}
