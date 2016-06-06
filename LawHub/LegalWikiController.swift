//
//  SettingsTableViewController.swift
//  LawHub
//
//  Created by Dylan Aird on 2/04/2016.
//  Copyright © 2016 Dylan Aird. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "topicCell"

class LegalWikiController: UITableViewController {
    
    
    var topicsArray:Array<SubtopicModel> = []
    var isChild = false;
    var parentKey = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if(isChild == true){
            loadSubtopics()
        }else{
            loadTopics()
        }
        
    }
    
    
    
    func loadSubtopics(){
        self.topicsArray = SQLSingletonModel.sharedManager.getAllSubTopics(self.parentKey)
        self.tableView!.reloadData();
    
    }
    
    func loadTopics(){
        
        self.topicsArray = SQLSingletonModel.sharedManager.getAllTopics()
        self.tableView!.reloadData();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.topicsArray.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //get clicked cell
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! topicTableViewCell
        
        if (self.isChild) {
            self.performSegueWithIdentifier("loadTopicSubView", sender: cell)
        }else{
            self.performSegueWithIdentifier("loadSubTopics", sender: cell)
        
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! topicTableViewCell
        
        cell.topicTitle.text = self.topicsArray[indexPath.row].getName()
        
        return cell
    }
    
    
    // MARK: - Navigation
    
    /* In a storyboard-based application, you will often want to do a little preparation before navigation*/
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "loadSubTopics"{
            
            let selfVc = segue.destinationViewController as! LegalWikiController
            let cell = sender as! topicTableViewCell
            
            
            if let indexPath = self.tableView!.indexPathForCell(cell){
                selfVc.navigationItem.title = self.topicsArray[indexPath.row].getName()
                selfVc.parentKey = self.topicsArray[indexPath.row].getKey()
                selfVc.isChild = true
            }
        
        
        
        }else if(segue.identifier == "loadTopicSubView"){
        
            let subTopicVc = segue.destinationViewController as! SubTopic
            let cell = sender as! topicTableViewCell
            
            
            if let indexPath = self.tableView!.indexPathForCell(cell){
                subTopicVc.navigationItem.title = self.topicsArray[indexPath.row].getName()
                subTopicVc.subModel = self.topicsArray[indexPath.row]
                
            }
        }
    }

    
    @IBAction func cancelToRecentArtcilesViewController(segue:UIStoryboardSegue) {
        segue.perform()
    }
    
    @IBAction func saveSettingsDetail(segue:UIStoryboardSegue) {
    }
    
}
