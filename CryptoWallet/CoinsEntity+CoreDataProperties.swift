//
//  CoinsEntity+CoreDataProperties.swift
//  
//
//  Created by neoviso on 9/13/21.
//
//

import Foundation
import CoreData


extension CoinsEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoinsEntity> {
        return NSFetchRequest<CoinsEntity>(entityName: "CoinsEntity")
    }

    @NSManaged public var changes: Double
    @NSManaged public var code: String?
    @NSManaged public var name: String?
    @NSManaged public var price: Double

}
