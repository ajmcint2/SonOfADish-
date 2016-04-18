//
//  Restaurant.swift
//  TAS Group Project
//
//  Created by Alex McIntosh on 3/24/16.
//  Copyright © 2016 Alex McIntosh. All rights reserved.
//

import Foundation
import CoreData

class Restaurant: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var food: String
    @NSManaged var img: NSData
    @NSManaged var rating: Int
    @NSManaged var address: String
    @NSManaged var type: String
}