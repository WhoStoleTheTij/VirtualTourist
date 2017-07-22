//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Richard H on 18/07/2017.
//  Copyright © 2017 Richard H. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var image: NSData?
    @NSManaged public var pin: Pin?

}
