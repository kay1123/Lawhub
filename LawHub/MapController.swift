//
//  MapController.swift
//  LawHub
//
//  Created by Dylan Aird on 11/05/2016.
//  Copyright © 2016 Dylan Aird. All rights reserved.
//

import UIKit
import MapKit

class MapController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var firmId:String = ""
    var model:FirmModel!;
    
    //map vars
    var ismapLoaded = false;
    var region:MKCoordinateRegion!
    var coords: CLLocationCoordinate2D?
    var placemark:CLPlacemark!
    
    
    
    override func didReceiveMemoryWarning() {
        self.mapView.delegate = nil;
        self.mapView = nil
    }
    override func viewDidLoad() {
        model = SingletonModel.sharedManager.getFirmWithId(firmId)

        // Load
        loadMap()
    }
    //try unload the map from memory
    override func viewWillDisappear(animated: Bool) {
        self.mapView.delegate = nil;
        self.mapView = nil
    }
    
    //add the annotation to the map once its rendered
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
        if(fullyRendered == true){
            let anotation = PinAnnotation(title: self.model.getName(), locationName: self.model.getAddress(), discipline: "Wut", coordinate: self.coords!)
            self.mapView.addAnnotation(anotation)
            self.mapView.selectAnnotation(anotation, animated: true)
        
        }
    }
    
    //create the custom annotations and add the right navigation button
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is PinAnnotation {
            
            
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            
            pinAnnotationView.draggable = false
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.animatesDrop = true
            
            
            let button   = UIButton(type: UIButtonType.Custom) as UIButton
            
            button.frame = CGRectMake(100, 100, 100, 100)
            button.setTitle("Navigate", forState: .Normal)
            button.setTitleColor(UIColor.blueColor(), forState: .Normal)
            button.sizeToFit()
           

            
            button.addTarget(self, action: #selector(MapController.openMaps), forControlEvents:.TouchUpInside)
            self.view.addSubview(button)
            
            pinAnnotationView.rightCalloutAccessoryView = button
            
            return pinAnnotationView
        }
        
        return nil
    }
    
    //call the system map to navigate
    func openMaps()->Void{
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: self.coords!, addressDictionary:nil))
        mapItem.name = self.model.getName()
        mapItem.openInMapsWithLaunchOptions([MKLaunchOptionsDirectionsModeDriving : MKLaunchOptionsDirectionsModeKey])

    }
    //load the map and decode the address into coords
    func loadMap(){
            let geoCoder = CLGeocoder()
            
            // Determine the zoom level of the map to display
            let span = MKCoordinateSpanMake(0.01, 0.01)
            geoCoder.geocodeAddressString(self.model.getAddress(), completionHandler:
                {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                    if let placemark = placemarks?[0] {
                        self.placemark = placemark
                        // Convert the address to a coordinate
                        let location = placemark.location
                        self.coords = location!.coordinate
                        // Set the map to the coordinate
                        self.region = MKCoordinateRegion(center: self.coords!, span: span)
                        
                        
                        self.mapView.region = self.region
        
                    }
            })
    
    }

}
