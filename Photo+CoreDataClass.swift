//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Richard H on 27/07/2017.
//  Copyright © 2017 Richard H. All rights reserved.
//

import Foundation
import CoreData


public class Photo: NSManagedObject {
    convenience init(image: NSData, url: String, context: NSManagedObjectContext){
        
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context){
            self.init(entity: ent, insertInto: context)
            self.image = image
            self.url = url
        }else{
            fatalError("Unable to find entity name")
        }
        
    }}
