//
//  DataController.swift
//  VirtualTourist
//
//  Created by Musaad on 12/9/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    static let sharedInstance = DataController()
    
    let persistentContainer = NSPersistentContainer(name: "VirtualTourist")
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func load()
    {
        
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else
            {
                fatalError(error!.localizedDescription)
            }
            
            
        }
        
        
    }
    
    
    
}
