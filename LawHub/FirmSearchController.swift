//
//  FirmSearchController.swift
//  LawHub
//
//  Created by Dylan Aird on 3/04/2016.
//  Copyright © 2016 Dylan Aird. All rights reserved.
//


import UIKit
import Firebase
import MapKit

class FirmSearchController: UITableViewController,UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, CLLocationManagerDelegate {
    
    var selectedIndexPath : NSIndexPath?
    let cellID = "firmCell"
    var firms = Array<FirmModel>();
    
    //firebase information
    let rootRef = Firebase(url: "https://lawhubaus.firebaseio.com/")
    var firmRef: Firebase!
    
    var indicator = UIActivityIndicatorView()
    
    
    //location information
    var locationManager = CLLocationManager()
    
    var locValue:CLLocationCoordinate2D!
    
    var lawyerSearchController : UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
        }
        
        
        locationManager.pausesLocationUpdatesAutomatically = false;
        locationManager.startUpdatingLocation()
        
        //firebase handlers
        firmRef = rootRef.childByAppendingPath("lawfirms");
        
        // set the search controllers object
        self.lawyerSearchController = UISearchController(searchResultsController: nil)
        
        //tells the controller that this class is the updater
        self.lawyerSearchController.searchResultsUpdater = self
        self.lawyerSearchController.delegate = self
        self.lawyerSearchController.searchBar.delegate = self
        self.lawyerSearchController.hidesNavigationBarDuringPresentation = false
        self.lawyerSearchController.dimsBackgroundDuringPresentation = false
        self.lawyerSearchController.searchBar.placeholder = "Search By Firm Name Or Specialisation"
        
        self.navigationItem.titleView = lawyerSearchController.searchBar
        
        self.definesPresentationContext = true
        self.tableView.tableFooterView = UIView()

        indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        indicator.center = self.view.center
        self.view.addSubview(indicator)
        
        
    }
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if(self.locValue != nil){
            self.LoadFirmDistance()
        }
        self.tableView.reloadData()

        
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.indicator.startAnimating()
        if(searchText.characters.count == 0){
            self.indicator.stopAnimating()
            self.firms.removeAll()
        }else{
            self.firms.removeAll()
            searchModels(searchText)
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locValue = manager.location!.coordinate
        locationManager.stopUpdatingLocation()
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
        
    }
    
    
    func LoadFirmDistance()->Void{
    
        for item in firms{
            CLGeocoder().geocodeAddressString(item.getAddress(), completionHandler:
                {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                    if let placemark = placemarks?[0] {
                        // Convert the address to a coordinate
                        let location = placemark.location
                        let destCoords = location!.coordinate
                        let userLoc = CLLocation(latitude: self.locValue.latitude, longitude: self.locValue.longitude)
                        let firmLoc = CLLocation(latitude: destCoords.latitude, longitude: destCoords.longitude)
                        
                        
                        let distanceMeters = firmLoc.distanceFromLocation(userLoc)
                        let distanceKM = distanceMeters / 1000
                        var kmsrounded:String = String(format:"%1.f", round(distanceKM))
                        kmsrounded += " Km"
                        item.setDistanceFromUser(kmsrounded)
                        self.tableView.reloadData();
                    }
            })
        }
        
    }
    
    func searchFirebase(searchText: String) -> Void {
        //implement searching memory model and database here
        
        firmRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            for child in snapshot.children {
                
                //child snapshot
                let childSnapshot = snapshot.childSnapshotForPath(child.key)
                let name:String = childSnapshot.value["name"] as! String;
                
                if(name.containsString(searchText)){
                    //create object and push it to array of objects
                    let model:FirmModel = FirmModel(id: child.key as String,
                        n: childSnapshot.value["name"] as! String,
                        num: childSnapshot.value["phonenumber"] as! String,
                        w: childSnapshot.value["website"] as! String,
                        o: childSnapshot.value["openhours"] as! String,
                        a: childSnapshot.value["address"] as! String,
                        s: childSnapshot.value["specialties"]as! Array);
                    model.setDistanceFromUser(" ")
                    
                    //append to array
                    if(!self.searchFirmArray(model.getId())){
                        self.firms.append(model)
                        
                    }
                }
            }
            if(self.locValue != nil){
                self.LoadFirmDistance()
            }
            
            self.indicator.stopAnimating()
            self.tableView.reloadData();
            
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    func searchMemoryModel(s:String) -> Void {
        for singletonFirm in SingletonModel.sharedManager.firmMemoryModel {
            
            //check each firm in the firm array against the memory model
            if(singletonFirm.1.getName().containsString(s)){
                //if we match the search term against the singleton memory model, see if it exists, if not add it
                if(!searchFirmArray(singletonFirm.1.getId())){
                    firms.append(singletonFirm.1)
                    
                }
            }
        }
    }
    
    func searchModels(searchTerm:String) -> Void {
        
        let status = Reach().connectionStatus()
        
        switch status {
        case .Offline, .Unknown:

            searchMemoryModel(searchTerm)
            //search database model
            for firm in SQLSingletonModel.sharedManager.searchFirmTable(searchTerm){
                if(!searchFirmArray(firm.getId())){
                    self.firms.append(firm)
                }
                
            }
            self.indicator.stopAnimating()
            self.tableView.reloadData();
            
        case .Online(.WWAN):
            fallthrough
            
        case .Online(.WiFi):
            //search firebase model
            searchFirebase(searchTerm);

        }
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        //once you finish typing add all firms to the memory model
        for item in firms{
            SingletonModel.sharedManager.addtoFirmMemory(item)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if(segue.identifier == "showMap"){
            let mapVC:MapController = segue.destinationViewController as! MapController
            
            let cell = sender!.superview!?.superview as! LawyerFirmCell
            let indexPath = tableView!.indexPathForCell(cell)
            
            
            let model:FirmModel = firms[(indexPath?.row)!]
            mapVC.navigationItem.title = model.getName()
            mapVC.firmId = model.getId()
            
        }else if(segue.identifier == "showLawyers"){
            
            let lawyerProfile:LawyerProfilesCollectionView = segue.destinationViewController as! LawyerProfilesCollectionView
            
            let cell = sender!.superview!?.superview as! LawyerFirmCell
            let indexPath = tableView!.indexPathForCell(cell)
            
            
            let model:FirmModel = firms[(indexPath?.row)!]
            lawyerProfile.firmId = model.getId()
            lawyerProfile.navigationItem.title = model.getName()
        
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return firms.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        SingletonModel.sharedManager.addtoFirmMemory(firms[indexPath.row])
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! LawyerFirmCell
        
        //get current cell and match it with array position.
        let firmObject = firms[indexPath.row];

        
        //assign object attributes to cell
        cell.firmNameLabel.text = firmObject.getName();
        cell.firmPhoneNumber.text = firmObject.getPhoneNum()
        cell.firmWebsite.text = firmObject.getWebsite()
        cell.firmSpecialties.text = firmObject.getSpecialties()
        cell.id = firmObject.getId()
   
        cell.firmDistance.text = firmObject.getDistanceFromUser()
        
        
        //set button segue plus add a tag to identify it in makesegue method
        cell.UIButtonLawyer.addTarget(self, action: #selector(FirmSearchController.makeSegue(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.UIButtonLawyer.tag = 0
        
        //same as above
        cell.UIButtonMap.addTarget(self, action: #selector(FirmSearchController.makeSegue(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.UIButtonMap.tag = 1
        
        //set target for button
        cell.UIButtonPhone.addTarget(self, action: #selector(FirmSearchController.makeSegue(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.UIButtonPhone.tag = 2
        //use subview of titlelabel to contain the index row // hacked together prepare for segue
        cell.UIButtonPhone.titleLabel!.tag = indexPath.row
        
        cell.UIButtonWeb.addTarget(self, action: #selector(FirmSearchController.makeSegue(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.UIButtonWeb.tag = 3
        cell.UIButtonWeb.titleLabel?.tag = indexPath.row
    
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let model = firms[indexPath.row]
        
        SQLSingletonModel.sharedManager.pushFirmToDb(model)
        
        let previousIndexPath = selectedIndexPath
        if indexPath == selectedIndexPath {
            selectedIndexPath = nil
        } else {
            selectedIndexPath = indexPath
        }
        
        var indexPaths : Array<NSIndexPath> = []
        if let previous = previousIndexPath {
            indexPaths += [previous]
        }
        if let current = selectedIndexPath {
            indexPaths += [current]
        }
        if indexPaths.count > 0 {
            tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.firms.removeAll()
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        (cell as! LawyerFirmCell).watchFrameChanges()
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        (cell as! LawyerFirmCell).ignoreFrameChanges()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        for cell in tableView.visibleCells as! [LawyerFirmCell] {
            cell.ignoreFrameChanges()
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath == selectedIndexPath {
            return LawyerFirmCell.expandedHeight
        } else {
            return LawyerFirmCell.defaultHeight
        }
    }
    func makeSegue(button:UIButton) {
        
        switch button.tag {
        case 0:
            self.performSegueWithIdentifier("showLawyers", sender: button)
            break;
            
        case 1:
            self.performSegueWithIdentifier("showMap", sender: button)
            break;
        case 2:
            
            let model:FirmModel = firms[(button.titleLabel?.tag)!]
            self.callNumber(model.getPhoneNum())
            break;
        case 3:
            
            let model:FirmModel = firms[(button.titleLabel?.tag)!]
            UIApplication.sharedApplication().openURL(NSURL(string: model.getWebsite())!)
            break;
            
        default: break
            
        }
    }
    
    func searchFirmArray(firmId: String) -> Bool{
        
        for item in self.firms{
            if(item.getId() == firmId){
                return true;
            }
        }
        return false;
    }
    
    private func callNumber(phoneNumber:String) {
        if let phoneCallURL:NSURL = NSURL(string: "tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
}
