//
//  InstaMedia.swift
//  PicturesNearMe
//
//  Created by Georgios Taskos on 4/18/15.
//  Copyright (c) 2015 Xplat Solutions. All rights reserved.
//

import UIKit
import CoreLocation

class InstaMedia {
    
    var imageUrl: String = "NA"
    var username: String = "NA"
    var distance: Double = 0
    var locationCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var image: UIImage!
    
    init() {
        self.image = UIImage(named: "NotAvailable")!
    }

    convenience init(imageUrl : String, username : String, distance: Double, locationCoordinate: CLLocationCoordinate2D) {
        self.init()
        self.imageUrl = imageUrl
        self.username = username
        self.distance = distance
        self.locationCoordinate = locationCoordinate
    }
}
