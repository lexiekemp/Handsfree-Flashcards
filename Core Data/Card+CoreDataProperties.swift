//
//  Card+CoreDataProperties.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 1/10/18.
//  Copyright © 2018 Lexie Kemp. All rights reserved.
//
//

import Foundation
import CoreData


extension Card {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Card> {
        return NSFetchRequest<Card>(entityName: "Card")
    }

    @NSManaged public var definition: String?
    @NSManaged public var word: String?
    @NSManaged public var parentSet: Set?

}
