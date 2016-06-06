//
//  TodayViewController.swift
//  RecentArticlesToday
//
//  Created by Dylan Aird on 19/05/2016.
//  Copyright © 2016 Dylan Aird. All rights reserved.
//

import UIKit
import NotificationCenter
import Firebase

class TodayViewController: UITableViewController, NCWidgetProviding {
    
    let rootRef = Firebase(url: "https://lawhubaus.firebaseio.com/")
    var articleRef: Firebase!
    var models:Array<ArticleModel> = []
    var model:ArticleModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        articleRef = rootRef.childByAppendingPath("articles");
        // Do any additional setup after loading the view from its nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.models.count
    }
    func updatePreferredContentSize() {

        self.preferredContentSize = self.tableView.contentSize;
        
    }
    
    func widgetMarginInsetsForProposedMarginInsets
        (defaultMarginInsets: UIEdgeInsets) -> (UIEdgeInsets) {
        return UIEdgeInsetsZero
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition({ context in
            self.tableView.frame = CGRectMake(0, 0, size.width, size.height)
            }, completion: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("articleItem", forIndexPath: indexPath) as! TodayTableViewCell
        
        //get the model
        let model:ArticleModel = models[indexPath.row]
        
        //set the label and trunicate the text
        cell.UILabelName.text = model.getArticleName()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM"
        let dateString = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: model.getEpoc()))
        cell.UILabelDate.text = dateString
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        extensionContext?.openURL(NSURL(string: "lawhub://")!, completionHandler: nil)
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        let epochTime = NSDate().timeIntervalSince1970
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM"
        
        articleRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            for child in snapshot.children {
                

                
                //child snapshot
                let childSnapshot = snapshot.childSnapshotForPath(child.key)
                
                let childDate = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970:childSnapshot.value["timestamp"] as! Double))
                let currentDate = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: epochTime))
                
                if(childDate == currentDate){
                    let model:ArticleModel = ArticleModel(id: child.key as String, n: childSnapshot.value["articletitle"] as! String, t: childSnapshot.value["articletext"] as!String, epoc: childSnapshot.value["timestamp"] as! Double, st: childSnapshot.value["articleshorttext"] as! String)
                    
                    //append to array
                    if(!self.searchArticleArray(child.key)){
                        self.models.append(model);
                    }
                    
                    self.tableView.reloadData()
                }
                //create object and push it to array of objects

                
                
            }
            self.updatePreferredContentSize()

            completionHandler(NCUpdateResult.NewData)
            
            }, withCancelBlock: { error in
                completionHandler(NCUpdateResult.Failed)
        })
    


        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        
    }

    func searchArticleArray(Id: String) -> Bool{
    
        for item in self.models{
            if(item.getArticleId() == Id){
                return true;
            }
        }
        return false;
    }


}
