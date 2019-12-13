//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Musaad on 12/4/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newButton: UIButton!
    @IBOutlet weak var noImagesLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var pin: Pin!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var pageNumber = 1
    var deletingPhoto = false
    
    var context: NSManagedObjectContext {
        return DataController.sharedInstance.viewContext
    }
    
    var photosExist: Bool {
        return (fetchedResultsController.fetchedObjects?.count ?? 0) != 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            if photosExist {
                updatingInterface(processing: false)
            }
            else {
                newButtonClicked(self)
            }
            
        } catch {
            fatalError("The fetch could not be performd: \(error.localizedDescription)")
        }
        
    }
    
    
    @IBAction func newButtonClicked(_ sender: Any) {
        
        updatingInterface(processing: true)
        
        if photosExist {
            deletingPhoto = true
            for photo in fetchedResultsController.fetchedObjects! {
                context.delete(photo)
            }
            try? context.save()
            deletingPhoto = false
        }
        
        FlickrAPI.getPhotosUrls(with: pin.coordination, pageNumber: pageNumber) { (urls, error, errorMessage) in
            DispatchQueue.main.async {
                
                  self.updatingInterface(processing: false)
                
                guard (error == nil) && (errorMessage == nil) else {
                    ShowAlert.showAlert(title: "Error", message: error!.localizedDescription, vc: self)
                    return
                }
                
                guard let urls = urls, !urls.isEmpty else {
                    self.noImagesLabel.isHidden = false
                    return
                }
                
                
                for imageurl in urls {
                    let photo = Photo(context: self.context)
                    photo.url = imageurl
                    photo.pin = self.pin
                }
                
                try? self.context.save()
            }
        }
        pageNumber += 1
        
        
    }
    
    func updatingInterface (processing: Bool) {
        
        collectionView.isUserInteractionEnabled = !processing
        if processing {
            newButton.setTitle("", for: .normal)
            activityIndicator.startAnimating()
            
        } else {
            activityIndicator.stopAnimating()
            newButton.setTitle("New Collection", for: .normal)
        }
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return fetchedResultsController.fetchedObjects?.count ?? 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath)
        context.delete(photo)
        try? context.save()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let photo = fetchedResultsController.object(at: indexPath)
        cell.imageView.setPhoto(photo)
        return cell
        
    }
    
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width-20) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if let indexPath = indexPath, type == .delete && !deletingPhoto {
            collectionView.deleteItems(at: [indexPath])
            return
        }
        
        if let indexPath = indexPath, type == .insert {
            collectionView.insertItems(at: [indexPath])
            return
        }
        
        if let newIndexPath = newIndexPath, let oldIndexPath = indexPath, type == .move {
            collectionView.moveItem(at: oldIndexPath, to: newIndexPath)
            return
        }
        
        if type != .update {
            collectionView.reloadData()
        }
    }
    
}

