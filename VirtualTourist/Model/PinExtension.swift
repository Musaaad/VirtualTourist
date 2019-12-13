//
//  PinExtension.swift
//  VirtualTourist
//
//  Created by Musaad on 12/9/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import MapKit

extension Pin {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
    
    var coordination: CLLocationCoordinate2D {
        
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
        
        get {
            return CLLocationCoordinate2D (latitude: latitude, longitude: longitude)
        }
    }
    
    func comparing (to coordination: CLLocationCoordinate2D) -> Bool {
        return (latitude == coordination.latitude && longitude == coordination.longitude)
    }
    
    
    
}
