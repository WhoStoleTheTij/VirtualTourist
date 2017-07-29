//
//  CoreDataController.swift
//  VirtualTourist
//
//  Created by Richard H on 13/07/2017.
//  Copyright © 2017 Richard H. All rights reserved.
//

import CoreData

struct CoreDataHandler{
    
    private let model: NSManagedObjectModel
    internal let coordinator: NSPersistentStoreCoordinator
    private let modelURL: URL
    internal let dbURL: URL
    let context: NSManagedObjectContext
    
    //Mark: Init
    init?(modelName: String){
        
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else{
            print("UNable to find \(modelName) in the main bundle")
            return nil
        }
        
        self.modelURL = modelURL
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            print("Unable to create a mode from \(modelURL)")
            return nil
        }
        self.model = model
        
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        
        let fm = FileManager.default
        
        guard let docUrl = fm.urls(for: .documentDirectory, in: .userDomainMask).first else{
            print("Unable to reach documents folder")
            return nil
        }
        
        self.dbURL = docUrl.appendingPathComponent("model.sqlite")
        
        let options = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
        
        do{
            try addStoreCoordinator(NSSQLiteStoreType, configuration:nil, storeURL: dbURL, options: options as [NSObject: AnyObject]?)
        }catch{
            print("Unable to save store as \(dbURL)")
        }
    }
    
    func addStoreCoordinator(_ storeType: String, configuration: String?, storeURL: URL, options: [NSObject: AnyObject]?) throws{
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: nil)
    }
    
    
}

internal extension CoreDataHandler{
    
    func dropAllData() throws{
        try coordinator.destroyPersistentStore(at: dbURL, ofType: NSSQLiteStoreType, options: nil)
        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
    }
    
}


//Mark: save and delete functions
extension CoreDataHandler{
    
    func save(){
        context.performAndWait {
            if self.context.hasChanges{
                do{
                    try self.context.save()
                    print("Saving complete")
                }catch{
                    fatalError("Error while saving main context: \(error)")
                }
            }
        }
    }
    
    func autosave(_ delayInSeconds: Int){
        if delayInSeconds > 0{
            self.save()
            
        }
        
        let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
        let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: time){
            self.autosave(delayInSeconds)
        }
    }
    
    func deletePhotos(photos: [Photo]){
        
        for photo in photos{
            self.context.delete(photo)
        }
    }
    
    func deletePin(pins: [Pin]){
        
        for pin in pins{
            self.context.delete(pin)
        }
        
    }
    
}


























