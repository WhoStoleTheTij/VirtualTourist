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
    internal let persistingContext: NSManagedObjectContext
    internal let backgroundContext: NSManagedObjectContext //MIGHT NOT USE
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
        
        persistingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        persistingContext.persistentStoreCoordinator = coordinator
        
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = persistingContext
        
        //NOT SURE GOING TO USE
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = context
        
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

extension CoreDataHandler{
    
    typealias Batch = (_ workerContext: NSManagedObjectContext) -> ()
    
    func performBackgroundBatchOperation(_ batch: @escaping Batch){
        
        backgroundContext.perform(){
            batch(self.backgroundContext)
            
            do{
                try self.backgroundContext.save()
                print("Background Context saving")
            }catch{
                fatalError("Error while saving background context: \(error.localizedDescription) \(error)")
            }
        }
        
    }
    
}


extension CoreDataHandler{
    
    func save(){
        context.performAndWait {
            if self.context.hasChanges{
                do{
                    try self.context.save()
                    print("Saving complete")
                    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
                    let count = try? self.context.count(for: request)
                    print(count!)
                }catch{
                    fatalError("Error while saving main context: \(error)")
                }
                
                self.persistingContext.perform(){
                    do{
                        try self.persistingContext.save()
                    }catch{
                        fatalError("Error while saving persisting context: \(error)")
                    }
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
    
}


























