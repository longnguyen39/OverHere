//
//  Picture.swift
//  OverHere
//
//  Created by Long Nguyen on 1/9/22.
//

import UIKit
import MapKit

struct Picture {
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var altitude: CLLocationDegrees
    var title: String
    var timestamp: String
    var date: String
    var imageUrl: String
    
    //dictionary only used when fetching from Cloud Database
    init(dictionary: [String : Any]) {
        self.latitude = dictionary["latitude"] as? CLLocationDegrees ?? 0
        self.longitude = dictionary["longitude"] as? CLLocationDegrees ?? 0
        self.altitude = dictionary["altitude"] as? CLLocationDegrees ?? 0
        self.title = dictionary["title"] as? String ?? "no title"
        self.timestamp = dictionary["timestamp"] as? String ?? "no time"
        self.date = dictionary["date"] as? String ?? "no date"
        self.imageUrl = dictionary["imageURL"] as? String ?? "no imageURL"
        
        //all the shit "" must match the "" in "data" in UploadInfo
    }
    
}

