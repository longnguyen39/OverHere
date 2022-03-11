//
//  PictureAnnotation.swift
//  OverHere
//
//  Created by Long Nguyen on 1/14/22.
//

import UIKit
import MapKit

class PictureAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var timing: String
    
    init(time: String, coorPicture: CLLocationCoordinate2D) {
        self.coordinate = coorPicture
        self.timing = time
    }
    
}
