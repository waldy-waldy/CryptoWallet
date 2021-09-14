//
//  BalanceEntity+CoreDataProperties.swift
//  
//
//  Created by neoviso on 9/14/21.
//
//

import Foundation
import CoreData


extension BalanceEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BalanceEntity> {
        return NSFetchRequest<BalanceEntity>(entityName: "BalanceEntity")
    }

    @NSManaged public var value: Double

}
