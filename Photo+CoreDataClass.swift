//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Richard H on 30/07/2017.
//  Copyright © 2017 Richard H. All rights reserved.
//

import Foundation
import CoreData


public class Photo: NSManagedObject {
    convenience init(url: String, context: NSManagedObjectContext){
        
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context){
            self.init(entity: ent, insertInto: context)
            self.url = url
        }else{
            fatalError("Unable to find entity name")
        }
        
    }
}
