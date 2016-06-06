//
//  cardCollectionViewController.swift
//  LawHub
//
//  Created by Dylan Aird on 1/04/2016.
//  Copyright © 2016 Dylan Aird. All rights reserved.
//

import UIKit
import Firebase

class cardCollectionViewController: UICollectionViewController {
    
    private let reuseIdentifier = "Cell"
    private let infoCellReuseIdentifier = "infoCell"
    var refreshControl = UIRefreshControl()
    var indicator = UIActivityIndicatorView()
    
    
    private let stickyYellow = UIColor(red: 239/256, green: 249/256, blue: 185/256, alpha: 1)
    var updateSize: CGSize!
    
    let rootRef = Firebase(url: "https://lawhubaus.firebaseio.com/")
    var articleRef: Firebase!
    var models:Array<ArticleModel> = []
    
    let didYouKnow = "Did You Know?"
    let RandomFactsArray = ["In Australia, bars are required to stable, water and feed the horses of their patrons", "In Victoria, it is illegal to change a light bulb unless you are a qualified electrician", "You may never leave your car keys in an unattended vehicle"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set firebase references
        articleRef = rootRef.childByAppendingPath("articles");
        
        
        
        //refresh controller
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(cardCollectionViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView!.addSubview(refreshControl)
        
        //loading indicator
        indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        indicator.center = self.view.center
        self.view.addSubview(indicator)
        self.indicator.startAnimating()
        
        
        //Load Data On First Load
        self.refresh(self)
    }
    
    func refresh(sender:AnyObject) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            //load the image in the background
            self.loadData({(result) ->Void in
                if(result){
                    dispatch_async(dispatch_get_main_queue(), {
                        self.models.sortInPlace({$0.getEpoc() > $1.getEpoc()})
                        self.indicator.stopAnimating()
                        self.refreshControl.endRefreshing()
                    })
                }
            })
        })
    }
    
    func loadData(CompletionHandler:(result:Bool)->Void){
        self.models.removeAll()
        let status = Reach().connectionStatus()
        switch status {
        case .Unknown, .Offline:
            //print("Offline")
            if(SQLSingletonModel.sharedManager.getAllArticles()){
                for item in SingletonModel.sharedManager.getArticleMemoryModel(){
                    if(!searchArticleArray(item.1.getArticleId())){
                        self.models.append(item.1)
                    }
                    
                    self.collectionView?.reloadData()
                }
                CompletionHandler(result: true)
                
            }else{
                CompletionHandler(result: false)
            }
        case .Online(.WWAN):
            
            //print("Connected via WWAN")
            fallthrough
            
        case .Online(.WiFi):
            //print("Connected via WiFi")
            
            articleRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                
                for child in snapshot.children {
                    
                    //child snapshot
                    let childSnapshot = snapshot.childSnapshotForPath(child.key)
                    
                    //create object and push it to array of objects
                    let model:ArticleModel = ArticleModel(id: child.key as String, n: childSnapshot.value["articletitle"] as! String, t: childSnapshot.value["articletext"] as!String, epoc: childSnapshot.value["timestamp"] as! Double, st: childSnapshot.value["articleshorttext"] as! String)
                    
                    //append to array
                    if(self.searchArticleArray(child.key)){
                        for i in self.models{
                            if(i.getArticleId() == child.key){
                                i.setArticleName(childSnapshot.value["articletitle"] as! String)
                                i.setArticleText(childSnapshot.value["articletext"] as! String)
                                i.setShortText(childSnapshot.value["articleshorttext"] as! String)
                                SingletonModel.sharedManager.addArticleToMemory(i)
                                
                            }
                        }
                    }else{
                        self.models.append(model);
                    }
                   
                    SQLSingletonModel.sharedManager.pushArticleToDb(model)
                    self.collectionView!.reloadData();
                    
                }
                CompletionHandler(result: true)
                SQLSingletonModel.sharedManager.updateDbFromFirebase()
                
                }, withCancelBlock: { error in
                    CompletionHandler(result: false)
                    print(error.description)
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        
        var res = 0
        switch(section) {
        case 0:
            res = 1  // Number of cell per section(section 0)
            break
        default:
            //sort array to latest epoc time
            self.models.sortInPlace({$0.getEpoc() > $1.getEpoc()})
            res = self.models.count;
            break
        }
        return res;
    }
    
    
    
    // Use the UICollectionViewDelegateFlowLayout to set the size of our
    // cells.
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        // We will set our updateSize value if it's nil.
        if updateSize == nil {
            // At this point, the correct ViewController frame is set.
            self.updateSize = self.view.frame.size
            
        }
            return returnSizeForSection(indexPath)

    }
    
    func returnSizeForSection(indexPath: NSIndexPath) -> CGSize{
        if indexPath.section == 0{
            return CGSizeMake((updateSize.width - 35) , 75)
            
        }else{
            return CGSizeMake((updateSize.width - 35), 150)
        }
    
    }
    
    // Finally, update the size of the updateSize property, every time
    // viewWillTransitionToSize is called.  Then performBatchUpdates to
    // adjust our layout.
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        self.updateSize = size
        self.collectionView!.performBatchUpdates(nil, completion: nil)
    }
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0{
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(infoCellReuseIdentifier, forIndexPath: indexPath) as! infoCollectionViewCell
            
            cell.randomHeader.text = "Did You Know?";
            cell.randomTextField.text = RandomFactsArray.sample()
            cell.backgroundColor = stickyYellow
            cell.randomTextField.backgroundColor = stickyYellow
            cell.randomTextField.userInteractionEnabled = false
            return cell
        
        }else{
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MyCollectionViewCell
            
            //get the model
            let model:ArticleModel = models[indexPath.row]
            
            //set the label and trunicate the text
            cell.UIcardLabel.text = model.getArticleName()
            let str = model.getArticleShortText()
            cell.UIText.text = str.trunc(150)
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd-MM"
            let dateString = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: model.getEpoc()))
            cell.UICardDate.text = dateString
            
            cell.UIText.userInteractionEnabled = false
            return cell
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if  indexPath.section == 0{
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! infoCollectionViewCell
            
            cell.randomTextField.text = RandomFactsArray.sample()
        }else{
            let cell = collectionView.cellForItemAtIndexPath(indexPath)
            self.performSegueWithIdentifier("showArticle", sender: cell)
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showArticle"){
            
            
            let recentArticlesVC = segue.destinationViewController as! RecentArticlesViewController
            let cell = sender as! MyCollectionViewCell
            
            
            if let indexPath = self.collectionView!.indexPathForCell(cell){
                recentArticlesVC.navigationItem.title = self.models[indexPath.row].getArticleName()
                recentArticlesVC.articleContents = self.models[indexPath.row].getArticleText()
            }
        }
    }

    // MARK: UICollectionViewDelegate

    
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
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
extension Array {
    func sample() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}
extension String {
    func trunc(length: Int, trailing: String? = "...") -> String {
        if self.characters.count > length {
            return self.substringToIndex(self.startIndex.advancedBy(length)) + (trailing ?? "")
        } else {
            return self
        }
    }
}
