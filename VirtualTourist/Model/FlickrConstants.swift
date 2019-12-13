//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Musaad on 12/9/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import MapKit

class FlickrConstants {

    struct Flickr {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        
        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
    }
    
    
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let PhotosPerPage = "per_page"
        static let Page = "page"
    }
    
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "b6dc3e6938f54fb97c3ce75d2228221c"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let MediumURL = "url_n"
        static let UseSafeSearch = "1" 
        static let PhotosPerPage = 30
        static let GalleryPhotosMethod = "flicker.galleries.getPhotos"
    }
}
