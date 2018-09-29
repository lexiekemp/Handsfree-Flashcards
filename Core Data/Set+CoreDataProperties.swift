//
//  Set+CoreDataProperties.swift
//  HandsFreeFlashcards
//
//  Created by Lexie Kemp on 9/28/18.
//  Copyright © 2018 Lexie Kemp. All rights reserved.
//
//

import Foundation
import CoreData


extension Set {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Set> {
        return NSFetchRequest<Set>(entityName: "Set")
    }

    @NSManaged public var setName: String?
    @NSManaged public var sideOneLangID: String?
    @NSManaged public var sideOneName: String?
    @NSManaged public var sideThreeLangID: String?
    @NSManaged public var sideThreeName: String?
    @NSManaged public var sideTwoLangID: String?
    @NSManaged public var sideTwoName: String?
    @NSManaged public var childCards: NSSet?
    @NSManaged public var sideInfo: NSSet?

}

// MARK: Generated accessors for childCards
extension Set {

    @objc(addChildCardsObject:)
    @NSManaged public func addToChildCards(_ value: Card)

    @objc(removeChildCardsObject:)
    @NSManaged public func removeFromChildCards(_ value: Card)

    @objc(addChildCards:)
    @NSManaged public func addToChildCards(_ values: NSSet)

    @objc(removeChildCards:)
    @NSManaged public func removeFromChildCards(_ values: NSSet)

}

// MARK: Generated accessors for sideInfo
extension Set {

    @objc(addSideInfoObject:)
    @NSManaged public func addToSideInfo(_ value: SideInfo)

    @objc(removeSideInfoObject:)
    @NSManaged public func removeFromSideInfo(_ value: SideInfo)

    @objc(addSideInfo:)
    @NSManaged public func addToSideInfo(_ values: NSSet)

    @objc(removeSideInfo:)
    @NSManaged public func removeFromSideInfo(_ values: NSSet)

}
