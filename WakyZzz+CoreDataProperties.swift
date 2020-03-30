//
//  WakyZzz+CoreDataProperties.swift
//  WakyZzz
//
//  Created by Am GHAZNAVI on 26/03/2020.
//  Copyright © 2020 Am GHAZNAVI. All rights reserved.
//
//

import Foundation
import CoreData


extension WakyZzz {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WakyZzz> {
        return NSFetchRequest<WakyZzz>(entityName: "WakyZzz")
    }

    @NSManaged public var isEnabled: Bool
    @NSManaged public var time: Int32
    @NSManaged public var id: String?
    @NSManaged public var mon: Bool
    @NSManaged public var tue: Bool
    @NSManaged public var wed: Bool
    @NSManaged public var thu: Bool
    @NSManaged public var fri: Bool
    @NSManaged public var sat: Bool
    @NSManaged public var sun: Bool

}
