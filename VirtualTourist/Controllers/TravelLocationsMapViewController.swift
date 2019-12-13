//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Musaad on 12/4/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    
    @IBOutlet weak var travelMapView: MKMapView!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    
    
    var context: NSManagedObjectContext {
        return DataController.sharedInstance.viewContext
    }
    
    func settingFetchedResultsController() {
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false),
        ]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            updatingTravelMap()
            
        } catch {
            fatalError("The fetch could not be executed: \(error.localizedDescription)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settingFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    

    func updatingTravelMap() {
        
        guard let pins = fetchedResultsController.fetchedObjects else { return }
        
        for pin in pins {
            if travelMapView.annotations.contains(where: { pin.comparing(to: $0.coordinate) }) { continue }
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordination
            travelMapView.addAnnotation(annotation)
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let pin = fetchedResultsController.fetchedObjects?.filter {
            $0.comparing(to: view.annotation!.coordinate)
        }.first!
        performSegue(withIdentifier: "showAlbum", sender: pin)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let reuseId = "pin"

        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }


        return pinView
    }
    
    
    @IBAction func longPressAction(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state != .began { return }
        let touchPoint = sender.location(in: travelMapView)
        let pin = Pin(context: context)
        pin.coordination = travelMapView.convert(touchPoint, toCoordinateFrom: travelMapView)
        try? context.save()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        updatingTravelMap()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAlbum" {
            let photoVC = segue.destination as! PhotoAlbumViewController
            photoVC.pin = sender as? Pin
        }
    }
    
    
}
