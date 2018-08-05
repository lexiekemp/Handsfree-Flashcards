//
//  Card+CoreDataProperties.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 7/23/18.
//  Copyright © 2018 Lexie Kemp. All rights reserved.
//
//

import Foundation
import CoreData


extension Card {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Card> {
        return NSFetchRequest<Card>(entityName: "Card")
    }

    @NSManaged public var sideOne: String?
    @NSManaged public var sideTwo: String?
    @NSManaged public var sideThree: String?
    @NSManaged public var parentSet: Set?

}
