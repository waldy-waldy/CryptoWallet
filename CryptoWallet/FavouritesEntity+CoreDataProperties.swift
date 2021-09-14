//
//  FavouritesEntity+CoreDataProperties.swift
//  
//
//  Created by neoviso on 9/14/21.
//
//

import Foundation
import CoreData


extension FavouritesEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavouritesEntity> {
        return NSFetchRequest<FavouritesEntity>(entityName: "FavouritesEntity")
    }

    @NSManaged public var code: String?

}
