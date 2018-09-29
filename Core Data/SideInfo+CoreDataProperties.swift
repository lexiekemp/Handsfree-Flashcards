//
//  SideInfo+CoreDataProperties.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 9/28/18.
//  Copyright © 2018 Lexie Kemp. All rights reserved.
//
//

import Foundation
import CoreData


extension SideInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SideInfo> {
        return NSFetchRequest<SideInfo>(entityName: "SideInfo")
    }

    @NSManaged public var index: Int64
    @NSManaged public var langID: String?
    @NSManaged public var name: String?
    @NSManaged public var parentSet: Set?

}
