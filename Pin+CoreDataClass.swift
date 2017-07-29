//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Richard H on 27/07/2017.
//  Copyright © 2017 Richard H. All rights reserved.
//

import Foundation
import CoreData


public class Pin: NSManagedObject {
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext){
        
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context){
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
            self.createdAt = Date() as NSDate
        }else{
            fatalError("Unable to find entity name")
        }
        
    }
}
