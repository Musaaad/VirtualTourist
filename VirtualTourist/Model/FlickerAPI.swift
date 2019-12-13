//
//  FlickerAPI.swift
//  VirtualTourist
//
//  Created by Musaad on 12/8/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import MapKit

struct FlickrAPI {
    
    static func getPhotosUrls(with coordinate: CLLocationCoordinate2D, pageNumber: Int, completion: @escaping ([URL]?, Error?, String?) -> ()) {
        let methodParameters = [
            FlickrConstants.FlickrParameterKeys.Method: FlickrConstants.FlickrParameterValues.SearchMethod,
            FlickrConstants.FlickrParameterKeys.APIKey: FlickrConstants.FlickrParameterValues.APIKey,
            FlickrConstants.FlickrParameterKeys.BoundingBox: bboxString(for: coordinate),
            FlickrConstants.FlickrParameterKeys.SafeSearch: FlickrConstants.FlickrParameterValues.UseSafeSearch,
            FlickrConstants.FlickrParameterKeys.Extras: FlickrConstants.FlickrParameterValues.MediumURL,
            FlickrConstants.FlickrParameterKeys.Format: FlickrConstants.FlickrParameterValues.ResponseFormat,
            FlickrConstants.FlickrParameterKeys.NoJSONCallback: FlickrConstants.FlickrParameterValues.DisableJSONCallback,
            FlickrConstants.FlickrParameterKeys.Page: pageNumber,
            FlickrConstants.FlickrParameterKeys.PhotosPerPage: FlickrConstants.FlickrParameterValues.PhotosPerPage,
            ] as [String:Any]
        
        
        func gettingURL(from parameters: [String:Any]) -> URL {
            
            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.flickr.com"
            components.path = "/services/rest"
            components.queryItems = [URLQueryItem]()
            
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
            
            return components.url!
        }
        
        let request = URLRequest(url: gettingURL(from: methodParameters))
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard (error == nil) else {
                completion(nil, error, nil)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completion(nil, nil, "Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                completion(nil, nil, "No data was returned by the request!")
                return
            }
            
            guard let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {
                completion(nil, nil, "Sorry, the data couldn't be parsed as JSON.")
                return
            }
            
            guard let stat = result["stat"] as? String, stat == "ok" else {
                completion(nil, nil, "Flickr API returned an error. See error code and message in \(result)")
                return
            }
            
            guard let photosDictionary = result["photos"] as? [String:Any] else {
                completion(nil, nil, "No 'photos' were found in \(result)")
                return
            }
            
            guard let photosArray = photosDictionary["photo"] as? [[String:Any]] else {
                completion(nil, nil, "No 'photo' was found in \(photosDictionary)")
                return
            }
            
            let photosURLs = photosArray.compactMap { photoDictionary -> URL? in
                guard let url = photoDictionary["url_n"] as? String else { return nil}
                return URL(string: url)
            }
            
            completion(photosURLs, nil, nil)
        }
        
        task.resume()
    }
    
    static func bboxString(for coordinate: CLLocationCoordinate2D) -> String {
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        let minimumLon = max(longitude - FlickrConstants.Flickr.SearchBBoxHalfWidth, -180)
        let minimumLat = max(latitude - FlickrConstants.Flickr.SearchBBoxHalfHeight, -90)
        let maximumLon = min(longitude + FlickrConstants.Flickr.SearchBBoxHalfWidth, 180)
        let maximumLat = min(latitude + FlickrConstants.Flickr.SearchBBoxHalfHeight, 90)
        
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    
}
