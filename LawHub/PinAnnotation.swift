//
//  PinAnnotation.swift
//  LawHub
//
//  Created by Dylan Aird on 14/05/2016.
//  Copyright © 2016 Dylan Aird. All rights reserved.
//

import MapKit
import Foundation
import UIKit

class PinAnnotation : NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
}
