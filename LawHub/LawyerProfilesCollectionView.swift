//
//  LawyerProfilesCollectionView.swift
//  LawHub
//
//  Created by Dylan Aird on 5/04/2016.
//  Copyright © 2016 Dylan Aird. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import AlamofireImage

class LawyerProfilesCollectionView: UICollectionViewController, UIPopoverPresentationControllerDelegate {
    
    let reuseIdentifier = "lawyerCell"
    var firmId:String = ""
    var lawyers:Array<LawyerModel> = [];
    let rootRef = Firebase(url: "https://lawhubaus.firebaseio.com/")
    var lawyerRef: Firebase!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lawyerRef = rootRef.childByAppendingPath("lawyers");
        loadLawyers();
        
        
    }
    
    func loadLawyers(){
        
        lawyerRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            for child in snapshot.children {
                
                //child snapshot
                let childSnapshot = snapshot.childSnapshotForPath(child.key)
                
                if(childSnapshot.value["firmid"] as! String == self.firmId){
                    //create object and push it to array of objects
                    
                    
                    let model:LawyerModel = LawyerModel(id: child.key, name: childSnapshot.value["name"] as! String,
                        bio: childSnapshot.value["bio"] as! String,
                        a: childSnapshot.value["awards"] as! String,
                        url: childSnapshot.value["imageurl"] as! String,
                        lang: childSnapshot.value["languages"]as! Array,
                        spec: childSnapshot.value["specialties"]as! Array, fId: self.firmId)
                    
                    //append to array
                    if(!self.searchLawyerArray(model.getId())){
                        
                        self.lawyers.append(model)
                    }
                    SingletonModel.sharedManager.addtoLawyerMemory(model)
                    self.collectionView!.reloadData();
                    
                }
            }
            
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        self.performSegueWithIdentifier("showProfile", sender: cell)
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lawyers.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! LawyerProfilesCollectionViewCell
        let model:LawyerModel = lawyers[indexPath.row]
        

            let url = model.getUrlString()
            
            Alamofire.request(.GET, url).response { (request, response, data, error) in
                if(response?.statusCode == 200){
                    model.setImage(UIImage(data: data!, scale:1)!)
                    cell.lawyerImage.image = model.getImage()
                    cell.lawyerImage.layer.cornerRadius = cell.lawyerImage.frame.size.width / 3
                    cell.lawyerImage.clipsToBounds = true
                }
            }
        
        
        cell.lawyerName.text = model.getName()
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //segue for the popover configuration window
        if segue.identifier == "showProfile" {
            
            let lawyerProfile = segue.destinationViewController as! ProfileView
            
            
            lawyerProfile.Width = collectionView?.frame.width
            lawyerProfile.Height = collectionView?.frame.width
        
            
            let cell = sender as! LawyerProfilesCollectionViewCell
            
            
            if let indexPath = self.collectionView!.indexPathForCell(cell){
                let model:LawyerModel = self.lawyers[indexPath.row]
                
                lawyerProfile.navigationItem.title = model.getName()
                lawyerProfile.profileId = model.getId()

                //set the id of the article and send it via segue
            }
        }
    }
    
    @IBAction func cancelToProfileOverView(segue:UIStoryboardSegue) {
        segue.perform()
    }

    func searchLawyerArray(lawyerId: String) -> Bool{
        
        for item in self.lawyers{
            if(item.getId() == lawyerId){
                return true;
            }
        }
        return false;
    }

}
