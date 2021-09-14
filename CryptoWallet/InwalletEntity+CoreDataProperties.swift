//
//  InwalletEntity+CoreDataProperties.swift
//  
//
//  Created by neoviso on 9/14/21.
//
//

import Foundation
import CoreData


extension InwalletEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InwalletEntity> {
        return NSFetchRequest<InwalletEntity>(entityName: "InwalletEntity")
    }

    @NSManaged public var code: String?
    @NSManaged public var value: Double

}
