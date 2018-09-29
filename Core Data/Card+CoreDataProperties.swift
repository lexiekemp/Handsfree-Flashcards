//
//  Card+CoreDataProperties.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 9/28/18.
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
    @NSManaged public var sideThree: String?
    @NSManaged public var sideTwo: String?
    @NSManaged public var parentSet: Set?
    @NSManaged public var sides: NSSet?

}

// MARK: Generated accessors for sides
extension Card {

    @objc(addSidesObject:)
    @NSManaged public func addToSides(_ value: Side)

    @objc(removeSidesObject:)
    @NSManaged public func removeFromSides(_ value: Side)

    @objc(addSides:)
    @NSManaged public func addToSides(_ values: NSSet)

    @objc(removeSides:)
    @NSManaged public func removeFromSides(_ values: NSSet)

}
