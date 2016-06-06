//
//  LaunchScreen.swift
//  LawHub
//
//  Created by Dylan Aird on 17/05/2016.
//  Copyright © 2016 Dylan Aird. All rights reserved.
//

import UIKit

class LaunchScreen: UIViewController {
    
    @IBOutlet weak var UILabelActivity: UIActivityIndicatorView!
    
    @IBOutlet weak var UIImageViewLaunch: UIImageView!
    @IBOutlet weak var UIProgress: UIProgressView!
    @IBOutlet weak var UILabelProgress: UILabel!
    var totalLoaded:Float = 100.0
    var currentLoaded:Float = 0.0
     let threadGroup = dispatch_group_create()
    
    
    override func viewDidLoad() {
        
        self.UILabelProgress.text = "Loading..."
        UIProgress.setProgress(0.0, animated: false)
        UILabelActivity.startAnimating()
    }
    
    override func viewDidAppear(animated: Bool) {
        //set label post view data
        //create instance of singleton
        SQLSingletonModel.sharedManager
        
        self.syncDatabases(){(result)-> Void in
            if(result){
                self.UILabelActivity.stopAnimating()
                self.performSelector(#selector(self.loadMain), withObject: nil, afterDelay: 2)
            }else{
                
            }
        }
    }
    
    func UpdateUI()->Void{
        self.UIProgress.progress = self.currentLoaded / self.totalLoaded
        var s = "Updating: "
        s += String(format: "%.01f", self.currentLoaded) + "%"
        self.UILabelProgress.text = s
        
    }
    
    func loadMain(){
        self.performSegueWithIdentifier("loadMain", sender: self)
    }
    
    
    func syncDatabases(CompletionHandler:(result:Bool)->Void){
        let status = Reach().connectionStatus()
        switch status {
        case .Unknown, .Offline:
            self.currentLoaded += 100.0
            self.UpdateUI()
            CompletionHandler(result: self.checkCounter())
            //print("Offline")
            
            
            //show aleart dialog explaining
        case .Online(.WWAN):
            
            //print("Connected via WWAN")
            fallthrough
            
        case .Online(.WiFi):
            //compare database versions
            SQLSingletonModel.sharedManager.compareDatabaseVersions(){(result) -> Void in
                dispatch_group_enter(self.threadGroup)
                if(result){
                    self.UILabelProgress.text = "Checking For Updates"
                    self.UpdateUI()
                    
                    // sync topics
                    SQLSingletonModel.sharedManager.syncTopics(){(result) ->Void in
                        dispatch_group_enter(self.threadGroup)
                        if(result){
                            self.currentLoaded += 20.0
                            self.UpdateUI()
                            
                            //sync subtopics
                            SQLSingletonModel.sharedManager.syncSubTopics(){(result) ->Void in
                                dispatch_group_enter(self.threadGroup)
                                if(result){
                                    self.currentLoaded += 20.0
                                    self.UpdateUI()
                                    
                                    //sync sections
                                    SQLSingletonModel.sharedManager.syncSections(){(result) ->Void in
                                        dispatch_group_enter(self.threadGroup)
                                        if(result){
                                            self.currentLoaded += 20.0
                                            self.UpdateUI()
                                            
                                            
                                            //sync subinfo
                                            SQLSingletonModel.sharedManager.syncSubinfo(){(result) ->Void in
                                                dispatch_group_enter(self.threadGroup)
                                                if(result){
                                                    self.currentLoaded += 20.0
                                                    self.UpdateUI()
                                                    
                                                    
                                                    //update local database version
                                                    SQLSingletonModel.sharedManager.updateLocalDatabaseVersion{(result) ->Void in
                                                        dispatch_group_enter(self.threadGroup)
                                                        if(result){
                                                            self.currentLoaded += 20.0
                                                            self.UpdateUI()
                                                            
                                                            
                                                            //update local database version
                                                            
                                                            CompletionHandler(result: self.checkCounter())
                                                            dispatch_group_leave(self.threadGroup)
                                                        }else{
                                                            
                                                        }
                                                    }
                                                    
                                                    CompletionHandler(result: self.checkCounter())
                                                    dispatch_group_leave(self.threadGroup)
                                                }else{
                                                    
                                                }
                                            }
                                            
                                            CompletionHandler(result: self.checkCounter())
                                            dispatch_group_leave(self.threadGroup)
                                        }else{
                                            
                                        }
                                    }
                        
                                    
                                    CompletionHandler(result: self.checkCounter())
                                    dispatch_group_leave(self.threadGroup)
                                }else{
                                    
                                }
                            }
                            CompletionHandler(result: self.checkCounter())
                            dispatch_group_leave(self.threadGroup)
                        }else{
                            
                        }
                    }
                    dispatch_group_leave(self.threadGroup)
                    
                }else{
                    self.currentLoaded += 100.0
                    self.UpdateUI()
                    CompletionHandler(result: self.checkCounter())
                }
            }
    }
        
    }
    
    func checkCounter()->Bool{
        //print(self.currentLoaded)
        if self.currentLoaded == 100.0{
            return true;
        }
        return false
    }
}
