//
//  DownloadingPhotos.swift
//  VirtualTourist
//
//  Created by Musaad on 12/10/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

let imagesCache = NSCache<NSString, AnyObject>()

class DownloadingPhotos: UIImageView {
    
    
    var imageURL: URL!
    
    func setPhoto(_ newPhoto: Photo) {
        if photo != nil {
            return
        }
        photo = newPhoto
    }
    
    private var photo: Photo! {
        didSet {
            if let image = photo.getImage() {
                hideActivityIndicator()
                self.image = image
                return
            }
            
            guard let url = photo.url else {
                return
            }
            
            loadImageUsingCache(with: url)
        }
    }
    
    func loadImageUsingCache(with url: URL) {
        imageURL = url
        image = nil
        showActivityIndicator()
        
        if let cachedImage = imagesCache.object(forKey: url.absoluteString as NSString) as? UIImage {
            self.image = cachedImage
            hideActivityIndicator()
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            guard let DownloadedImage = UIImage(data: data!) else { return }
            imagesCache.setObject(DownloadedImage, forKey:  url.absoluteString as NSString)
            DispatchQueue.main.async {
                self.image = DownloadedImage
                self.photo.set(image: DownloadedImage)
                ((try? self.photo.managedObjectContext?.save()) as ()??)
                 self.hideActivityIndicator()
            }
            
        }.resume()
    }
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        self.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activityIndicator.color = .black
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    func showActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
    }
    
    func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
    
    
    
}
