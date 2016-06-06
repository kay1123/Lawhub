//
//  SubTopic.swift
//  LawHub
//
//  Created by Dylan Aird on 15/05/2016.
//  Copyright © 2016 Dylan Aird. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "subtopiccell"

class SubTopic: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var subTableView: UITableView!
    
    @IBOutlet weak var UIWebViewInfo: UIWebView!
    var subSectionKey = ""
    var subTopicKey = ""
    
    var isSubSection = false
    
    var subModel:SubtopicModel!
    var subtopicsArray:Array<SubtopicModel> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(isSubSection){
            loadSubInfo();
        
        }else{
            loadSections()
        }
    }
    
    func loadSubInfo(){

        self.subtopicsArray = SQLSingletonModel.sharedManager.getAllSubinfo(subSectionKey)
        self.UIWebViewInfo.loadHTMLString(subModel.getInfo(), baseURL: nil)
        self.subTableView!.reloadData();
    }
    
    func loadSections(){
        
        self.subtopicsArray = SQLSingletonModel.sharedManager.getAllSections(subModel.getKey())
        self.UIWebViewInfo.loadHTMLString(subModel.getInfo(), baseURL: nil)
        self.subTableView!.reloadData();
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //get clicked cell
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! subtopicCell
        
        if (self.isSubSection) {
            self.performSegueWithIdentifier("loadSubInfo", sender: cell)
        }else{
            self.performSegueWithIdentifier("loadSection", sender: cell)
            
        }
    }
    
    /* In a storyboard-based application, you will often want to do a little preparation before navigation*/
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "loadSection"{
            
            let selfVc = segue.destinationViewController as! SubTopic
            let cell = sender as! subtopicCell
            
            
            if let indexPath = self.subTableView!.indexPathForCell(cell){
                selfVc.navigationItem.title = self.subtopicsArray[indexPath.row].getName()
                selfVc.subSectionKey = self.subtopicsArray[indexPath.row].getKey()
                selfVc.subModel = self.subtopicsArray[indexPath.row]
                selfVc.isSubSection = true
            }
        }else if(segue.identifier == "loadSubInfo"){
            
            let subTopicVc = segue.destinationViewController as! SubInfo
            let cell = sender as! subtopicCell
            
            
            if let indexPath = self.subTableView!.indexPathForCell(cell){
                subTopicVc.subInfoName = self.subtopicsArray[indexPath.row].getName()
                subTopicVc.subInfoText = self.subtopicsArray[indexPath.row].getInfo()
            }
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return subtopicsArray.count
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! subtopicCell
        
        let model:SubtopicModel = subtopicsArray[indexPath.row]
        cell.UILabelSubTopic.text = model.getName()
        
        return cell
    }
}
